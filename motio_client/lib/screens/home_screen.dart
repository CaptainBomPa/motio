import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/services/message_service.dart';

import '../providers/user_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_screen_body.dart';
import '../widgets/user_greeting.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _setupNotifications() {
    final messagingService = MessagingService();
    messagingService.setupFirebase();
    messagingService.listenToPublic();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    _setupNotifications();

    return Scaffold(
      appBar: AppBar(
        title: UserGreeting(user: user),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      drawer: const AppDrawer(),
      body: const HomeScreenBody(),
    );
  }
}
