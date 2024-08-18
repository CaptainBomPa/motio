package com.motio.core.service.impl;

import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.TodoItem;
import com.motio.commons.model.TodoList;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.core.repository.TodoItemRepository;
import com.motio.core.repository.TodoListRepository;
import com.motio.core.service.TodoListService;
import com.motio.core.service.notification.TodoListNotificationSender;
import com.motio.core.service.sender.TodoListUpdateSender;
import jakarta.annotation.Nullable;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TodoListServiceImpl implements TodoListService {
    private final TodoListRepository todoListRepository;
    private final TodoItemRepository todoItemRepository;
    private final UserRepository userRepository;
    private final TodoListUpdateSender updateSender;
    private final TodoListNotificationSender todoListNotificationSender;

    @Override
    public TodoList saveTodoList(TodoList todoList, String username) {
        User user = userRepository.findByUsername(username).orElseThrow(UserNotFoundException::new);
        todoList.setCreatedByUser(user);
        sendNotifications(todoList, null);
        return todoListRepository.save(todoList);
    }

    @Override
    public TodoList updateTodoList(Long id, TodoList todoList) {
        TodoList actualList = todoListRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(TodoList.class));
        TodoList copyList = actualList.createCopy();
        actualList.setListName(todoList.getListName());
        actualList.setItems(todoList.getItems());
        actualList.setAccessibleUsers(todoList.getAccessibleUsers());
        TodoList updatedList = todoListRepository.save(actualList);

        updateSender.sendUpdate(updatedList);
        sendNotifications(updatedList, copyList);

        return updatedList;
    }

    @Override
    public void deleteTodoList(Long id) {
        todoListRepository.deleteById(id);
    }

    @Override
    public TodoList getTodoListById(Long id) {
        return todoListRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(TodoList.class));
    }

    @Override
    public List<TodoList> getAllTodoLists(Authentication authentication) {
        final User user = userRepository.findByUsername(authentication.getName()).orElseThrow(UserNotFoundException::new);
        return todoListRepository.findAll().stream()
                .filter(todoList -> todoList.getCreatedByUser().equals(user) || todoList.getAccessibleUsers().contains(user))
                .toList();
    }

    @Override
    public TodoList updateItemsInTodoList(Long todoListId, List<TodoItem> items) {
        TodoList todoList = getTodoListById(todoListId);
        TodoList copyList = todoList.createCopy();
        todoList.getItems().clear();
        todoList.getItems().addAll(items);
        todoItemRepository.saveAll(items);
        TodoList updatedList = todoListRepository.save(todoList);
        updateSender.sendUpdate(updatedList);
        sendNotifications(todoList, copyList);
        return updatedList;
    }

    private void sendNotifications(TodoList newTodoList, @Nullable TodoList previousTodoList) {
        Collection<User> users = getNewSharedUsers(newTodoList, previousTodoList);
        for (User user : users) {
            todoListNotificationSender.sendAddNewSharedUsers(newTodoList, user);
        }
    }

    private Collection<User> getNewSharedUsers(TodoList newTodoList, @Nullable TodoList previousTodoList) {
        if (previousTodoList == null) {
            return newTodoList.getAccessibleUsers();
        }
        Collection<User> newUsers = new LinkedList<>();
        newTodoList.getAccessibleUsers().forEach(user -> {
            if (!previousTodoList.getAccessibleUsers().contains(user)) {
                newUsers.add(user);
            }
        });
        return newUsers;
    }
}
