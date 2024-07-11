package com.motio.core.repository;

import com.motio.commons.model.TodoItem;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TodoItemRepository extends JpaRepository<TodoItem, Long> {

    @Cacheable(value = "todoItems", key = "#id")
    Optional<TodoItem> findById(Long id);

    @CachePut(value = "todoItems", key = "#result.id")
    @Override
    <S extends TodoItem> S save(S entity);

    @CacheEvict(value = "todoItems", key = "#entity.id")
    @Override
    void delete(TodoItem entity);
}
