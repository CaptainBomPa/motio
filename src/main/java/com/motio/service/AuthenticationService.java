package com.motio.service;

import com.motio.model.User;
import com.motio.security.dto.JwtResponse;

public interface AuthenticationService {
    User registerUser(User user);

    JwtResponse loginUser(String username, String password);

    JwtResponse refreshAccessToken(String oldToken);
}
