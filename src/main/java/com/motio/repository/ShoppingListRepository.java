package com.motio.repository;

import com.motio.model.ShoppingList;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShoppingListRepository extends JpaRepository<ShoppingList, Long> {

    @Cacheable(value = "shoppingLists", key = "#id")
    Optional<ShoppingList> findById(Long id);

    @CachePut(value = "shoppingLists", key = "#result.id")
    @Override
    <S extends ShoppingList> S save(S entity);

    @CacheEvict(value = "shoppingLists", key = "#entity.id")
    @Override
    void delete(ShoppingList entity);
}
