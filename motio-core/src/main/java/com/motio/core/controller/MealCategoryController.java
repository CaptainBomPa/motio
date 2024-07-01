package com.motio.core.controller;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.commons.model.MealCategory;
import com.motio.core.service.MealCategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/mealCategories")
@RequiredArgsConstructor
@Tag(name = "Meal Category Management System", description = "Operations pertaining to meal categories in Meal Category Management System")
public class MealCategoryController {
    private final MealCategoryService mealCategoryService;

    @PostMapping
    @Operation(summary = "Create a new meal category", description = "Create a new meal category in the system", tags = {"Meal Category Management System"})
    public ResponseEntity<MealCategory> createMealCategory(@RequestBody MealCategory mealCategory) {
        MealCategory createdCategory = mealCategoryService.saveMealCategory(mealCategory);
        return ResponseEntity.ok(createdCategory);
    }

    @PutMapping("/{name}")
    @Operation(summary = "Update an existing meal category", description = "Update the details of an existing meal category", tags = {"Meal Category Management System"})
    public ResponseEntity<MealCategory> updateMealCategory(@PathVariable String name, @RequestBody MealCategory mealCategory) {
        MealCategory updatedCategory = mealCategoryService.updateMealCategory(name, mealCategory);
        return ResponseEntity.ok(updatedCategory);
    }

    @PostMapping("/{name}/image")
    @Operation(summary = "Upload an image for a meal category", description = "Upload an image for a specific meal category", tags = {"Meal Category Management System"})
    public ResponseEntity<MealCategory> uploadImage(@PathVariable String name, @RequestParam("file") MultipartFile file) throws IOException, ImageProcessingException, MetadataException {
        String filePath = mealCategoryService.saveImage(file, name);
        MealCategory category = mealCategoryService.getMealCategoryByName(name)
                .orElseThrow(() -> new RuntimeException("Meal category not found"));
        category.setImagePath(filePath);
        MealCategory updatedCategory = mealCategoryService.saveMealCategory(category);
        return ResponseEntity.ok(updatedCategory);
    }

    @DeleteMapping("/{name}")
    @Operation(summary = "Delete a meal category", description = "Delete a meal category from the system", tags = {"Meal Category Management System"})
    public ResponseEntity<Void> deleteMealCategory(@PathVariable String name) {
        mealCategoryService.deleteMealCategory(name);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{name}")
    @Operation(summary = "Get a meal category by name", description = "Retrieve a meal category by its name", tags = {"Meal Category Management System"})
    public ResponseEntity<MealCategory> getMealCategoryByName(@PathVariable String name) {
        Optional<MealCategory> mealCategory = mealCategoryService.getMealCategoryByName(name);
        return mealCategory.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    @Operation(summary = "Get all meal categories", description = "Retrieve a list of all meal categories", tags = {"Meal Category Management System"})
    public ResponseEntity<List<MealCategory>> getAllMealCategories() {
        List<MealCategory> mealCategories = mealCategoryService.getAllMealCategories();
        return ResponseEntity.ok(mealCategories);
    }
}
