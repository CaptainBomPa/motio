import 'package:motio_client/models/user.dart';

class NotificationMessage {
  final int id;
  final String? firebaseGeneratedId;
  final String messageType;
  final User? receiver;
  final String title;
  final String body;
  final DateTime sendDateTime;

  NotificationMessage({
    required this.id,
    this.firebaseGeneratedId,
    required this.messageType,
    this.receiver,
    required this.title,
    required this.body,
    required this.sendDateTime,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'],
      firebaseGeneratedId: json['firebaseGeneratedId'],
      messageType: json['messageType'],
      receiver: User.fromJson(json['receiver']),
      title: json['title'],
      body: json['body'],
      sendDateTime: DateTime.parse(json['sendDateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseGeneratedId': firebaseGeneratedId,
      'messageType': messageType,
      'receiver': receiver,
      'title': title,
      'body': body,
      'sendDateTime': sendDateTime.toIso8601String(),
    };
  }
}
