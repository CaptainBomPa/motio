package com.motio.config.dev;

import com.motio.model.Meal;
import com.motio.model.MealCategory;
import com.motio.model.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Collection;

@Configuration
public class DataInitializer {

    @Value("${initialize.mock.data}")
    private boolean initializeMockData;

    @Bean
    CommandLineRunner initData(ModelInitializer<User> userModelInitializer, ModelInitializer<MealCategory> mealCategoryModelInitializer, ModelInitializer<Meal> mealModelInitializer) {
        if (initializeMockData) {
            return args -> {
                Collection<User> users = userModelInitializer.initializeObjects();
                Collection<MealCategory> mealCategories = mealCategoryModelInitializer.initializeObjects();

                mealModelInitializer.addContextObjects(users, User.class);
                mealModelInitializer.addContextObjects(mealCategories, MealCategory.class);
                Collection<Meal> meals = mealModelInitializer.initializeObjects();
            };
        }
        return args -> {
        };
    }
}
