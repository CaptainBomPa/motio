import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/event.dart';
import '../../models/user.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';

class EventDialog extends ConsumerStatefulWidget {
  final Event? event;

  const EventDialog({Key? key, this.event}) : super(key: key);

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _allDayDate;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<User> _invitedPeople = [];
  List<User> _allUsers = [];
  bool _isAllDay = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.eventName);
    _descriptionController = TextEditingController(text: widget.event?.description);
    _allDayDate = widget.event?.allDayDate;
    _startDateTime = widget.event?.startDateTime;
    _endDateTime = widget.event?.endDateTime;
    _invitedPeople = widget.event?.invitedPeople.toList() ?? [];
    _isAllDay = _allDayDate != null;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userService = ref.read(userServiceProvider);
    final users = await userService.getAllUsers();
    final current = await userService.getUserInfo();
    setState(() {
      _allUsers = users;
      currentUser = current!;
    });
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        (_isAllDay ? _allDayDate != null : (_startDateTime != null && _endDateTime != null));
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final eventService = ref.read(eventServiceProvider);
      DateTime dateToRefresh;

      if (widget.event != null) {
        final event = Event(
          id: widget.event!.id,
          eventName: _nameController.text,
          description: _descriptionController.text,
          allDayDate: _isAllDay ? _allDayDate?.toUtc() : null,
          startDateTime: _isAllDay ? null : _startDateTime?.toUtc(),
          endDateTime: _isAllDay ? null : _endDateTime?.toUtc(),
          invitedPeople: _invitedPeople.toList(),
          createdByUser: widget.event!.createdByUser,
        );
        await eventService.updateEvent(event.id, event);
        dateToRefresh = event.allDayDate ?? event.startDateTime!;
      } else {
        final newEvent = Event(
          id: 0,
          eventName: _nameController.text,
          description: _descriptionController.text,
          allDayDate: _isAllDay ? _allDayDate?.toUtc() : null,
          startDateTime: _isAllDay ? null : _startDateTime?.toUtc(),
          endDateTime: _isAllDay ? null : _endDateTime?.toUtc(),
          invitedPeople: _invitedPeople.toList(),
          createdByUser: currentUser!,
        );
        await eventService.addEvent(
          eventName: newEvent.eventName,
          description: newEvent.description,
          allDayDate: newEvent.allDayDate,
          startDateTime: newEvent.startDateTime,
          endDateTime: newEvent.endDateTime,
          invitedPeople: newEvent.invitedPeople,
          createdByUser: newEvent.createdByUser,
        );
        dateToRefresh = newEvent.allDayDate ?? newEvent.startDateTime!;
      }

      // Odświeżamy dane po dodaniu/modyfikacji wydarzenia
      ref.refresh(eventsForDateProvider(dateToRefresh));

      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {});
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj nazwę wydarzenia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Opis'),
                ),
                SwitchListTile(
                  title: Text(
                    'Całodniowe',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: _isAllDay,
                  onChanged: (value) {
                    setState(() {
                      _isAllDay = value;
                    });
                  },
                  activeTrackColor: theme.colorScheme.primary.withOpacity(0.4),
                  activeColor: theme.colorScheme.primary,
                  inactiveThumbColor: theme.colorScheme.onSurface,
                  inactiveTrackColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                ),
                if (_isAllDay) ...[
                  ListTile(
                    title: Text(
                      'Data',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      _allDayDate != null ? _formatDate(_allDayDate!) : 'Wybierz datę',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _allDayDate ?? DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _allDayDate = selectedDate;
                        });
                      }
                    },
                  ),
                ],
                if (!_isAllDay) ...[
                  ListTile(
                    title: Text(
                      'Data rozpoczęcia',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      _startDateTime != null ? _formatDateTime(_startDateTime!) : 'Wybierz datę i czas rozpoczęcia',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      final selectedDateTime = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime ?? DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDateTime != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startDateTime ?? DateTime.now()),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _startDateTime = DateTime(
                              selectedDateTime.year,
                              selectedDateTime.month,
                              selectedDateTime.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Data zakończenia',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      _endDateTime != null ? _formatDateTime(_endDateTime!) : 'Wybierz datę i czas zakończenia',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      final selectedDateTime = await showDatePicker(
                        context: context,
                        initialDate: _endDateTime ?? DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDateTime != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _endDateTime = DateTime(
                              selectedDateTime.year,
                              selectedDateTime.month,
                              selectedDateTime.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _allUsers.map((user) {
                    final isSelected = _invitedPeople.contains(user);
                    return ChoiceChip(
                      label: Text(
                        '${user.firstName} ${user.lastName}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _invitedPeople.add(user);
                          } else {
                            _invitedPeople.remove(user);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Anuluj'),
                    ),
                    ElevatedButton(
                      onPressed: _isFormValid ? _saveEvent : null,
                      child: const Text('Zapisz'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
