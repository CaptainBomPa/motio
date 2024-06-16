package com.motio.repository

import com.motio.config.CacheConfig
import com.motio.model.MealCategory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.cache.CacheManager
import org.springframework.context.annotation.Import
import spock.lang.Specification

@DataJpaTest
@Import(CacheConfig)
class MealCategoryRepositoryTest extends Specification {
    @Autowired
    MealCategoryRepository mealCategoryRepository
    @Autowired
    CacheManager cacheManager

    def "save and findByName should work correctly"() {
        given: "a new MealCategory"
        def category = new MealCategory(name: "Breakfast")

        when: "saving the category"
        mealCategoryRepository.save(category)

        then: "it can be found by name"
        def foundCategory = mealCategoryRepository.findByName("Breakfast").orElse(null)
        foundCategory != null
        foundCategory.name == "Breakfast"
    }

    def "delete should remove the category"() {
        given: "an existing MealCategory"
        def category = new MealCategory(name: "Lunch")
        mealCategoryRepository.save(category)

        when: "deleting the category"
        mealCategoryRepository.delete(category)

        then: "it should no longer be found by name"
        def foundCategory = mealCategoryRepository.findByName("Lunch").orElse(null)
        foundCategory == null
    }

    def "cache should be used for findByName"() {
        given: "an existing MealCategory"
        def category = new MealCategory(name: "Dinner")
        mealCategoryRepository.save(category)
        cacheManager.getCache("mealCategories").clear()

        when: "finding the category by name"
        def firstCall = mealCategoryRepository.findByName("Dinner").orElse(null)
        def secondCall = mealCategoryRepository.findByName("Dinner").orElse(null)

        then: "the second call should use the cache"
        firstCall != null
        secondCall != null
        firstCall == secondCall
        def cache = cacheManager.getCache("mealCategories")
        cache != null
        cache.get("Dinner") != null
    }
}
