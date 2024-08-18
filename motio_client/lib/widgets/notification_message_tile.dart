import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification_message.dart';
import '../services/notification_service.dart';

class NotificationMessageTile extends StatelessWidget {
  final NotificationMessage notificationMessage;
  final NotificationService notificationService;
  final Function onDismissed;

  NotificationMessageTile({
    super.key,
    required this.notificationMessage,
    required this.notificationService,
    required this.onDismissed,
  });

  Future<void> _deleteNotification(BuildContext context) async {
    try {
      await notificationService.deleteNotification(notificationMessage.id);
      onDismissed();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Powiadomienie zostało usunięte.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania powiadomienia: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(notificationMessage.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Potwierdź usunięcie"),
              content: const Text("Czy na pewno chcesz usunąć to powiadomienie?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Nie"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Tak"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await _deleteNotification(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificationMessage.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  notificationMessage.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(notificationMessage.sendDateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
