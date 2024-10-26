import 'package:flutter/material.dart';

import '../models/user.dart';

class UserGreeting extends StatelessWidget {
  final User? user;

  const UserGreeting({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      user != null
          ? 'Cześć, ${user!.firstName.isNotEmpty ? user!.firstName : user!.username}! 👋'
          : 'Ładowanie...',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
