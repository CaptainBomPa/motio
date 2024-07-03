import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/meal_service.dart';

final mealServiceProvider = Provider<MealService>((ref) {
  return MealService();
});
