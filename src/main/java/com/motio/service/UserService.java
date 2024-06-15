package com.motio.service;

import com.motio.model.User;

import java.util.List;
import java.util.Optional;

public interface UserService {
    User saveUser(User user);

    User updateUser(Long id, User user);

    void deleteUser(Long id);

    Optional<User> getUserById(Long id);

    Optional<User> getUserByUsername(String username);

    Optional<User> getUserByEmail(String email);

    List<User> getAllUsers();
}
