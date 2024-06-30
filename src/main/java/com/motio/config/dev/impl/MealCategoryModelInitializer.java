package com.motio.config.dev.impl;

import com.motio.config.dev.ModelInitializer;
import com.motio.model.MealCategory;
import com.motio.service.MealCategoryService;
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
            new MealCategory("Meksykańskie", null),
            new MealCategory("Włoskie", null),
            new MealCategory("Słodkie", null),
            new MealCategory("Placki", null),
            new MealCategory("Napoje", null),
            new MealCategory("Przekąski", null),
            new MealCategory("Fast Food", null)
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
