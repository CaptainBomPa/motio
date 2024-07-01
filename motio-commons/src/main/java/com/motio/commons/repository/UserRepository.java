package com.motio.commons.repository;

import com.motio.commons.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    @Override
    <S extends User> S save(S entity);

    @Override
    void delete(User entity);
}
