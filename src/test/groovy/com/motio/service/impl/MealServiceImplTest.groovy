package com.motio.service.impl

import com.motio.model.Meal
import com.motio.model.MealCategory
import com.motio.model.User
import com.motio.repository.MealRepository
import com.motio.repository.UserRepository
import com.motio.service.MealService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import spock.lang.Specification

@DataJpaTest
class MealServiceImplTest extends Specification {

    @Autowired
    MealRepository mealRepository

    @Autowired
    UserRepository userRepository

    @Autowired
    TestEntityManager entityManager

    MealService mealService

    void setup() {
        mealService = new MealServiceImpl(mealRepository, userRepository)
    }

    def "should save meal"() {
        given:
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")

        when:
        Meal savedMeal = mealService.saveMeal(meal)

        then:
        savedMeal != null
        savedMeal.getId() != null
        savedMeal.getCreatedByUser().getUsername() == "chef123"
    }

    def "should update meal"() {
        given:
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        entityManager.persistAndFlush(meal)
        def updatedMeal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Updated Step 1", "Updated Step 2"], ingredients: ["Updated Ingredient 1", "Updated Ingredient 2"], imageUrl: "http://example.com/updated_image.jpg")

        when:
        Meal result = mealService.updateMeal(meal.getId(), updatedMeal)

        then:
        result != null
        result.getSteps() == ["Updated Step 1", "Updated Step 2"]
        result.getIngredients() == ["Updated Ingredient 1", "Updated Ingredient 2"]
        result.getImageUrl() == "http://example.com/updated_image.jpg"
    }

    def "should delete meal"() {
        given:
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        entityManager.persistAndFlush(meal)

        when:
        mealService.deleteMeal(meal.getId())

        then:
        mealRepository.findById(meal.getId()).isEmpty()
    }

    def "should get meal by ID"() {
        given:
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        entityManager.persistAndFlush(meal)

        when:
        Optional<Meal> result = mealService.getMealById(meal.getId())

        then:
        result.isPresent()
        result.get().getId() == meal.getId()
    }

    def "should get all meals"() {
        given:
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user)
        entityManager.persistAndFlush(category)
        def meal1 = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image1.jpg")
        def meal2 = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step A", "Step B"], ingredients: ["Ingredient A", "Ingredient B"], imageUrl: "http://example.com/image2.jpg")
        entityManager.persistAndFlush(meal1)
        entityManager.persistAndFlush(meal2)

        when:
        List<Meal> result = mealService.getAllMeals()

        then:
        result.size() == 2
        result.containsAll([meal1, meal2])
    }

    def "should grant access to user"() {
        given:
        def user1 = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def user2 = new User(username: "user123", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user1, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        entityManager.persistAndFlush(meal)

        when:
        mealService.grantAccessToUser(meal.getId(), user2.getId())

        then:
        meal.getAccessibleUsers().contains(user2)
    }

    def "should revoke access from user"() {
        given:
        def user1 = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def user2 = new User(username: "user123", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        entityManager.persistAndFlush(category)
        def meal = new Meal(createdByUser: user1, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        meal.getAccessibleUsers().add(user2)
        entityManager.persistAndFlush(meal)

        when:
        mealService.revokeAccessFromUser(meal.getId(), user2.getId())

        then:
        !meal.getAccessibleUsers().contains(user2)
    }
}
