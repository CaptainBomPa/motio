package com.motio.auth.service;

import com.motio.commons.model.User;
import com.motio.commons.security.dto.JwtResponse;

public interface AuthenticationService {
    User registerUser(User user);

    JwtResponse loginUser(String username, String password);

    JwtResponse loginAsAdmin(String username, String password);

    JwtResponse refreshAccessToken(String oldToken);
}
