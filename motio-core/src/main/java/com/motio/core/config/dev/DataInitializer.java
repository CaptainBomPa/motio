package com.motio.core.config.dev;

import com.motio.commons.model.MealCategory;
import com.motio.commons.model.User;
import com.motio.core.config.dev.impl.*;
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
    CommandLineRunner initData(UserModelInitializer userModelInitializer, MealCategoryModelInitializer mealCategoryModelInitializer,
                               MealModelInitializer mealModelInitializer, TodoListItemModelInitializer todoListModelInitializer,
                               DebtModelInitializer debtModelInitializer, EventModelInitializer eventModelInitializer) {
        if (initializeMockData) {
            return args -> {
                Collection<User> users = userModelInitializer.initializeObjects();
                Collection<MealCategory> mealCategories = mealCategoryModelInitializer.initializeObjects();

                mealModelInitializer.addContextObjects(users, User.class);
                mealModelInitializer.addContextObjects(mealCategories, MealCategory.class);
                mealModelInitializer.initializeObjects();
                todoListModelInitializer.initializeObjects();

                debtModelInitializer.addContextObjects(users, User.class);
                debtModelInitializer.initializeObjects();

                eventModelInitializer.addContextObjects(users, User.class);
                eventModelInitializer.initializeObjects();
            };
        }
        return args -> {
        };
    }
}
