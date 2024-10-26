// HomeScreen implementation with PageView
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/services/message_service.dart';
import '../providers/user_provider.dart';
import '../widgets/home_screen_body.dart';
import '../widgets/carousel_app_bar.dart';
import '../screens/debt_screen.dart';
import '../screens/events_screen.dart';
import '../screens/recipe_categories_screen.dart';
import '../screens/todo_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();

  void _setupNotifications() {
    final messagingService = MessagingService();
    messagingService.setupFirebase();
    messagingService.listenToPublic();
  }

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: CarouselAppBar(user: user, pageController: _pageController),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeScreenBody(),
          TodoListScreen(),
          DebtScreen(),
          EventsScreen(),
          MealCategoriesScreen(),
        ],
      ),
    );
  }
}
