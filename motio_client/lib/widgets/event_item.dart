import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import 'dialog/event_dialog.dart';

class EventItem extends ConsumerWidget {
  final Event event;

  const EventItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modyfikuj'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => EventDialog(event: event),
                ).then((_) {
                  // Odświeżamy dane po zamknięciu dialogu
                  ref.refresh(eventsForDateProvider(event.startDateTime ?? event.allDayDate!));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Usuń'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdź usunięcie'),
          content: const Text('Czy na pewno chcesz usunąć to wydarzenie?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                final eventService = ref.read(eventServiceProvider);
                await eventService.deleteEvent(event.id!);
                Navigator.of(context).pop();
                // Odświeżamy dane po usunięciu wydarzenia
                ref.refresh(eventsForDateProvider(event.startDateTime ?? event.allDayDate!));
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invitedPeople = event.invitedPeople.map((user) => '${user.firstName} ${user.lastName}').join(', ');

    return GestureDetector(
      onLongPress: () => _showOptions(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          gradient: event.startDateTime != null && event.endDateTime != null
              ? const LinearGradient(
            colors: [Colors.purple, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Colors.pinkAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventName,
              style: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                style: theme.textTheme.bodySmall,
              ),
            if (event.startDateTime != null && event.endDateTime != null) ...[
              const SizedBox(height: 4.0),
              Text(
                'Od: ${_formatDateTime(event.startDateTime!)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Do: ${_formatDateTime(event.endDateTime!)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (invitedPeople.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                invitedPeople,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
