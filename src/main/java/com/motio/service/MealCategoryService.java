package com.motio.service;

import com.motio.model.MealCategory;

import java.util.List;
import java.util.Optional;

public interface MealCategoryService {
    MealCategory saveMealCategory(MealCategory mealCategory);

    MealCategory updateMealCategory(String name, MealCategory mealCategory);

    void deleteMealCategory(String name);

    Optional<MealCategory> getMealCategoryByName(String name);

    List<MealCategory> getAllMealCategories();
}
