package com.motio.auth.controller;

import com.motio.auth.service.AuthenticationService;
import com.motio.commons.model.User;
import com.motio.commons.security.dto.JwtResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Operations pertaining to user authentication")
public class AuthenticationController {
    private final AuthenticationService authenticationService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user", description = "Register a new user in the system", tags = {"Authentication"})
    public ResponseEntity<User> registerUser(@RequestBody User user) {
        final User registeredUser = authenticationService.registerUser(user);
        return ResponseEntity.ok(registeredUser);
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate a user", description = "Authenticate a user and return a JWT token", tags = {"Authentication"})
    public ResponseEntity<JwtResponse> loginUser(@RequestBody User user) {
        final JwtResponse response = authenticationService.loginUser(user.getUsername(), user.getPassword());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Refresh JWT Token", description = "Refresh the JWT token using a refresh token", tags = {"Authentication"})
    public ResponseEntity<JwtResponse> refreshToken(@RequestBody JwtResponse request) {
        final JwtResponse response = authenticationService.refreshAccessToken(request.getRefreshToken());
        return ResponseEntity.ok(response);
    }
}
