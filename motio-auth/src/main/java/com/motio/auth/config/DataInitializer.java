package com.motio.auth.config;

import com.motio.commons.model.Role;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.commons.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {
    private final UserService userService;
    private final UserRepository userRepository;

    @Value("${initialize.admin.user.ifNotExists}")
    private boolean initializeAdminUserIfNotExists;

    @Bean
    CommandLineRunner initData() {
        if (initializeAdminUserIfNotExists) {
            return args -> {
                if (userRepository.findByUsername("motio-admin").isEmpty()) {
                    final User adminUser = User.builder()
                            .username("motio-admin")
                            .password("securepassword123")
                            .firstName("Filip")
                            .lastName("Mróz")
                            .email("filip.mroz12@gmail.com")
                            .role(Role.ADMIN)
                            .build();
                    userService.saveUser(adminUser);
                }
            };
        }
        return args -> {
        };
    }
}
