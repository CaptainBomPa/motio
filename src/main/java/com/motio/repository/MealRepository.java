package com.motio.repository;

import com.motio.model.Meal;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MealRepository extends JpaRepository<Meal, Long> {
    @Cacheable(value = "meals", key = "#id")
    Optional<Meal> findById(Long id);

    @CachePut(value = "meals", key = "#result.id")
    @Override
    <S extends Meal> S save(S entity);

    @CacheEvict(value = "meals", key = "#entity.id")
    @Override
    void delete(Meal entity);
}
