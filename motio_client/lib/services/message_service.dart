import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motio_client/services/user_service.dart';

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
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        print('APNS token: $apnsToken');
      } else {
        print('APNS token not yet available.');
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}');
      _localNotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.notification?.title}');
    });

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Push Messaging token: $token");
      UserService userService = UserService();
      userService.updateNotificationToken(token);
      listenToPublic();
    } else {
      print("Unable to get FCM token.");
    }
  }

  void listenToPublic() {
    _firebaseMessaging.subscribeToTopic("all_users").then((_) {
      print("Subscribed to topic all_users");
    }).catchError((error) {
      print("Failed to subscribe to topic: $error");
    });
  }
}

