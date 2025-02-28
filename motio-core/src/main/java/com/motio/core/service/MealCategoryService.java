package com.motio.core.service;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.commons.model.MealCategory;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

public interface MealCategoryService {
    MealCategory saveMealCategory(MealCategory mealCategory);

    MealCategory updateMealCategory(String name, MealCategory mealCategory);

    void deleteMealCategory(String name);

    Optional<MealCategory> getMealCategoryByName(String name);

    List<MealCategory> getAllMealCategories();

    String saveImage(MultipartFile file, String categoryName) throws IOException, ImageProcessingException, MetadataException;
}
