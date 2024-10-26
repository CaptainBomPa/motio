import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../models/notification_message.dart';
import '../services/notification_service.dart';

class NotificationMessageTile extends StatelessWidget {
  final NotificationMessage notificationMessage;
  final NotificationService notificationService;
  final Function onDismissed;

  const NotificationMessageTile({
    super.key,
    required this.notificationMessage,
    required this.notificationService,
    required this.onDismissed,
  });

  Future<void> _deleteNotification(BuildContext context) async {
    try {
      await notificationService.deleteNotification(notificationMessage.id);
      onDismissed();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Powiadomienie zostało usunięte.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd podczas usuwania powiadomienia.')),
        );
      }
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
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.red,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Lottie.asset(
          'assets/animations/delete_animation.json',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
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
        padding: const EdgeInsets.all(1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 6.0, bottom: 6.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[50]?.withOpacity(0.9),
              border: Border.all(
                color: theme.primaryColor,
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
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificationMessage.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  notificationMessage.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(notificationMessage.sendDateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
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
