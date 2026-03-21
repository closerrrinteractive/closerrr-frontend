import 'package:closerrr/core/services/custom_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../src/controller/routing/routing_controller.dart';

class PushNotificationService {
  static final FirebaseMessaging fcm = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await fcm.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
        criticalAlert: true,
        announcement: true,
        carPlay: true);
  }

  Future<void> handleMsgWhenTerminated(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        kLog("FirebaseMessaging.terminated.message.listen => $message");
        final notification = message!.notification;
        final data = message.data;
        if (notification != null) {
          if (data["type"] == "JOIN_LIVE_STREAM") {
            RouterController.current
                .pushNamed('stream_call', extra: {'userData': data});
          }
          // LocalNotificationService.createAndDisplayNotification(message);
        }
      },
    );
  }

  Future<void> handleForegroundMsg(BuildContext context) async {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        kLog("On recieved foreground message");
        final notification = message.notification;
        final data = message.data;
        if (notification != null) {
          if (data["type"] == "JOIN_LIVE_STREAM") {
            RouterController.current
                .pushNamed('stream_call', extra: {'userData': data});
          }
          // LocalNotificationService.createAndDisplayNotification(message);
        }
      },
    );
  }

  Future<void> handlebackgroundMsg(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        kLog("FirebaseMessaging.onMessageOpenedApp.listen");
        final notification = message.notification;
        final data = message.data;
        if (notification != null) {
          if (data["type"] == "JOIN_LIVE_STREAM") {
            RouterController.current
                .pushNamed('stream_call', extra: {'userData': data});
          }
          // LocalNotificationService.createAndDisplayNotification(message);
        }
      },
    );
  }
}
