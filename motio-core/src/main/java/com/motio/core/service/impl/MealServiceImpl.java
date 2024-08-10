package com.motio.core.service.impl;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.Meal;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.core.repository.MealRepository;
import com.motio.core.service.MealService;
import com.motio.core.service.util.ImageSaveUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
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
        Path path = Paths.get(IMAGES_DIRECTORY, username, mealName.replaceAll("\\s+", "_"));
        return ImageSaveUtil.saveImage(file, path.toString());
    }
}
