import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_category.dart';
import '../services/meal_category_service.dart';

class MealCategoryNotifier extends StateNotifier<List<MealCategory>> {
  final MealCategoryService _mealCategoryService;

  MealCategoryNotifier(this._mealCategoryService) : super([]) {
    _fetchMealCategories();
  }

  Future<void> _fetchMealCategories() async {
    try {
      final categories = await _mealCategoryService.fetchMealCategories();
      state = categories;
    } catch (e) {
      // Obsłuż błąd
    }
  }
}

final mealCategoryServiceProvider = Provider<MealCategoryService>((ref) {
  return MealCategoryService();
});

final mealCategoryProvider = StateNotifierProvider<MealCategoryNotifier, List<MealCategory>>((ref) {
  final service = ref.read(mealCategoryServiceProvider);
  return MealCategoryNotifier(service);
});

