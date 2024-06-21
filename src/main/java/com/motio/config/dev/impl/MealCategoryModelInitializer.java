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
            new MealCategory("Meksykańskie", "https://i.ibb.co/F5xBSRN/mexican-food.png"),
            new MealCategory("Włoskie", "https://i.ibb.co/YD14M97/italian-food.png"),
            new MealCategory("Słodkie", "https://i.ibb.co/c179Dmb/sweet-food.png"),
            new MealCategory("Placki", "https://i.ibb.co/2ybXCtH/cake-food.png"),
            new MealCategory("Napoje", "https://i.ibb.co/hC5y74c/soda.png"),
            new MealCategory("Przekąski", "https://i.ibb.co/PMYFVSR/snacks.png"),
            new MealCategory("Fast Food", "https://i.ibb.co/mNTspZ7/fast-food.png")
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
