package com.motio.commons.service.impl;

import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.Role;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.commons.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder();

    @Override
    public User saveUser(User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    @Override
    public User updateUser(Long id, User user) {
        return userRepository.findById(id).map(existingUser -> {
            existingUser.setUsername(user.getUsername());
            existingUser.setFirstName(user.getFirstName());
            existingUser.setLastName(user.getLastName());
            existingUser.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
            existingUser.setEmail(user.getEmail());
            return userRepository.save(existingUser);
        }).orElseThrow(UserNotFoundException::new);
    }

    @Override
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    @Override
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll().stream().filter(user -> user.getRole().equals(Role.USER)).toList();
    }

    @Override
    public User getUserByAuthentication(Authentication authentication) {
        return getUserByUsername(authentication.getName()).orElseThrow(UserNotFoundException::new);
    }
}
