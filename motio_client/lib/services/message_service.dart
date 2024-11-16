import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motio_client/services/user_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'local_notification_service.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  LocalNotificationService service = LocalNotificationService();
  service.initialize();
  service.showNotification(message);
}

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  Future<void> setupFirebase() async {
    await _localNotificationService.initialize();

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    if (Platform.isIOS) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      String? apnsToken = await _firebaseMessaging.getAPNSToken();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _localNotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      UserService userService = UserService();
      userService.updateNotificationToken(token);
      listenToPublic();
    } else {}
  }

  void listenToPublic() {
    if (!kIsWeb && Platform.isAndroid) {
      _firebaseMessaging.subscribeToTopic("all_users").then((_) {}).catchError((error) {});
    }
  }
}
