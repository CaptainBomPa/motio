import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import '../screens/events/add_update_event_screen.dart';

class EventItem extends ConsumerWidget {
  final Event event;
  final VoidCallback refreshEvents;

  const EventItem({
    Key? key,
    required this.event,
    required this.refreshEvents,
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddUpdateEventScreen(event: event),
                  ),
                ).then((_) {
                  refreshEvents();
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
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme
                .of(context)
                .primaryColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const Svg('assets/main/dialog_background.svg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Usuń wydarzenie',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Czy na pewno chcesz usunąć to wydarzenie?',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Anuluj',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        try {
                          final eventService = ref.read(eventServiceProvider);
                          await eventService.deleteEvent(event.id!);
                          refreshEvents();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd podczas usuwania wydarzenia: \$e')),
                          );
                        }
                      },
                      child: Text(
                        'Usuń',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          image: DecorationImage(
            image: event.startDateTime != null && event.endDateTime != null
                ? Svg('assets/main/event/time_event.svg')
                : Svg('assets/main/event/day_event.svg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventName,
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4.0),
            Text(
              'Założyciel: ${event.createdByUser.firstName} ${event.createdByUser.lastName}',
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (event.startDateTime != null && event.endDateTime != null) ...[
              const SizedBox(height: 4.0),
              Text(
                'Od: ${_formatDateTime(event.startDateTime!)}',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'Do: ${_formatDateTime(event.endDateTime!)}',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
            if (invitedPeople.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                'Zaproszeni: $invitedPeople',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
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
