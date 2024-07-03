import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _automaticTheme = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motyw',
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Automatyczny motyw', style: theme.textTheme.bodyLarge),
                Switch(
                  activeColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.grey[900],
                  inactiveTrackColor: Colors.grey[500],
                  value: _automaticTheme,
                  onChanged: (value) {
                    setState(() {
                      _automaticTheme = value;
                    });
                    // Dodaj tutaj logikę zmiany motywu
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ciemny motyw', style: theme.textTheme.bodyLarge),
                Switch(
                  activeColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.grey[900],
                  inactiveTrackColor: Colors.grey[500],
                  value: _isDarkMode,
                  onChanged: _automaticTheme ? null : (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    // Dodaj tutaj logikę zmiany motywu
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
