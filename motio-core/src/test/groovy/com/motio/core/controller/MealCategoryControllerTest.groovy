package com.motio.core.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.commons.model.MealCategory
import com.motio.commons.repository.UserRepository
import com.motio.commons.service.UserService
import com.motio.core.repository.MealCategoryRepository
import com.motio.core.service.MealCategoryService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.mock.web.MockMultipartFile
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Ignore
import spock.lang.Specification

import java.nio.file.Paths

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class MealCategoryControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc
    @Autowired
    MealCategoryService mealCategoryService
    @Autowired
    MealCategoryRepository mealCategoryRepository
    @Autowired
    UserService userService
    @Autowired
    UserRepository userRepository
    @Autowired
    ObjectMapper objectMapper

    void setup() {
        mealCategoryRepository.deleteAll()
        userRepository.deleteAll()
    }

    void cleanup() {
        mealCategoryRepository.deleteAll()
        userRepository.deleteAll()
    }

    def "test creating a meal category"() {
        given: "A meal category object"
        def mealCategory = new MealCategory("Breakfast", null)

        expect:
        mockMvc.perform(post("/mealCategories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealCategory)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Breakfast"))
    }

    @Ignore
    def "test uploading an image for a meal category"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Lunch", null)
        mealCategoryRepository.save(mealCategory)

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "image.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "test image content".getBytes()
        )

        expect:
        def response = mockMvc.perform(multipart("/mealCategories/Lunch/image")
                .file(file)
                .contentType(MediaType.MULTIPART_FORM_DATA))
                .andExpect(status().isOk())
                .andReturn()

        def jsonResponse = response.getResponse().getContentAsString()
        def responseObject = objectMapper.readValue(jsonResponse, MealCategory)
        def expectedPath = Paths.get("img", "meal_category", "Lunch", "image.jpg").toString()
        assert responseObject.imagePath.endsWith(expectedPath)
    }

    def "test updating a meal category"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Snack", "img/meal_category/Snack/image.jpg")
        mealCategoryRepository.save(mealCategory)
        def updatedMealCategory = new MealCategory("Snack", "img/meal_category/Snack/updated_image.jpg")

        expect:
        mockMvc.perform(put("/mealCategories/${mealCategory.name}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedMealCategory)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Snack"))
                .andExpect(jsonPath('$.imagePath').value("img/meal_category/Snack/updated_image.jpg"))
    }

    def "test deleting a meal category"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Dinner", "img/meal_category/Dinner/image.jpg")
        mealCategoryRepository.save(mealCategory)

        expect:
        mockMvc.perform(delete("/mealCategories/${mealCategory.name}"))
                .andExpect(status().isNoContent())
    }

    def "test getting a meal category by name"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Dessert", "img/meal_category/Dessert/image.jpg")
        mealCategoryRepository.save(mealCategory)

        expect:
        mockMvc.perform(get("/mealCategories/${mealCategory.name}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Dessert"))
                .andExpect(jsonPath('$.imagePath').value("img/meal_category/Dessert/image.jpg"))
    }

    def "test getting all meal categories"() {
        given: "Multiple meal categories"
        def mealCategory1 = new MealCategory("Breakfast", "img/meal_category/Breakfast/image.jpg")
        def mealCategory2 = new MealCategory("Lunch", "img/meal_category/Lunch/image.jpg")
        mealCategoryRepository.saveAll([mealCategory1, mealCategory2])

        expect:
        mockMvc.perform(get("/mealCategories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].name').value("Breakfast"))
                .andExpect(jsonPath('$[1].name').value("Lunch"))
    }
}
