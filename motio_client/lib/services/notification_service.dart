import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_message.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class NotificationService extends BaseService {
  static const String _notificationUrl = HostApiData.baseNotificationApiUrl;

  Future<List<NotificationMessage>> fetchNotifications() async {
    final response = await sendAuthenticatedRequest(http.Request('GET', Uri.parse(_notificationUrl)));

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      return body.map((dynamic item) => NotificationMessage.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await sendAuthenticatedRequest(http.Request('DELETE', Uri.parse('$_notificationUrl/$id')));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}
