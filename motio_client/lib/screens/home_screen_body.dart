import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/notification_message.dart';
import '../services/notification_service.dart';
import '../widgets/notification_message_tile.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  List<NotificationMessage> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _fetchNotifications();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił problem podczas ładowania notyfikacji. Spróbuj ponownie. $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const Svg('assets/main/home_body.svg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'Brak notyfikacji do wyświetlenia',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: FadeTransition(
        opacity: _animation,
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(_animation),
              child: NotificationMessageTile(
                notificationMessage: notification,
                notificationService: _notificationService,
                onDismissed: () {
                  setState(() {
                    _notifications.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
