package com.motio.controller

import com.motio.model.Meal
import com.motio.model.MealCategory
import com.motio.model.User
import com.motio.repository.MealCategoryRepository
import com.motio.repository.MealRepository
import com.motio.service.ImageService
import com.motio.service.MealCategoryService
import com.motio.service.MealService
import com.motio.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.HttpHeaders
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class ImageControllerTest extends Specification {

    @Autowired
    MockMvc mockMvc
    @Autowired
    MealService mealService
    @Autowired
    MealRepository mealRepository
    @Autowired
    MealCategoryService mealCategoryService
    @Autowired
    MealCategoryRepository mealCategoryRepository
    @Autowired
    ImageService imageService
    @Autowired
    UserService userService

    void setup() {
        mealRepository.deleteAll()
        mealCategoryRepository.deleteAll()
    }

    void cleanup() {
        mealRepository.deleteAll()
        mealCategoryRepository.deleteAll()
    }

    def "test getting meal image"() {
        given: "An existing meal with an image"
        def user = new User(username: "chef123", firstName: "Gordon", lastName: "Ramsay", password: "securepassword123", email: "gordon.ramsay@example.com")
        userService.saveUser(user)
        def meal = new Meal(mealName: "Pasta", createdByUser: user, imagePath: "src/test/resources/img/test-image.jpg")
        mealRepository.save(meal)

        expect:
        mockMvc.perform(get("/images/meals/${meal.id}"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"test-image.jpg\""))
    }

    def "test getting meal category image"() {
        given: "An existing meal category with an image"
        def mealCategory = new MealCategory(name: "Dinner", imagePath: "src/test/resources/img/test-image.jpg")
        mealCategoryRepository.save(mealCategory)

        expect:
        mockMvc.perform(get("/images/mealCategories/${mealCategory.name}"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"test-image.jpg\""))
    }
}
