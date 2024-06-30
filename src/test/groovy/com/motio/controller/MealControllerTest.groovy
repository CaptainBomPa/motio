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
import org.springframework.mock.web.MockMultipartFile
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import java.nio.file.Paths

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
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)

        expect:
        mockMvc.perform(post("/meals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(meal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.createdByUser.username').value("chef123"))
                .andExpect(jsonPath('$.categories[0].name').value("Dinner"))
                .andExpect(jsonPath('$.steps[0]').value("Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Ingredient 1"))
                .andExpect(jsonPath('$.imagePath').doesNotExist())
    }

    def "test uploading an image for a meal"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)
        mealService.saveMeal(meal)

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "image.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "test image content".getBytes()
        )

        expect:
        def response = mockMvc.perform(multipart("/meals/${meal.getId()}/image")
                .file(file)
                .contentType(MediaType.MULTIPART_FORM_DATA))
                .andExpect(status().isOk())
                .andReturn()

        def jsonResponse = response.getResponse().getContentAsString()
        def responseObject = objectMapper.readValue(jsonResponse, Meal)
        def expectedPath = Paths.get("img", "meals", "chef123", "Pasta", "image.jpg").toString()
        assert responseObject.imagePath.endsWith(expectedPath)
    }

    def "test updating a meal"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)
        mealService.saveMeal(meal)

        def updatedMeal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Updated Step 1", "Updated Step 2"], ingredients: ["Updated Ingredient 1", "Updated Ingredient 2"], imagePath: null)

        expect:
        mockMvc.perform(put("/meals/${meal.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedMeal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.steps[0]').value("Updated Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Updated Ingredient 1"))
                .andExpect(jsonPath('$.imagePath').doesNotExist())
    }

    def "test updating a meal image"() {
        given: "An existing meal with an image"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: "img/meals/chef123/Pasta/image.jpg")
        mealService.saveMeal(meal)

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "updated_image.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "updated test image content".getBytes()
        )

        expect:
        def response = mockMvc.perform(multipart("/meals/${meal.getId()}/image")
                .file(file)
                .contentType(MediaType.MULTIPART_FORM_DATA))
                .andExpect(status().isOk())
                .andReturn()

        def jsonResponse = response.getResponse().getContentAsString()
        def responseObject = objectMapper.readValue(jsonResponse, Meal)
        def expectedPath = Paths.get("img", "meals", "chef123", "Pasta", "updated_image.jpg").toString()
        assert responseObject.imagePath.endsWith(expectedPath)
    }

    def "test deleting a meal"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(delete("/meals/${meal.getId()}"))
                .andExpect(status().isNoContent())
    }

    def "test getting a meal by ID"() {
        given: "An existing meal"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: "img/meals/chef123/Pasta/image.jpg")
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(get("/meals/${meal.getId()}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.createdByUser.username').value("chef123"))
                .andExpect(jsonPath('$.categories[0].name').value("Dinner"))
                .andExpect(jsonPath('$.steps[0]').value("Step 1"))
                .andExpect(jsonPath('$.ingredients[0]').value("Ingredient 1"))
                .andExpect(jsonPath('$.imagePath').value("img/meals/chef123/Pasta/image.jpg"))
    }

    def "test getting all meals"() {
        given: "Multiple meals"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user)
        mealCategoryService.saveMealCategory(category)
        def meal1 = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: "img/meals/chef123/Pasta/image1.jpg")
        def meal2 = new Meal(createdByUser: user, mealName: "Pasta", categories: [category], steps: ["Step A", "Step B"], ingredients: ["Ingredient A", "Ingredient B"], imagePath: "img/meals/chef123/Pasta/image2.jpg")
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
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user1)
        userService.saveUser(user2)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user1, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(post("/meals/${meal.getId()}/grantAccess/${user2.getId()}"))
                .andExpect(status().isNoContent())

        and:
        def updatedMeal = mealService.getMealById(meal.getId())
        updatedMeal.getAccessibleUsers().contains(user2)
    }

    def "test revoking access from user"() {
        given: "An existing meal with access granted to user"
        def user1 = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        def user2 = new User(username: "user123", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def category = new MealCategory("Dinner", "http://example.org")
        userService.saveUser(user1)
        userService.saveUser(user2)
        mealCategoryService.saveMealCategory(category)
        def meal = new Meal(createdByUser: user1, mealName: "Pasta", categories: [category], steps: ["Step 1", "Step 2"], ingredients: ["Ingredient 1", "Ingredient 2"], imagePath: null)
        meal.getAccessibleUsers().add(user2)
        mealService.saveMeal(meal)

        expect:
        mockMvc.perform(post("/meals/${meal.getId()}/revokeAccess/${user2.getId()}"))
                .andExpect(status().isNoContent())

        and:
        def updatedMeal = mealService.getMealById(meal.getId())
        !updatedMeal.getAccessibleUsers().contains(user2)
    }
}
