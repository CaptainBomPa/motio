package com.motio.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.model.Meal
import com.motio.model.MealCategory
import com.motio.model.User
import com.motio.repository.MealCategoryRepository
import com.motio.repository.MealRepository
import com.motio.repository.UserRepository
import com.motio.service.MealCategoryService
import com.motio.service.MealService
import com.motio.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class MealControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc
    @Autowired
    MealService mealService
    @Autowired
    MealRepository mealRepository
    @Autowired
    UserService userService
    @Autowired
    UserRepository userRepository
    @Autowired
    MealCategoryService mealCategoryService
    @Autowired
    MealCategoryRepository mealCategoryRepository
    @Autowired
    ObjectMapper objectMapper

    void setup() {
        mealRepository.deleteAll()
        userRepository.deleteAll()
        mealCategoryRepository.deleteAll()
    }

    void cleanup() {
        mealRepository.deleteAll()
        userRepository.deleteAll()
        mealCategoryRepository.deleteAll()
    }

    def "test creating a meal"() {
        given: "A user, category and meal object"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")

        expect:
        mockMvc.perform(post("/meals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(meal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.createdByUser.username').value("chef123"))
                .andExpect(jsonPath('$.category.name').value("Dinner"))
                .andExpect(jsonPath('$.steps[0]').value("Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Ingredient 1"))
                .andExpect(jsonPath('$.imageUrl').value("http://example.com/image.jpg"))
    }

    def "test updating a meal"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        mealService.saveMeal(meal)

        def updatedMeal = new Meal(createdByUser: user, category: category, steps: ["Updated Step 1", "Updated Step 2"], ingredients: ["Updated Ingredient 1", "Updated Ingredient 2"], imageUrl: "http://example.com/updated_image.jpg")

        expect:
        mockMvc.perform(put("/meals/${meal.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedMeal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.steps[0]').value("Updated Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Updated Ingredient 1"))
                .andExpect(jsonPath('$.imageUrl').value("http://example.com/updated_image.jpg"))
    }

    def "test deleting a meal"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(delete("/meals/${meal.getId()}"))
                .andExpect(status().isNoContent())
    }

    def "test getting a meal by ID"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(get("/meals/${meal.getId()}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.createdByUser.username').value("chef123"))
                .andExpect(jsonPath('$.category.name').value("Dinner"))
                .andExpect(jsonPath('$.steps[0]').value("Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Ingredient 1"))
                .andExpect(jsonPath('$.imageUrl').value("http://example.com/image.jpg"))
    }

    def "test getting all meals"() {
        given: "Multiple meals"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal1 = new Meal(createdByUser: user, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image1.jpg")
        def meal2 = new Meal(createdByUser: user, category: category, steps: ["Step A", "Step B"], ingredients: ["Ingredient A", "Ingredient B"], imageUrl: "http://example.com/image2.jpg")
        mealService.saveMeal(meal1)
        mealService.saveMeal(meal2)

        expect:
        mockMvc.perform(get("/meals"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].createdByUser.username').value("chef123"))
                .andExpect(jsonPath('$[1].createdByUser.username').value("chef123"))
    }

    def "test granting access to user"() {
        given: "An existing meal and user"
        def user1 = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def user2 = new User(username: "user123", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user1)
        userService.saveUser(user2)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user1, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(post("/meals/${meal.getId()}/grantAccess/${user2.getId()}"))
                .andExpect(status().isNoContent())

        and:
        def updatedMeal = mealService.getMealById(meal.getId()).get()
        updatedMeal.getAccessibleUsers().contains(user2)
    }

    def "test revoking access from user"() {
        given: "An existing meal with access granted to user"
        def user1 = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def user2 = new User(username: "user123", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory(name: "Dinner")
        userService.saveUser(user1)
        userService.saveUser(user2)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user1, category: category, steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imageUrl: "http://example.com/image.jpg")
        meal.getAccessibleUsers().add(user2)
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(post("/meals/${meal.getId()}/revokeAccess/${user2.getId()}"))
                .andExpect(status().isNoContent())

        and:
        def updatedMeal = mealService.getMealById(meal.getId()).get()
        !updatedMeal.getAccessibleUsers().contains(user2)
    }
}
