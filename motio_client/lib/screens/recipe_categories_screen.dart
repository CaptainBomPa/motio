import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_category.dart';
import '../providers/meal_category_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_tile.dart';
import 'add_meal_screen.dart';

class RecipeCategoriesScreen extends ConsumerStatefulWidget {
  const RecipeCategoriesScreen({Key? key}) : super(key: key);

  @override
  _RecipeCategoriesScreenState createState() => _RecipeCategoriesScreenState();
}

class _RecipeCategoriesScreenState extends ConsumerState<RecipeCategoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<MealCategory> _mealCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await ref.read(mealCategoryProvider.future);
    setState(() {
      _mealCategories = categories;
      _isLoading = false;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Przepisy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMealScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _animation,
        child: ListView.builder(
          itemCount: _mealCategories.length,
          itemBuilder: (context, index) {
            final category = _mealCategories[index];
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
