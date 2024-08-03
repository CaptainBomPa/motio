import 'user.dart';

class Event {
  final int id;
  final String eventName;
  final String? description;
  final User createdByUser;
  final List<User> invitedPeople;
  final DateTime? allDayDate;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final int? reminderMinutesBefore;

  Event({
    required this.id,
    required this.eventName,
    this.description,
    required this.createdByUser,
    required this.invitedPeople,
    this.allDayDate,
    this.startDateTime,
    this.endDateTime,
    this.reminderMinutesBefore,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'],
      description: json['description'],
      createdByUser: User.fromJson(json['createdByUser']),
      invitedPeople: (json['invitedPeople'] as List).map((e) => User.fromJson(e)).toList(),
      allDayDate: json['allDayDate'] != null ? DateTime.parse(json['allDayDate']) : null,
      startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']).toLocal() : null,
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']).toLocal() : null,
      reminderMinutesBefore: json['reminderMinutesBefore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'description': description,
      'createdByUser': createdByUser.toJson(),
      'invitedPeople': invitedPeople.map((user) => user.toJson()).toList(),
      'allDayDate': allDayDate?.toIso8601String(),
      'startDateTime': startDateTime?.toUtc().toIso8601String(),
      'endDateTime': endDateTime?.toUtc().toIso8601String(),
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }
}
