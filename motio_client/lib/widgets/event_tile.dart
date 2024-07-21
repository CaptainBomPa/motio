import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/event_provider.dart';  // poprawiona nazwa pliku
import 'event_item.dart';

class EventTile extends ConsumerWidget {
  final DateTime date;

  const EventTile({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayOfWeek = _getDayOfWeek(date.weekday);
    final formattedDate = "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    final eventsAsyncValue = ref.watch(eventsForDateProvider(date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.dividerColor),
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Text(
            '$dayOfWeek, $formattedDate',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ),
        eventsAsyncValue.when(
          data: (events) {
            if (events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Brak wydarzeń na ten dzień'),
              );
            } else {
              // Sortowanie wydarzeń
              events.sort((a, b) {
                // Najpierw sortujemy według tego, czy są całodniowe
                if (a.allDayDate != null && b.allDayDate == null) {
                  return -1;
                } else if (a.allDayDate == null && b.allDayDate != null) {
                  return 1;
                } else {
                  // Następnie sortujemy według eventName
                  return a.eventName.compareTo(b.eventName);
                }
              });

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Wrap(
                  spacing: 2.0,
                  runSpacing: 0.0,
                  children: events.map((event) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: EventItem(event: event),
                  )).toList(),
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Błąd wczytywania wydarzeń: $err'),
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Poniedziałek';
      case DateTime.tuesday:
        return 'Wtorek';
      case DateTime.wednesday:
        return 'Środa';
      case DateTime.thursday:
        return 'Czwartek';
      case DateTime.friday:
        return 'Piątek';
      case DateTime.saturday:
        return 'Sobota';
      case DateTime.sunday:
        return 'Niedziela';
      default:
        return '';
    }
  }
}
