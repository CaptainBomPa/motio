import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../providers/user_provider.dart';
import 'add_edit_meal_screen.dart';

class MealDetailScreen extends ConsumerWidget {
  final Meal meal;
  final File? imageFile;

  MealDetailScreen({Key? key, required this.meal, this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.mealName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (currentUser != null && meal.createdByUser.id == currentUser.id)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMealScreen(meal: meal),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'mealImage_${meal.id}',
              child: imageFile != null
                  ? Image.file(
                imageFile!,
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
                children: meal.ingredients.map((ingredient) => Text('- $ingredient')).toList(),
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
                children: meal.steps.map((step) => Text('- $step')).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
