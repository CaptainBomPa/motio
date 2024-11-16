import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:intl/intl.dart';

import '../../models/event.dart';
import '../../models/user.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';

class AddUpdateEventScreen extends ConsumerStatefulWidget {
  final Event? event;

  const AddUpdateEventScreen({Key? key, this.event}) : super(key: key);

  @override
  _AddUpdateEventScreenState createState() => _AddUpdateEventScreenState();
}

class _AddUpdateEventScreenState extends ConsumerState<AddUpdateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _reminderController;
  DateTime? _allDayDate;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<User> _invitedPeople = [];
  List<User> _allUsers = [];
  bool _isAllDay = false;
  bool _hasReminder = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.eventName);
    _descriptionController = TextEditingController(text: widget.event?.description);
    _reminderController = TextEditingController(text: widget.event?.reminderMinutesBefore?.toString() ?? ''); // Nowe pole
    _allDayDate = widget.event?.allDayDate ?? DateTime.now();
    _startDateTime = widget.event?.startDateTime ?? DateTime.now().add(const Duration(hours: 1));
    _endDateTime = widget.event?.endDateTime ?? DateTime.now().add(const Duration(hours: 2));
    _invitedPeople = widget.event?.invitedPeople.toList() ?? [];
    _isAllDay = _allDayDate != null;
    _hasReminder = widget.event?.reminderMinutesBefore != null;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userService = ref.read(userServiceProvider);
    final users = await userService.getAllUsers();
    final current = await userService.getUserInfo();
    users.remove(current);
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

      _allDayDate = _allDayDate?.copyWith(hour: 12, isUtc: true);

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
          reminderMinutesBefore: _hasReminder ? int.tryParse(_reminderController.text) : null, // Nowe pole
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
          reminderMinutesBefore: _hasReminder ? int.tryParse(_reminderController.text) : null, // Nowe pole
        );
        await eventService.addEvent(
          eventName: newEvent.eventName,
          description: newEvent.description,
          allDayDate: newEvent.allDayDate,
          startDateTime: newEvent.startDateTime,
          endDateTime: newEvent.endDateTime,
          invitedPeople: newEvent.invitedPeople,
          createdByUser: newEvent.createdByUser,
          reminderMinutesBefore: newEvent.reminderMinutesBefore, // Nowe pole
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edytuj wydarzenie' : 'Dodaj wydarzenie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: Svg('assets/main/app_bar.svg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: theme.textTheme.bodyLarge!.copyWith(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Svg('assets/main/home_body.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.25), BlendMode.darken),
          ),
        ),
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
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 1,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Całodniowe',
                        style: TextStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                          if (_isAllDay) {
                            _hasReminder = false; // Wyłączenie przypomnienia dla całodniowych wydarzeń
                          }
                        });
                      },
                      activeTrackColor: theme.colorScheme.primary.withOpacity(0.4),
                      activeColor: theme.colorScheme.primary,
                      inactiveThumbColor: theme.colorScheme.onSurface,
                      inactiveTrackColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                    ),
                  ),
                  if (_isAllDay) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Data',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          _allDayDate != null ? _formatDate(_allDayDate!) : 'Wybierz datę',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
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
                    ),
                  ],
                  if (!_isAllDay) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Data rozpoczęcia',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          _startDateTime != null ? _formatDateTime(_startDateTime!) : 'Wybierz datę i czas rozpoczęcia',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
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
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Data zakończenia',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          _endDateTime != null ? _formatDateTime(_endDateTime!) : 'Wybierz datę i czas zakończenia',
                          style: TextStyle(
                              color: theme.primaryColor
                          ),
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
                    ),
                  ],
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        'Przypomnienie',
                        style: TextStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                      value: _hasReminder,
                      onChanged: _isAllDay
                          ? null // Blokowanie przypomnienia dla całodniowych wydarzeń
                          : (value) {
                        setState(() {
                          _hasReminder = value ?? false;
                          if (!_hasReminder) {
                            _reminderController.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  if (!_isAllDay && _hasReminder) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _reminderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minuty przed wydarzeniem'),
                      validator: (value) {
                        if (_hasReminder && (value == null || value.isEmpty)) {
                          return 'Podaj liczbę minut';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 1,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _allUsers.map((user) {
                        final isSelected = _invitedPeople.contains(user);
                        return ChoiceChip(
                          label: Text(
                            '${user.firstName} ${user.lastName}',
                            style: isSelected ? const TextStyle(color: Colors.white) : TextStyle(color: theme.primaryColor),
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isFormValid ? _saveEvent : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return theme.colorScheme.onPrimary.withOpacity(0.5);
                              }
                              return theme.primaryColor; // Ustawienie koloru tła dla aktywnego przycisku
                            },
                          ),
                        ),
                        child: Text(
                          'Zapisz',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
