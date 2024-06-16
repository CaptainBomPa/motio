package com.motio.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.model.MealCategory
import com.motio.repository.MealCategoryRepository
import com.motio.service.MealCategoryService
import com.motio.service.impl.MealCategoryServiceImpl
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
class MealCategoryControllerTest extends Specification {

    @Autowired
    MockMvc mockMvc

    @Autowired
    MealCategoryRepository mealCategoryRepository

    @Autowired
    ObjectMapper objectMapper

    MealCategoryService mealCategoryService

    def setup() {
        mealCategoryRepository.deleteAll()
        mealCategoryService = new MealCategoryServiceImpl(mealCategoryRepository)
    }

    def "test creating a meal category"() {
        given: "A meal category object"
        def mealCategory = new MealCategory("Breakfast")

        expect:
        mockMvc.perform(post("/mealCategories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealCategory)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Breakfast"))
    }

    def "test updating a meal category"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Lunch")
        mealCategoryRepository.save(mealCategory)
        def updatedMealCategory = new MealCategory("Brunch")

        expect:
        mockMvc.perform(put("/mealCategories/${mealCategory.name}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedMealCategory)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Brunch"))
    }

    def "test deleting a meal category"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Snack")
        mealCategoryRepository.save(mealCategory)

        expect:
        mockMvc.perform(delete("/mealCategories/${mealCategory.name}"))
                .andExpect(status().isNoContent())
    }

    def "test getting a meal category by name"() {
        given: "An existing meal category"
        def mealCategory = new MealCategory("Dessert")
        mealCategoryRepository.save(mealCategory)

        expect:
        mockMvc.perform(get("/mealCategories/${mealCategory.name}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.name').value("Dessert"))
    }

    def "test getting all meal categories"() {
        given: "Multiple meal categories"
        def mealCategory1 = new MealCategory("Breakfast")
        def mealCategory2 = new MealCategory("Lunch")
        mealCategoryRepository.saveAll([mealCategory1, mealCategory2])

        expect:
        mockMvc.perform(get("/mealCategories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].name').value("Breakfast"))
                .andExpect(jsonPath('$[1].name').value("Lunch"))
    }
}
