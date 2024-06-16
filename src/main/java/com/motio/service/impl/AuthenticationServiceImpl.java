package com.motio.service.impl;

import com.motio.model.User;
import com.motio.repository.UserRepository;
import com.motio.security.dto.JwtResponse;
import com.motio.security.util.JwtTokenUtil;
import com.motio.service.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class AuthenticationServiceImpl implements AuthenticationService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder();
    private final JwtTokenUtil jwtTokenUtil;

    public User registerUser(User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public JwtResponse loginUser(String username, String password) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!bCryptPasswordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        return createJwtResponse(user);
    }

    private JwtResponse createJwtResponse(User user) {
        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities(new ArrayList<>())
                .build();

        String accessToken = jwtTokenUtil.generateToken(userDetails);
        String refreshToken = jwtTokenUtil.generateRefreshToken(userDetails);

        return new JwtResponse(accessToken, refreshToken);
    }

    public JwtResponse refreshAccessToken(String refreshToken) {
        String username = jwtTokenUtil.getUsernameFromToken(refreshToken);
        UserDetails userDetails = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (jwtTokenUtil.validateToken(refreshToken, userDetails)) {
            String newAccessToken = jwtTokenUtil.generateToken(userDetails);
            String newRefreshToken = refreshToken;

            Date expirationDate = jwtTokenUtil.getExpirationDateFromToken(refreshToken);
            long oneDayInMillis = 48 * 60 * 60 * 1000;
            if (expirationDate.getTime() - System.currentTimeMillis() < oneDayInMillis) {
                newRefreshToken = jwtTokenUtil.generateRefreshToken(userDetails);
            }

            return new JwtResponse(newAccessToken, newRefreshToken);
        } else {
            throw new RuntimeException("Invalid refresh token");
        }
    }
}
