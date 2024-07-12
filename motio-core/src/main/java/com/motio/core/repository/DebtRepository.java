package com.motio.core.repository;

import com.motio.commons.model.Debt;
import com.motio.commons.model.User;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DebtRepository extends JpaRepository<Debt, Long> {

    boolean existsByUser1AndUser2(User user1, User user2);

    @Cacheable(value = "debts", key = "#id")
    Optional<Debt> findById(Long id);

    @CachePut(value = "debts", key = "#result.id")
    @Override
    <S extends Debt> S save(S entity);

    @CacheEvict(value = "debts", key = "#entity.id")
    @Override
    void delete(Debt entity);
}
