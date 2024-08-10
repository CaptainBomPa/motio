package com.motio.core.service.impl;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.model.MealCategory;
import com.motio.core.repository.MealCategoryRepository;
import com.motio.core.service.MealCategoryService;
import com.motio.core.service.util.ImageSaveUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MealCategoryServiceImpl implements MealCategoryService {
    private final MealCategoryRepository mealCategoryRepository;
    private static final String BASE_DIRECTORY = "img/meal_category";

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
            category.setImagePath(mealCategory.getImagePath());
            return mealCategoryRepository.save(category);
        }
        throw new GenericObjectNotFoundException(MealCategory.class);
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

    @Override
    public String saveImage(MultipartFile file, String categoryName) throws IOException, ImageProcessingException, MetadataException {
        Path path = Paths.get(BASE_DIRECTORY, categoryName.replaceAll("\\s+", "_"));
        return ImageSaveUtil.saveImage(file, path.toString());
    }
}
