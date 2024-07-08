import 'package:motio_client/models/user.dart';

import 'meal_category.dart';

class Meal {
  int id;
  String mealName;
  User createdByUser;
  Set<User> accessibleUsers;
  Set<MealCategory> categories;
  List<String> steps;
  List<String> ingredients;
  String? imagePath; // Nullable field

  Meal({
    required this.id,
    required this.mealName,
    required this.createdByUser,
    required this.accessibleUsers,
    required this.categories,
    required this.steps,
    required this.ingredients,
    this.imagePath, // Nullable field
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      mealName: json['mealName'],
      createdByUser: User.fromJson(json['createdByUser']),
      accessibleUsers: (json['accessibleUsers'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toSet(),
      categories: (json['categories'] as List)
          .map((categoryJson) => MealCategory.fromJson(categoryJson))
          .toSet(),
      steps: List<String>.from(json['steps']),
      ingredients: List<String>.from(json['ingredients']),
      imagePath: json['imagePath'], // Nullable field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealName': mealName,
      'createdByUser': createdByUser.toJson(),
      'accessibleUsers': accessibleUsers.map((user) => user.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'steps': steps,
      'ingredients': ingredients,
      'imagePath': imagePath, // Nullable field
    };
  }
}
