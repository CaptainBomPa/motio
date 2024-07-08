import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../providers/user_provider.dart';
import '../services/meal_service.dart';
import 'add_edit_meal_screen.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;
  final File? imageFile;

  MealDetailScreen({Key? key, required this.meal, this.imageFile}) : super(key: key);

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  Meal? _meal;
  File? _imageFile;
  bool _isLoading = false;
  final MealService _mealService = MealService();

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _imageFile = widget.imageFile;
  }

  Future<void> fetchMealDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMeal = await _mealService.getMealById(_meal!.id.toString());
      final updatedImageFile = await _mealService.getImageFile(_meal!.id.toString());
      setState(() {
        _meal = updatedMeal;
        _imageFile = updatedImageFile;
      });
    } catch (e) {
      print('Failed to load meal details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_meal!.mealName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (currentUser != null && _meal!.createdByUser.id == currentUser.id)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMealScreen(meal: _meal),
                  ),
                ).then((_) {
                  fetchMealDetails();
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'mealImage_${_meal!.id}',
              child: _imageFile != null
                  ? Image.file(
                _imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              )
                  : Container(
                height: 300,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported, color: isDarkMode ? Colors.white : Colors.black, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Składniki',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _meal!.ingredients.map((ingredient) => Text('- $ingredient')).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Kroki',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _meal!.steps.map((step) => Text('- $step')).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
