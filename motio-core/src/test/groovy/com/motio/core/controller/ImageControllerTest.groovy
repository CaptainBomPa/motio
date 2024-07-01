package com.motio.core.controller

import com.motio.commons.model.Meal
import com.motio.commons.model.MealCategory
import com.motio.commons.model.User
import com.motio.commons.service.UserService
import com.motio.core.repository.MealCategoryRepository
import com.motio.core.repository.MealRepository
import com.motio.core.service.ImageService
import com.motio.core.service.MealCategoryService
import com.motio.core.service.MealService
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
