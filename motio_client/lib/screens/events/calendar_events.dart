import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motio_client/models/event.dart';
import 'package:motio_client/services/event_service.dart';
import 'package:table_calendar/table_calendar.dart';

import 'add_update_event_screen.dart';

class CalendarEvents extends StatefulWidget {
  const CalendarEvents({super.key});

  @override
  State<CalendarEvents> createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  EventService eventService = EventService();
  final Map<DateTime, List<Event>> _eventsCache = {};
  bool isLoading = true;

  @override
  void initState() {
    _loadInitialEvents();
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  Future<void> _loadInitialEvents() async {
    _eventsCache.clear();
    final firstDayOfMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      1,
    ).copyWith(isUtc: true);
    final lastDayOfMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).copyWith(isUtc: true);

    final startDay = firstDayOfMonth.subtract(const Duration(days: 90));
    final endDay = lastDayOfMonth.add(const Duration(days: 365));

    List<Event> allEvents = await eventService.getEventsForUsernameOnDateRange(startDay, endDay);

    for (var event in allEvents) {
      final eventDay = event.startDateTime?.dateOnly().copyWith(isUtc: true);
      if (eventDay != null) {
        if (!_eventsCache.containsKey(eventDay)) {
          _eventsCache[eventDay] = [];
        }
        _eventsCache[eventDay]?.add(event);
      } else {
        final allDay = event.allDayDate!.dateOnly().copyWith(isUtc: true);
        if (!_eventsCache.containsKey(allDay)) {
          _eventsCache[allDay] = [];
        }
        _eventsCache[allDay]?.add(event);
      }
    }

    final initialEvents = _eventsCache[_selectedDay.dateOnly()] ?? [];
    setState(() {
      isLoading = false;
      _selectedEvents.value = initialEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadInitialEvents,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const Svg('assets/main/home_body.svg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.17), BlendMode.darken),
            ),
          ),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            child: Column(
              children: [
                TableCalendar<Event>(
                  locale: 'pl_PL',
                  firstDay: DateTime.now().subtract(const Duration(days: 90)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) {
                    return _eventsCache[day] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) async {
                    if (isLoading) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    final events = _eventsCache[selectedDay] ?? [];
                    _selectedEvents.value = events;
                  },
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                  headerStyle: _getHeaderStyle(),
                  daysOfWeekHeight: 26.0,
                  daysOfWeekStyle: _getDaysOfWeekStyle(),
                  calendarStyle: _getCalendarStyle(),
                  calendarBuilders: CalendarBuilders(singleMarkerBuilder: (context, day, events) {
                    return Container(
                      height: 5,
                      width: 5,
                      decoration: const BoxDecoration(
                        color: Colors.purpleAccent,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: isLoading
                      ? const Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  )
                      : ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50]?.withOpacity(0.9),
                              border: Border.all(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple[300]!,
                                  blurRadius: 4,
                                  offset: const Offset(6, 8),
                                ),
                              ],
                              image: const DecorationImage(
                                image: Svg('assets/main/notification_background.svg'),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${event.createdByUser.firstName} ${event.createdByUser.lastName}",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(event.eventName,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                              subtitle: Text(event.description ?? "",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  )),
                              trailing: event.allDayDate != null
                                  ? const Text(
                                "Cały dzień",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              )
                                  : Column(
                                children: [
                                  Text(
                                    "Od: ${_formatDateTime(event.startDateTime!)}" ?? "",
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Do: ${_formatDateTime(event.endDateTime!)}" ?? "",
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddUpdateEventScreen(),
            ),
          ).then((_) {
            _loadInitialEvents();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  CalendarStyle _getCalendarStyle() {
    return CalendarStyle(
        cellMargin: const EdgeInsets.all(2.0),
        markerDecoration: const BoxDecoration(
          color: Colors.redAccent,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.deepOrangeAccent.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(12.0),
        ),
        disabledDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
        outsideDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
        weekendDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
        weekendTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        defaultDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
        defaultTextStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold));
  }

  DaysOfWeekStyle _getDaysOfWeekStyle() {
    return DaysOfWeekStyle(
        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.2)),
        weekdayStyle: const TextStyle(fontSize: 16, color: Colors.black),
        weekendStyle: const TextStyle(fontSize: 16, color: Colors.deepOrangeAccent));
  }

  HeaderStyle _getHeaderStyle() {
    return const HeaderStyle(
      titleCentered: true,
      titleTextStyle: TextStyle(fontSize: 24, color: Colors.deepPurple),
      leftChevronIcon: Icon(
        Icons.chevron_left,
        size: 36,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        size: 36,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime
        .hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

extension DateTimeExtensions on DateTime {
  DateTime dateOnly() {
    return DateTime(this.year, this.month, this.day);
  }
}
