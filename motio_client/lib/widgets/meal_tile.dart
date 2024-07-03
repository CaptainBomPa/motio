import 'dart:io';

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../screens/meal_detail_screen.dart';
import '../services/meal_service.dart';

class MealTile extends StatelessWidget {
  final Meal meal;
  final MealService mealService = MealService();

  MealTile({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          onTap: () {
            mealService.getImageFile(meal.id.toString()).then((imageFile) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MealDetailScreen(meal: meal, imageFile: imageFile),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            }).catchError((error) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MealDetailScreen(meal: meal, imageFile: null),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            });
          },

          child: Container(
            height: 150,
            child: FutureBuilder<File?>(
              future: mealService.getImageFile(meal.id.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(Icons.image_not_supported, color: isDarkMode ? Colors.white : Colors.black, size: 50),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey[200]!.withOpacity(0.7),
                          alignment: Alignment.center,
                          child: Text(
                            meal.mealName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  final imageFile = snapshot.data!;
                  return Hero(
                    tag: 'mealImage_${meal.id}',
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0),
                            ),
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey[200]!.withOpacity(0.7),
                            alignment: Alignment.center,
                            child: Text(
                              meal.mealName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
