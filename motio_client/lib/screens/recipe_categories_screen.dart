import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../providers/meal_category_provider.dart';
import '../widgets/category_tile.dart';
import '../providers/debt_provider.dart';
import '../services/debt_service.dart';
import '../widgets/debt_list_tile.dart';
import '../widgets/dialog/add_debt_dialog.dart';
import '../providers/todo_list_provider.dart';
import '../widgets/dialog/new_todo_list_dialog.dart';
import '../widgets/todo_list_tile.dart';
import 'add_edit_meal_screen.dart';
import '../widgets/event_tile.dart';
import '../providers/event_provider.dart';
import 'events/add_update_event_screen.dart';

class MealCategoriesScreen extends ConsumerStatefulWidget {
  const MealCategoriesScreen({super.key});

  @override
  ConsumerState<MealCategoriesScreen> createState() => _MealCategoriesScreenState();
}

class _MealCategoriesScreenState extends ConsumerState<MealCategoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animateScreen();
  }

  void _animateScreen() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealCategories = ref.watch(mealCategoryProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Svg('assets/main/home_body.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: mealCategories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _animation,
          child: ListView.builder(
            itemCount: mealCategories.length,
            itemBuilder: (context, index) {
              final category = mealCategories[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(_animation),
                child: CategoryTile(category: category),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditMealScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}