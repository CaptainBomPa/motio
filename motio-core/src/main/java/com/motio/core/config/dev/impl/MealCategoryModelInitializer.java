package com.motio.core.config.dev.impl;

import com.motio.commons.model.MealCategory;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.service.MealCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class MealCategoryModelInitializer implements ModelInitializer<MealCategory> {
    private final MealCategoryService mealCategoryService;

    private List<MealCategory> mealCategories = List.of(
            new MealCategory("Fast Food", "img/meal_category/Fast Food/img.png"),
            new MealCategory("Meksykańskie", "img/meal_category/Meksykańskie/img.png"),
            new MealCategory("Napoje", "img/meal_category/Napoje/img.png"),
            new MealCategory("Placki", "img/meal_category/Placki/img.png"),
            new MealCategory("Przekąski", "img/meal_category/Przekąski/img.png"),
            new MealCategory("Słodkie", "img/meal_category/Słodkie/img.png"),
            new MealCategory("Włoskie", "img/meal_category/Włoskie/img.png")
    );

    @Override
    public Collection<MealCategory> initializeObjects() {
        Collection<MealCategory> loadedMealCategories = new LinkedList<>();
        for (MealCategory mealCategory : mealCategories) {
            loadedMealCategories.add(mealCategoryService.saveMealCategory(mealCategory));
        }
        return loadedMealCategories;
    }

    @Override
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void destroy() throws Exception {
        mealCategories = null;
    }
}
