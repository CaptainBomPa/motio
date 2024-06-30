package com.motio.service;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.model.Meal;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface MealService {
    Meal saveMeal(Meal meal);

    Meal updateMeal(Long id, Meal meal);

    void deleteMeal(Long id);

    Meal getMealById(Long id);

    List<Meal> getAllMeals();

    void grantAccessToUser(Long mealId, Long userId);

    void revokeAccessFromUser(Long mealId, Long userId);

    List<Meal> getMealsByCategoryAndUser(String categoryName, Long userId);

    String saveImage(MultipartFile file, String username, String mealName) throws IOException, ImageProcessingException, MetadataException;
}
