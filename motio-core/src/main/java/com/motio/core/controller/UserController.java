package com.motio.core.controller;

import com.motio.commons.dto.NotificationTokenDTO;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "User Management System", description = "Operations pertaining to users in User Management System")
public class UserController {
    private final UserService userService;

    @GetMapping("/me")
    @Operation(summary = "Return user information", description = "Return a user that send a request", tags = {"Authentication"})
    public ResponseEntity<User> getMe(Authentication authentication) {
        return ResponseEntity.ok(userService.getUserByAuthentication(authentication));
    }

    @PostMapping
    @Operation(summary = "Create a new user", description = "Create a new user in the system", tags = {"User Management System"})
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User createdUser = userService.saveUser(user);
        return ResponseEntity.ok(createdUser);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing user", description = "Update the details of an existing user", tags = {"User Management System"})
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        User updatedUser = userService.updateUser(id, user);
        return ResponseEntity.ok(updatedUser);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a user", description = "Delete a user from the system", tags = {"User Management System"})
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a user by ID", description = "Retrieve a user by their ID", tags = {"User Management System"})
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        Optional<User> user = userService.getUserById(id);
        return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    @Operation(summary = "Get all users", description = "Retrieve a list of all users", tags = {"User Management System"})
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/username/{username}")
    @Operation(summary = "Get a user by username", description = "Retrieve a user by their username", tags = {"User Management System"})
    public ResponseEntity<User> getUserByUsername(@PathVariable String username) {
        Optional<User> user = userService.getUserByUsername(username);
        return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/email/{email}")
    @Operation(summary = "Get a user by email", description = "Retrieve a user by their email", tags = {"User Management System"})
    public ResponseEntity<User> getUserByEmail(@PathVariable String email) {
        Optional<User> user = userService.getUserByEmail(email);
        return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/notification-token")
    @Operation(summary = "Update Notification Token", description = "Update Notification Token", tags = {"User Management System"})
    public ResponseEntity<Void> updateNotificationToken(@RequestBody NotificationTokenDTO notificationTokenDTO, Authentication authentication) {
        userService.updateNotificationToken(authentication.getName(), notificationTokenDTO.getNotificationToken());
        log.info("Notification token updated");
        return ResponseEntity.ok().build();
    }
}
