package com.motio.config.dev.impl;

import com.motio.config.dev.ModelInitializer;
import com.motio.model.User;
import com.motio.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class UserModelInitializer implements ModelInitializer<User> {
    private final UserService userService;

    private List<User> userList = List.of(
            new User(null, "admin", "Gordon", "Ramsay", "securepassword123", "gordon.ramsay@example.com"),
            new User(null, "user", "John", "Doe", "securepassword123", "john.doe@example.com"),
            new User(null, "bompa", "Filip", "Mróz", "securepassword123", "filip.mroz@example.com")
    );

    @Override
    public Collection<User> initializeObjects() {
        List<User> loadedUsers = new LinkedList<>();
        for (User user : userList) {
            loadedUsers.add(userService.saveUser(user));
        }
        return loadedUsers;
    }

    @Override
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void destroy() {
        userList = null;
    }
}
