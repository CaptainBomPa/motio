import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import 'user_provider.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

final eventsForDateProvider = FutureProvider.family<List<Event>, DateTime>((ref, date) async {
  final eventService = ref.watch(eventServiceProvider);
  final user = ref.watch(userProvider);
  if (user == null) {
    throw Exception('User is not authenticated');
  }
  return await eventService.getEventsForUsernameOnDate(user.username, date);
});
