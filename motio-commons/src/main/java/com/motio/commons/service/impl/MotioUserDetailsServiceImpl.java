package com.motio.commons.service.impl;

import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.commons.service.MotioUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MotioUserDetailsServiceImpl implements MotioUserDetailsService {
    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isEmpty()) {
            throw new UserNotFoundException(username);
        }
        return user.get();
    }
}
