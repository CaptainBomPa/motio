import 'dart:io';

import 'package:flutter/material.dart';

import '../models/meal_category.dart';
import '../screens/meals_screen.dart';
import '../services/meal_category_service.dart';

class CategoryTile extends StatelessWidget {
  final MealCategory category;
  final MealCategoryService mealCategoryService = MealCategoryService();

  CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealsScreen(categoryName: category.name),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            children: [
              // Tło z obrazem z gradientem
              FutureBuilder<File?>(
                future: mealCategoryService.getImageFile(category.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 100,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Container(
                      height: 100,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      alignment: Alignment.center,
                      child: Icon(Icons.error, color: isDarkMode ? Colors.white : Colors.black),
                    );
                  } else {
                    final imageFile = snapshot.data!;
                    return Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Colors.transparent, Colors.black],
                                stops: [0.1, 1.0],
                                begin: Alignment.centerLeft,
                                end: Alignment.center,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 3 / 4,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              Container(
                color: isDarkMode ? Colors.grey[800]!.withOpacity(0.2) : Colors.grey[200]!.withOpacity(0.2),
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  category.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}