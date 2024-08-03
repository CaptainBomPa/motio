import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor
  factory NotificationService() => _instance;

  // Private constructor
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Zainicjalizuj dane stref czasowych
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('icon'); // Upewnij się, że 'app_icon' to nazwa pliku ikony w katalogu res

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Dodatkowa logika po kliknięciu powiadomienia, jeśli potrzebujesz
      },
    );
  }

  Future<void> scheduleEventNotification(Event event) async {
    final DateTime? eventDateTime = event.startDateTime;
    if (eventDateTime != null && event.reminderMinutesBefore != null) {
      // Konwertuj DateTime na TZDateTime
      final tz.TZDateTime notificationTime = tz.TZDateTime.from(
        eventDateTime.subtract(Duration(minutes: event.reminderMinutesBefore!)),
        tz.local,
      );

      if (notificationTime.isAfter(tz.TZDateTime.now(tz.local))) {
        print('Zaplanoawano powiadomienie dla ${event.eventName} o ${notificationTime.toString()}');

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          event.id.hashCode, // Użyj hashCode lub innego unikalnego ID
          'Przypomnienie o wydarzeniu',
          'Wydarzenie ${event.eventName} zaczyna się za ${event.reminderMinutesBefore} minut',
          notificationTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'event_channel', // Upewnij się, że ID kanału jest zgodne z konfiguracją
              'Event Notifications',
              channelDescription: 'Powiadomienia o nadchodzących wydarzeniach',
              importance: Importance.max,
              priority: Priority.high,
              ongoing: false,
              // Ustaw na false, aby powiadomienie było usuwalne
              playSound: true,
              enableVibration: true,
              visibility: NotificationVisibility.public,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // Pozwala powiadomieniom działać w trybie oszczędzania energii
          androidAllowWhileIdle: true,
          // Upewnij się, że powiadomienia są wyświetlane w trybie bezczynności
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }
}
