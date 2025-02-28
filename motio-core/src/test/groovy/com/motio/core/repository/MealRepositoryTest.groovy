package com.motio.core.repository

import com.motio.commons.model.Meal
import com.motio.commons.model.MealCategory
import com.motio.commons.model.User
import com.motio.commons.repository.UserRepository
import com.motio.core.config.CacheConfig
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import org.springframework.cache.CacheManager
import org.springframework.context.annotation.Import
import spock.lang.Specification

@DataJpaTest
@Import(CacheConfig)
class MealRepositoryTest extends Specification {
    @Autowired
    MealRepository mealRepository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    MealCategoryRepository mealCategoryRepository;
    @Autowired
    TestEntityManager entityManager;
    @Autowired
    CacheManager cacheManager;

    def "test saving and finding meal by ID"() {
        given: "A user, category and meal object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory("Breakfast", "http://example.org")
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: List.of("Step 1", "Step 2"),
                ingredients: List.of("Ingredient 1", "Ingredient 2"), imagePath: "/img/meals/john_doe/2")

        when: "Saving the user, category and meal"
        userRepository.saveAndFlush(user)
        mealCategoryRepository.saveAndFlush(category)
        mealRepository.saveAndFlush(meal)

        def foundMeal = mealRepository.findById(meal.getId()).orElse(null)

        then: "The meal should be found in the repository"
        foundMeal != null
        foundMeal.getId() == meal.getId()

        when: "Fetching the meal again"
        def cachedMeal = cacheManager.getCache("meals").get(meal.getId(), Meal.class)

        then: "The meal should be cached"
        cachedMeal != null
        cachedMeal.getId() == meal.getId()
    }

    def "test caching on save and delete meal"() {
        given: "A user, category and meal object"
        def user = new User(username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "securepassword123", email: "jane.doe@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: List.of("Step 1", "Step 2"), ingredients: List.of("Ingredient 1", "Ingredient 2"), imagePath: "/img/meals/john_doe/2")

        when: "Saving the user, category and meal"
        userRepository.saveAndFlush(user)
        mealCategoryRepository.saveAndFlush(category)
        mealRepository.saveAndFlush(meal)

        //trigger cache to store data
        mealRepository.findById(meal.getId()).orElse(null)

        then: "The meal should be cached"
        def cachedMeal = cacheManager.getCache("meals").get(meal.getId(), Meal.class)
        cachedMeal != null
        cachedMeal.getId() == meal.getId()

        when: "Deleting the meal"
        mealRepository.delete(meal)

        then: "The meal should be evicted from the cache"
        def evictedMeal = cacheManager.getCache("meals").get(meal.getId(), Meal.class)
        evictedMeal == null
    }
}
