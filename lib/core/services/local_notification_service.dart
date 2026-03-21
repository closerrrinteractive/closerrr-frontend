import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
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
    final shared = await SharedPreferences.getInstance();
    final sound = shared.getString('chat_sound');

    try {
      final androidDetails = AndroidNotificationDetails(
        'com.sharkbrewsinternational.closerrr',
        'Push Notifications',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        sound: (sound != null && sound.isNotEmpty)
            ? RawResourceAndroidNotificationSound(sound)
            : null,
      );

      final iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: (sound != null && sound.isNotEmpty) ? '$sound.aiff' : null,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
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
