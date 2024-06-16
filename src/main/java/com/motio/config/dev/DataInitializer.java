package com.motio.config.dev;

import com.motio.model.Meal;
import com.motio.model.MealCategory;
import com.motio.model.User;
import com.motio.service.MealCategoryService;
import com.motio.service.MealService;
import com.motio.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

@Configuration
public class DataInitializer {
    private static final Random random = new Random();
    private static final List<String> possibleIngredients = List.of(
            "Flour", "Sugar", "Salt", "Butter", "Milk", "Eggs", "Cheese", "Tomatoes",
            "Onions", "Garlic", "Chicken", "Beef", "Pork", "Fish", "Carrots", "Potatoes",
            "Peppers", "Olive Oil", "Basil", "Oregano", "Thyme", "Rosemary", "Lettuce",
            "Spinach", "Cucumber", "Avocado", "Corn", "Rice", "Pasta", "Beans"
    );
    private static final List<String> possibleSteps = List.of(
            "Preheat oven to 350°F (175°C)", "Mix ingredients in a bowl", "Bake for 30 minutes",
            "Stir occasionally", "Chop vegetables finely", "Grill for 10 minutes each side",
            "Simmer for 20 minutes", "Serve with a side of rice", "Garnish with fresh herbs",
            "Let it rest for 10 minutes", "Whisk until smooth", "Heat oil in a pan",
            "Combine ingredients in a blender", "Marinate meat for 2 hours", "Boil water and add pasta"
    );
    @Value("${initialize.mock.data}")
    private boolean initializeMockData;

    private static <T> List<T> getRandomElements(List<T> list, int count) {
        return random.ints(0, list.size())
                .distinct()
                .limit(count)
                .mapToObj(list::get)
                .collect(Collectors.toList());
    }

    @Bean
    CommandLineRunner initData(UserService userService, MealCategoryService mealCategoryService, MealService mealService) {
        if (initializeMockData) {
            return args -> {
                User user1 = new User(null, "admin", "Gordon", "Ramsay", "securepassword123", "gordon.ramsay@example.com");
                User user2 = new User(null, "user", "John", "Doe", "securepassword123", "john.doe@example.com");
                userService.saveUser(user1);
                userService.saveUser(user2);

                List<MealCategory> mealCategories = Stream.of(
                        "Italian", "Chinese", "Mexican", "French", "Indian", "Greek", "Japanese", "Spanish",
                        "Thai", "Moroccan", "Vietnamese", "Turkish", "Korean", "Lebanese", "German",
                        "Brazilian", "Ethiopian", "Caribbean", "Cajun", "Mediterranean"
                ).map(MealCategory::new).toList();
                mealCategories.forEach(mealCategoryService::saveMealCategory);

                IntStream.range(1, 101).forEach(i -> {
                    MealCategory category = mealCategories.get(random.nextInt(mealCategories.size()));
                    User creator = (i % 2 == 0) ? user1 : user2;
                    Set<User> accessibleUsers = new HashSet<>();
                    accessibleUsers.add((i % 2 == 0) ? user2 : user1);

                    List<String> steps = getRandomElements(possibleSteps, 4 + random.nextInt(3));
                    List<String> ingredients = getRandomElements(possibleIngredients, 4 + random.nextInt(3));
                    String imageUrl = "http://example.com/image" + i + ".jpg";

                    Meal meal = new Meal(null, creator, accessibleUsers, category, steps, ingredients, imageUrl);
                    mealService.saveMeal(meal);
                });
            };
        }
        return args -> {
        };
    }
}
