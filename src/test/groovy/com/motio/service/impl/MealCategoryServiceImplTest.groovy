package com.motio.service.impl

import com.motio.model.MealCategory
import com.motio.repository.MealCategoryRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import spock.lang.Specification

@DataJpaTest
class MealCategoryServiceImplTest extends Specification {

    @Autowired
    MealCategoryRepository mealCategoryRepository
    MealCategoryServiceImpl mealCategoryService

    void setup() {
        mealCategoryService = new MealCategoryServiceImpl(mealCategoryRepository)
    }

    def "should save meal category"() {
        given:
        MealCategory mealCategory = new MealCategory("Breakfast", "http://example.org")

        when:
        MealCategory savedCategory = mealCategoryService.saveMealCategory(mealCategory)

        then:
        savedCategory != null
        savedCategory.getName() == "Breakfast"
    }

    def "should update meal category"() {
        given:
        MealCategory existingCategory = new MealCategory("Lunch", "http://example.org")
        mealCategoryRepository.save(existingCategory)
        MealCategory updatedCategory = new MealCategory("Brunch", "http://example.org")

        when:
        MealCategory result = mealCategoryService.updateMealCategory("Lunch", updatedCategory)

        then:
        result != null
        result.getName() == "Brunch"
    }

    def "should delete meal category"() {
        given:
        MealCategory mealCategory = new MealCategory("Snack", "http://example.org")
        mealCategoryRepository.save(mealCategory)

        when:
        mealCategoryService.deleteMealCategory("Snack")

        then:
        mealCategoryRepository.findById("Snack").isEmpty()
    }

    def "should get meal category by name"() {
        given:
        MealCategory mealCategory = new MealCategory("Dessert", "http://example.org")
        mealCategoryRepository.save(mealCategory)

        when:
        Optional<MealCategory> result = mealCategoryService.getMealCategoryByName("Dessert")

        then:
        result.isPresent()
        result.get().getName() == "Dessert"
    }

    def "should get all meal categories"() {
        given:
        MealCategory category1 = new MealCategory("Breakfast", "http://example.org")
        MealCategory category2 = new MealCategory("Lunch", "http://example.org")
        mealCategoryRepository.saveAll([category1, category2])

        when:
        List<MealCategory> result = mealCategoryService.getAllMealCategories()

        then:
        result.size() == 2
        result.containsAll([category1, category2])
    }
}
