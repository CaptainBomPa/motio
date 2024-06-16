package com.motio.repository;

import com.motio.model.User;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @Cacheable(value = "users", key = "#username")
    Optional<User> findByUsername(String username);

    @Cacheable(value = "users", key = "#email")
    Optional<User> findByEmail(String email);

    @CachePut(value = "users", key = "#result.username")
    @Override
    <S extends User> S save(S entity);

    @CacheEvict(value = "users", key = "#entity.username")
    @Override
    void delete(User entity);
}
