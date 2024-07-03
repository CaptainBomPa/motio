import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../providers/meal_service_provider.dart';
import '../widgets/meal_tile.dart';

class MealsScreen extends ConsumerStatefulWidget {
  final String categoryName;

  const MealsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Future<List<Meal>> _mealsFuture;
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
    _mealsFuture = _loadMeals();
  }

  Future<List<Meal>> _loadMeals() async {
    final mealService = ref.read(mealServiceProvider);
    final meals = await mealService.fetchMealsByCategory(widget.categoryName);
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
    return meals;
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
        title: Text('Przepisy: ${widget.categoryName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Meal>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak przepisów'));
          } else {
            final meals = snapshot.data!;
            return FadeTransition(
              opacity: _animation,
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: MealTile(meal: meal),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
