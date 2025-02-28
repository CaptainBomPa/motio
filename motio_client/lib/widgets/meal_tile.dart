import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../providers/user_provider.dart';
import '../screens/meal_detail_screen.dart';
import '../services/meal_service.dart';

class MealTile extends ConsumerWidget {
  final Meal meal;
  final MealService mealService = MealService();

  MealTile({Key? key, required this.meal}) : super(key: key);

  Future<void> _deleteMeal(BuildContext context) async {
    try {
      await mealService.deleteMeal(meal.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Przepis został usunięty.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania przepisu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider);

    return Dismissible(
      key: Key(meal.id.toString()),
      direction: currentUser != null && meal.createdByUser.id == currentUser.id
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Potwierdź usunięcie"),
              content: const Text("Czy na pewno chcesz usunąć ten przepis?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Nie"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Tak"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await _deleteMeal(context);
      },
      child: Padding(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  meal.mealName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                if (currentUser != null && meal.createdByUser.id != currentUser.id)
                                  Text(
                                    'Udostępnione przez: ${meal.createdByUser.firstName} ${meal.createdByUser.lastName}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                              ],
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    meal.mealName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  if (currentUser != null && meal.createdByUser.id != currentUser.id)
                                    Text(
                                      'Udostępnione przez: ${meal.createdByUser.firstName} ${meal.createdByUser.lastName}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                ],
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
      ),
    );
  }
}
