package com.motio.core.repository;

import com.motio.commons.model.TodoList;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TodoListRepository extends JpaRepository<TodoList, Long> {

    @Cacheable(value = "todoLists", key = "#id")
    Optional<TodoList> findById(Long id);

    @CachePut(value = "todoLists", key = "#result.id")
    @Override
    <S extends TodoList> S save(S entity);

    @CacheEvict(value = "todoLists", key = "#entity.id")
    @Override
    void delete(TodoList entity);
}
