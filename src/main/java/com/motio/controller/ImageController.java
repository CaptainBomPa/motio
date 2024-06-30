package com.motio.controller;

import com.motio.model.Meal;
import com.motio.model.MealCategory;
import com.motio.service.ImageService;
import com.motio.service.MealCategoryService;
import com.motio.service.MealService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
@RequestMapping("/images")
@RequiredArgsConstructor
@Tag(name = "Image Management System", description = "Operations pertaining to images in the system")
public class ImageController {
    private final ImageService imageService;
    private final MealService mealService;
    private final MealCategoryService mealCategoryService;

    @GetMapping("/meals/{id}")
    @Operation(summary = "Get the image of a meal", description = "Retrieve the image of a meal by its ID", tags = {"Image Management System"})
    public ResponseEntity<Resource> getMealImage(@PathVariable Long id) throws IOException {
        Meal meal = mealService.getMealById(id);
        Resource imageResource = imageService.loadImage(meal.getImagePath());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + imageResource.getFilename() + "\"")
                .body(imageResource);
    }

    @GetMapping("/mealCategories/{name}")
    @Operation(summary = "Get the image of a meal category", description = "Retrieve the image of a meal category by its name", tags = {"Image Management System"})
    public ResponseEntity<Resource> getMealCategoryImage(@PathVariable String name) throws IOException {
        MealCategory mealCategory = mealCategoryService.getMealCategoryByName(name)
                .orElseThrow(() -> new RuntimeException("Meal category not found"));

        Resource imageResource = imageService.loadImage(mealCategory.getImagePath());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + imageResource.getFilename() + "\"")
                .body(imageResource);
    }
}
