package com.motio.service.impl;

import com.motio.model.MealCategory;
import com.motio.repository.MealCategoryRepository;
import com.motio.service.MealCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MealCategoryServiceImpl implements MealCategoryService {
    private final MealCategoryRepository mealCategoryRepository;

    @Override
    public MealCategory saveMealCategory(MealCategory mealCategory) {
        return mealCategoryRepository.save(mealCategory);
    }

    @Override
    public MealCategory updateMealCategory(String name, MealCategory mealCategory) {
        Optional<MealCategory> optionalMealCategory = mealCategoryRepository.findByName(name);
        if (optionalMealCategory.isPresent()) {
            MealCategory category = optionalMealCategory.get();
            category.setName(mealCategory.getName());
            category.setImageUrl(mealCategory.getImageUrl());
            return mealCategoryRepository.save(category);
        }
        throw new RuntimeException("Meal category not found");
    }

    @Override
    public void deleteMealCategory(String name) {
        mealCategoryRepository.deleteById(name);
    }

    @Override
    public Optional<MealCategory> getMealCategoryByName(String name) {
        return mealCategoryRepository.findByName(name);
    }

    @Override
    public List<MealCategory> getAllMealCategories() {
        return mealCategoryRepository.findAll();
    }
}
