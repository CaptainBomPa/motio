package com.motio.service.impl;

import com.motio.model.Meal;
import com.motio.model.User;
import com.motio.repository.MealRepository;
import com.motio.repository.UserRepository;
import com.motio.service.MealService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MealServiceImpl implements MealService {
    private final MealRepository mealRepository;
    private final UserRepository userRepository;

    @Override
    public Meal saveMeal(Meal meal) {
        return mealRepository.save(meal);
    }

    @Override
    public Meal updateMeal(Long id, Meal meal) {
        return mealRepository.findById(id).map(existingMeal -> {
            existingMeal.setCategory(meal.getCategory());
            existingMeal.setSteps(meal.getSteps());
            existingMeal.setIngredients(meal.getIngredients());
            existingMeal.setImageUrl(meal.getImageUrl());
            return mealRepository.save(existingMeal);
        }).orElseThrow(() -> new RuntimeException("Meal not found"));
    }

    @Override
    public void deleteMeal(Long id) {
        mealRepository.deleteById(id);
    }

    @Override
    public Optional<Meal> getMealById(Long id) {
        return mealRepository.findById(id);
    }

    @Override
    public List<Meal> getAllMeals() {
        return mealRepository.findAll();
    }

    @Override
    public void grantAccessToUser(Long mealId, Long userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new RuntimeException("Meal not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        meal.getAccessibleUsers().add(user);
        mealRepository.save(meal);
    }

    @Override
    public void revokeAccessFromUser(Long mealId, Long userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new RuntimeException("Meal not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        meal.getAccessibleUsers().remove(user);
        mealRepository.save(meal);
    }
}
