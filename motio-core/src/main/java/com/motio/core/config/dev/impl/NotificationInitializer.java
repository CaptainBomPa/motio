package com.motio.core.config.dev.impl;

import com.motio.commons.model.NotificationMessage;
import com.motio.commons.model.TodoList;
import com.motio.commons.model.User;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.service.notification.impl.TodoListNotificationSenderImpl;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.Validate;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.List;
import java.util.Random;

@Component
@RequiredArgsConstructor
public class NotificationInitializer implements ModelInitializer<NotificationMessage> {
    private Collection<User> providedUsers;
    private Collection<TodoList> providedTodoLists;
    private static final Random random = new Random();
    private final TodoListNotificationSenderImpl todoListNotificationSender;

    @Override
    public Collection<NotificationMessage> initializeObjects() {
        Validate.notEmpty(providedUsers);
        List<User> users = List.copyOf(providedUsers);

        providedTodoLists.forEach(todoList -> {
            User user1 = users.get(random.nextInt(users.size()));
            User user2 = users.get(random.nextInt(users.size()));
            User user3 = users.get(random.nextInt(users.size()));
            todoListNotificationSender.sendAddNewSharedUsers(todoList, user1);
            todoListNotificationSender.sendAddNewSharedUsers(todoList, user2);
            todoListNotificationSender.sendAddNewSharedUsers(todoList, user3);
        });
        return List.of();
    }

    @Override
    @SuppressWarnings("unchecked")
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        if (type.isAssignableFrom(User.class)) {
            providedUsers = (Collection<User>) objects;
        } else if (type.isAssignableFrom(TodoList.class)) {
            providedTodoLists = (Collection<TodoList>) objects;
        } else {
            throw new RuntimeException("Could not apply context objects during data initialization");
        }
    }

    @Override
    public void destroy() throws Exception {

    }
}
