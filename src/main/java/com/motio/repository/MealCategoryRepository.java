package com.motio.repository;

import com.motio.model.MealCategory;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MealCategoryRepository extends JpaRepository<MealCategory, String> {
    @Cacheable(value = "mealCategories", key = "#name")
    Optional<MealCategory> findByName(String name);

    @CachePut(value = "mealCategories", key = "#result.name")
    @Override
    <S extends MealCategory> S save(S entity);

    @CacheEvict(value = "mealCategories", key = "#entity.name")
    @Override
    void delete(MealCategory entity);
}
