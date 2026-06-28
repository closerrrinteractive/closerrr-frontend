import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static int? activeChatId;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _channel =
      MethodChannel('com.sharkbrewsinternational.closerrr/notifications');

  static Future<void> initialize(BuildContext context) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('notification_icon'),
      iOS: DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    final shared = await SharedPreferences.getInstance();
    final sound = shared.getString('chat_sound');

    // Create notification channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'com.sharkbrewsinternational.closerrr',
      'Push Notifications',
      description: 'Channel for push notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: (sound != null && sound.isNotEmpty)
          ? RawResourceAndroidNotificationSound(sound)
          : null,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request notification permission for Android 13+
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    // Set up method channel for Firebase messaging
    setupMethodChannel();
  }

  static void setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'createAndDisplayNotification') {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(call.arguments);
        final message = RemoteMessage(data: data);
        await createAndDisplayNotification(message);
      }
      return null;
    });
  }

  static Future<void> createAndDisplayNotification(
      RemoteMessage message) async {
    // Check if the user is actively viewing this chat to mute notification
    final chatIdStr = (message.data['chat_id'] ?? message.data['chatId'])?.toString();
    if (chatIdStr != null && activeChatId != null && chatIdStr == activeChatId.toString()) {
      return;
    }

    final shared = await SharedPreferences.getInstance();

    // 1. Extract friendId / senderId
    String? friendId;
    if (message.data.containsKey('sender_id')) {
      friendId = message.data['sender_id']?.toString();
    } else if (message.data.containsKey('friend_id')) {
      friendId = message.data['friend_id']?.toString();
    } else if (message.data.containsKey('influencer_id')) {
      friendId = message.data['influencer_id']?.toString();
    } else if (message.data.containsKey('callerId')) {
      friendId = message.data['callerId']?.toString();
    } else if (message.data.containsKey('user_id')) {
      friendId = message.data['user_id']?.toString();
    }

    // 2. Extract notification type
    final type = (message.data['type'] ?? '').toString().toLowerCase();

    // Map type to category: messages, events, live, stories
    String category = 'messages';
    if (type.contains('event')) {
      category = 'events';
    } else if (type.contains('live') || type.contains('call') || type == 'join_live_stream') {
      category = 'live';
    } else if (type.contains('story') || type.contains('stories')) {
      category = 'stories';
    } else {
      category = 'messages';
    }

    // 3. Check enabled state (Friend override -> Global -> true)
    bool isEnabled = true;
    if (friendId != null) {
      final friendKey = 'enabled_${category}_$friendId';
      if (shared.containsKey(friendKey)) {
        isEnabled = shared.getBool(friendKey) ?? true;
      } else {
        final globalKey = 'enabled_$category';
        isEnabled = shared.getBool(globalKey) ?? true;
      }
    } else {
      final globalKey = 'enabled_$category';
      isEnabled = shared.getBool(globalKey) ?? true;
    }

    if (!isEnabled) {
      return;
    }

    // 4. Resolve Sound Tone
    String toneKey;
    if (category == 'messages') {
      toneKey = 'chat_sound';
    } else if (category == 'events') {
      toneKey = 'event_sound';
    } else if (category == 'live') {
      toneKey = 'call_ringtone';
    } else {
      toneKey = 'story_sound';
    }

    String? sound;
    if (friendId != null) {
      sound = shared.getString('${toneKey}_$friendId');
    }
    sound ??= shared.getString(toneKey);

    // Closerrr Live ringtone defaults to 'Haven' if not set or if it's legacy 'Default'
    if (category == 'live') {
      if (sound == null || sound.isEmpty || sound == 'Default') {
        sound = 'Haven';
      }
    }

    // 5. Resolve Vibration choice
    String vibeKey = 'vibration_$category';
    String? vibeChoice;
    if (friendId != null) {
      vibeChoice = shared.getString('${vibeKey}_$friendId');
    }
    vibeChoice ??= shared.getString(vibeKey);
    vibeChoice ??= 'default';

    // 6. Map vibration settings to pattern
    bool enableVibration = true;
    Int64List? vibrationPattern;

    if (vibeChoice.toLowerCase() == 'off') {
      enableVibration = false;
    } else if (vibeChoice.toLowerCase() == 'short') {
      vibrationPattern = Int64List.fromList([0, 100, 100, 100]);
    } else if (vibeChoice.toLowerCase() == 'medium') {
      vibrationPattern = Int64List.fromList([0, 300, 200, 300]);
    } else if (vibeChoice.toLowerCase() == 'long') {
      if (category == 'live') {
        // Continuous buzz for Closerrr Live alerts
        vibrationPattern = Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000]);
      } else {
        vibrationPattern = Int64List.fromList([0, 800, 400, 800]);
      }
    }

    try {
      AndroidNotificationSound? androidSound;
      if (category == 'live' && (sound == null || sound.isEmpty || sound == 'System Default')) {
        androidSound = const UriAndroidNotificationSound('content://settings/system/ringtone');
      } else if (sound != null && sound.isNotEmpty && sound != 'System Default') {
        if (sound.startsWith('/') || sound.contains('/') || sound.startsWith('content:')) {
          String uriString = sound;
          if (sound.startsWith('/')) {
            uriString = Uri.file(sound).toString();
          }
          androidSound = UriAndroidNotificationSound(uriString);
        } else {
          // Custom sounds are lowercase without extension on Android raw resources
          androidSound = RawResourceAndroidNotificationSound(sound.toLowerCase());
        }
      }

      final sanitizedSound = (sound != null && sound.isNotEmpty)
          ? sound.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase()
          : 'default';
      final channelId = 'com.sharkbrewsinternational.closerrr.${category}_${sanitizedSound}_$vibeChoice';

      if (Platform.isAndroid) {
        final channel = AndroidNotificationChannel(
          channelId,
          '${category[0].toUpperCase()}${category.substring(1)} Notifications',
          description: 'Channel for $category notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: enableVibration,
          vibrationPattern: vibrationPattern,
          sound: androidSound,
        );

        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        '${category[0].toUpperCase()}${category.substring(1)} Notifications',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: enableVibration,
        vibrationPattern: vibrationPattern,
        playSound: true,
        sound: androidSound,
      );

      final iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: (sound != null && sound.isNotEmpty && sound != 'System Default')
            ? '${sound.toLowerCase()}.m4a'
            : null,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? message.data['title'] ?? 'New Notification',
        message.notification?.body ?? message.data['body'] ?? '',
        notificationDetails,
        payload: json.encode(message.data),
      );
    } on Exception catch (e) {
      print('Error displaying notification: $e');
    }
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  print('Background Notification Received: ${details.payload}');
}
