import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

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
    return Container(
      decoration: getDecoration(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: Svg('assets/main/app_bar.svg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            'Przepisy: ${widget.categoryName}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? Container(
            decoration: getDecoration(),
            child: Container(decoration: getDecoration(), child: const Center(child: CircularProgressIndicator())))
            : FutureBuilder<List<Meal>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(decoration: getDecoration(), child: const Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Container(
                  decoration: getDecoration(),
                  child: Container(decoration: getDecoration(), child: Center(child: Text('Error: ${snapshot.error}'))));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(decoration: getDecoration(), child: const Center(child: Text('Brak przepisów')));
            } else {
              final meals = snapshot.data!;
              return Container(
                decoration: getDecoration(),
                child: FadeTransition(
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
                ),
              );
            }
          },
        ),
      ),
    );
  }

  BoxDecoration getDecoration() {
    return BoxDecoration(
      image: DecorationImage(
        image: const Svg('assets/main/home_body.svg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
      ),
    );
  }
}
