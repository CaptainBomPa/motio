package com.motio.core.config.dev.impl;

import com.motio.commons.model.Role;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import com.motio.core.config.dev.ModelInitializer;
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
            new User(null, "gordon", "Gordon", "Ramsay", "securepassword123", "gordon.ramsay@example.com", Role.USER),
            new User(null, "user", "John", "Doe", "securepassword123", "john.doe@example.com", Role.USER),
            new User(null, "bompa", "Filip", "Mróz", "securepassword123", "filip.mroz@example.com", Role.USER),
            new User(null, "random", "Random", "Man", "securepassword123", "random.man@example.com", Role.USER),
            new User(null, "snow", "Jon", "Snow", "securepassword123", "jon.snow@example.com", Role.USER)
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
