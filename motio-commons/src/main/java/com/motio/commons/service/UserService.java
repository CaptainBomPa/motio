package com.motio.commons.service;

import com.motio.commons.model.User;
import org.springframework.security.core.Authentication;

import java.util.List;
import java.util.Optional;

public interface UserService {
    User saveUser(User user);

    User updateUser(Long id, User user);

    void deleteUser(Long id);

    Optional<User> getUserById(Long id);

    Optional<User> getUserByUsername(String username);

    User getUserByAuthentication(Authentication authentication);

    Optional<User> getUserByEmail(String email);

    List<User> getAllUsers();

    void updateNotificationToken(String username, String token);
}
