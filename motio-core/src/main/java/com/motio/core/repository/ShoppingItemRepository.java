package com.motio.core.repository;

import com.motio.commons.model.ShoppingItem;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, Long> {

    @Cacheable(value = "shoppingItems", key = "#id")
    Optional<ShoppingItem> findById(Long id);

    @CachePut(value = "shoppingItems", key = "#result.id")
    @Override
    <S extends ShoppingItem> S save(S entity);

    @CacheEvict(value = "shoppingItems", key = "#entity.id")
    @Override
    void delete(ShoppingItem entity);
}
