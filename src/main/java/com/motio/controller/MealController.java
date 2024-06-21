package com.motio.controller;

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

import java.util.List;
import java.util.Optional;

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

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a meal", description = "Delete a meal from the system", tags = {"Meal Management System"})
    public ResponseEntity<Void> deleteMeal(@PathVariable Long id) {
        mealService.deleteMeal(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a meal by ID", description = "Retrieve a meal by its ID", tags = {"Meal Management System"})
    public ResponseEntity<Meal> getMealById(@PathVariable Long id) {
        Optional<Meal> meal = mealService.getMealById(id);
        return meal.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
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
