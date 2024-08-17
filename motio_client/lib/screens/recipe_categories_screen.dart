import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meal_category_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_tile.dart';
import 'add_edit_meal_screen.dart';

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
      appBar: AppBar(
        title: const Text('Przepisy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditMealScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: mealCategories.isEmpty
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
    );
  }
}
