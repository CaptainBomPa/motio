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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}');
      _localNotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.notification?.title}');
    });

    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Push Messaging token: $token");
      UserService userService = UserService();
      userService.updateNotificationToken(token!);
    });
  }

  void listenToPublic() {
    _firebaseMessaging.subscribeToTopic("all_users");
  }
}
