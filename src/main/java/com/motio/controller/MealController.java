package com.motio.controller;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.model.Meal;
import com.motio.model.User;
import com.motio.service.MealService;
import com.motio.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/meals")
@RequiredArgsConstructor
@Tag(name = "Meal Management System", description = "Operations pertaining to meals in Meal Management System")
public class MealController {
    private final MealService mealService;
    private final UserService userService;

    @PostMapping
    @Operation(summary = "Create a new meal", description = "Create a new meal in the system", tags = {"Meal Management System"})
    public ResponseEntity<Meal> createMeal(@RequestBody Meal meal) {
        Meal createdMeal = mealService.saveMeal(meal);
        return ResponseEntity.ok(createdMeal);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing meal", description = "Update the details of an existing meal", tags = {"Meal Management System"})
    public ResponseEntity<Meal> updateMeal(@PathVariable Long id, @RequestBody Meal meal) {
        Meal updatedMeal = mealService.updateMeal(id, meal);
        return ResponseEntity.ok(updatedMeal);
    }

    @PostMapping("/{id}/image")
    @Operation(summary = "Upload an image for a meal", description = "Upload an image for a specific meal", tags = {"Meal Management System"})
    public ResponseEntity<Meal> uploadImage(@PathVariable Long id, @RequestParam("file") MultipartFile file) throws IOException, ImageProcessingException, MetadataException {
        Meal meal = mealService.getMealById(id);
        String filePath = mealService.saveImage(file, meal.getCreatedByUser().getUsername(), meal.getMealName());
        meal.setImagePath(filePath);
        Meal updatedMeal = mealService.saveMeal(meal);
        return ResponseEntity.ok(updatedMeal);
    }

    @PutMapping("/{id}/image")
    @Operation(summary = "Update the image of a meal", description = "Update the image of a specific meal", tags = {"Meal Management System"})
    public ResponseEntity<Meal> updateImage(@PathVariable Long id, @RequestParam("file") MultipartFile file) throws IOException, ImageProcessingException, MetadataException {
        Meal meal = mealService.getMealById(id);
        String filePath = mealService.saveImage(file, meal.getCreatedByUser().getUsername(), meal.getMealName());
        meal.setImagePath(filePath);
        Meal updatedMeal = mealService.saveMeal(meal);
        return ResponseEntity.ok(updatedMeal);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a meal", description = "Delete a meal from the system", tags = {"Meal Management System"})
    public ResponseEntity<Void> deleteMeal(@PathVariable Long id) {
        mealService.deleteMeal(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a meal by ID", description = "Retrieve a meal by its ID", tags = {"Meal Management System"})
    public ResponseEntity<Meal> getMealById(@PathVariable Long id) {
        Meal meal = mealService.getMealById(id);
        return ResponseEntity.ok(meal);
    }

    @GetMapping
    @Operation(summary = "Get all meals", description = "Retrieve a list of all meals", tags = {"Meal Management System"})
    public ResponseEntity<List<Meal>> getAllMeals() {
        List<Meal> meals = mealService.getAllMeals();
        return ResponseEntity.ok(meals);
    }

    @PostMapping("/{mealId}/grantAccess/{userId}")
    @Operation(summary = "Grant access to a meal", description = "Grant a user access to a meal", tags = {"Meal Management System"})
    public ResponseEntity<Void> grantAccessToUser(@PathVariable Long mealId, @PathVariable Long userId) {
        mealService.grantAccessToUser(mealId, userId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{mealId}/revokeAccess/{userId}")
    @Operation(summary = "Revoke access from a meal", description = "Revoke a user's access to a meal", tags = {"Meal Management System"})
    public ResponseEntity<Void> revokeAccessFromUser(@PathVariable Long mealId, @PathVariable Long userId) {
        mealService.revokeAccessFromUser(mealId, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/category/{categoryName}")
    @Operation(summary = "Get meals by category", description = "Retrieve a list of meals by category and user", tags = {"Meal Management System"})
    public ResponseEntity<List<Meal>> getMealsByCategory(@PathVariable String categoryName, @AuthenticationPrincipal UserDetails userDetails) {
        User user = userService.getUserByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        List<Meal> meals = mealService.getMealsByCategoryAndUser(categoryName, user.getId());
        return ResponseEntity.ok(meals);
    }
}
