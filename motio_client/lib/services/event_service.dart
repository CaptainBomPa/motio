import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';
import 'notification_service.dart';

class EventService extends BaseService {
  static const String _eventsUrl = "${HostApiData.baseCoreApiUrl}/events";
  final NotificationService _notificationService;

  EventService()
      : _notificationService = NotificationService() {
    // Zainicjalizuj NotificationService raz przy tworzeniu EventService
    _notificationService.initialize();
  }

  Future<Event> addEvent({
    required String eventName,
    final String? description,
    required User createdByUser,
    required List<User> invitedPeople,
    final DateTime? allDayDate,
    final DateTime? startDateTime,
    final DateTime? endDateTime,
    final int? reminderMinutesBefore,
  }) async {
    final response = await sendAuthenticatedRequest(
      http.Request('POST', Uri.parse(_eventsUrl))
        ..body = jsonEncode({
          'eventName': eventName,
          'description': description,
          'createdByUser': createdByUser.toJson(),
          'invitedPeople': invitedPeople.map((user) => user.toJson()).toList(),
          'allDayDate': allDayDate?.toIso8601String(),
          'startDateTime': startDateTime?.toIso8601String(),
          'endDateTime': endDateTime?.toIso8601String(),
          'reminderMinutesBefore': reminderMinutesBefore,
        }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Event.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<Event> updateEvent(int id, Event event) async {
    final response = await sendAuthenticatedRequest(
      http.Request('PUT', Uri.parse('$_eventsUrl/$id'))
        ..headers['Content-Type'] = 'application/json; charset=UTF-8'
        ..body = jsonEncode(event.toJson()),
    );

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<List<Event>> getEventsForUsernameOnDate(String username, DateTime date) async {
    final formattedDate = _formatDate(date);
    final response = await sendAuthenticatedRequest(
      http.Request('GET', Uri.parse('$_eventsUrl/user/date?date=$formattedDate')),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final events = body.map((dynamic item) => Event.fromJson(item)).toList();

      events.forEach((event) {
        if (event.eventName == 'test3') {
          print(event.startDateTime);
          print(event.endDateTime);
        }
      });

      // Zapisz wydarzenia w pamięci
      await _saveEventsToLocal(events);

      // Zaplanuj powiadomienia dla wydarzeń
      for (var event in events) {
        if (event.reminderMinutesBefore != null) {
          await _notificationService.scheduleEventNotification(event);
        }
      }

      return events;
    } else {
      throw Exception('Failed to load events for user on date');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await sendAuthenticatedRequest(
      http.Request('DELETE', Uri.parse('$_eventsUrl/$id')),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete event');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEventsToLocal(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final oneMonthLater = today.add(Duration(days: 30));

    final eventsToSave = events.where((event) {
      final eventDate = event.allDayDate ?? event.startDateTime!;
      return eventDate.isAfter(today) && eventDate.isBefore(oneMonthLater);
    }).toList();

    final eventsJson = jsonEncode(eventsToSave.map((e) => e.toJson()).toList());
    await prefs.setString('events', eventsJson);
  }

  Future<List<Event>> getLocalEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');

    if (eventsJson != null) {
      final List<dynamic> eventList = jsonDecode(eventsJson);
      return eventList.map((dynamic item) => Event.fromJson(item)).toList();
    } else {
      return [];
    }
  }
}

