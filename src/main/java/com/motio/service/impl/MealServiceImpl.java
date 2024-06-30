package com.motio.service.impl;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.exception.throwable.GenericObjectNotFoundException;
import com.motio.exception.throwable.UserNotFoundException;
import com.motio.model.Meal;
import com.motio.model.User;
import com.motio.repository.MealRepository;
import com.motio.repository.UserRepository;
import com.motio.service.MealService;
import com.motio.service.util.ImageSaveUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MealServiceImpl implements MealService {
    private final MealRepository mealRepository;
    private final UserRepository userRepository;
    private static final String IMAGES_DIRECTORY = "img/meals";

    @Override
    public Meal saveMeal(Meal meal) {
        return mealRepository.save(meal);
    }

    @Override
    public Meal updateMeal(Long id, Meal meal) {
        return mealRepository.findById(id).map(existingMeal -> {
            existingMeal.setCategories(meal.getCategories());
            existingMeal.setSteps(meal.getSteps());
            existingMeal.setIngredients(meal.getIngredients());
            existingMeal.setImagePath(meal.getImagePath());
            return mealRepository.save(existingMeal);
        }).orElseThrow(() -> new GenericObjectNotFoundException(Meal.class));
    }

    @Override
    public void deleteMeal(Long id) {
        mealRepository.deleteById(id);
    }

    @Override
    public Meal getMealById(Long id) {
        return mealRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(Meal.class));
    }

    @Override
    public List<Meal> getAllMeals() {
        return mealRepository.findAll();
    }

    @Override
    public void grantAccessToUser(Long mealId, Long userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new GenericObjectNotFoundException(Meal.class));
        User user = userRepository.findById(userId)
                .orElseThrow(UserNotFoundException::new);
        meal.getAccessibleUsers().add(user);
        mealRepository.save(meal);
    }

    @Override
    public void revokeAccessFromUser(Long mealId, Long userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new GenericObjectNotFoundException(Meal.class));
        User user = userRepository.findById(userId)
                .orElseThrow(UserNotFoundException::new);
        meal.getAccessibleUsers().remove(user);
        mealRepository.save(meal);
    }

    @Override
    public List<Meal> getMealsByCategoryAndUser(String categoryName, Long userId) {
        return mealRepository.findByCategoryAndUser(categoryName, userId);
    }

    @Override
    public String saveImage(MultipartFile file, String username, String mealName) throws IOException, ImageProcessingException, MetadataException {
        return ImageSaveUtil.saveImage(file, IMAGES_DIRECTORY + "/" + username + "/" + mealName);
    }
}
