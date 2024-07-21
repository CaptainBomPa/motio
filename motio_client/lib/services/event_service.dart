import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/user.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class EventService extends BaseService {
  static const String _eventsUrl = "${HostApiData.baseCoreApiUrl}/events";

  Future<Event> addEvent({
    required String eventName,
    final String? description,
    required User createdByUser,
    required List<User> invitedPeople,
    final DateTime? allDayDate,
    final DateTime? startDateTime,
    final DateTime? endDateTime,
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
          'endDateTime': endDateTime?.toIso8601String()
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
      return body.map((dynamic item) => Event.fromJson(item)).toList();
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
}
