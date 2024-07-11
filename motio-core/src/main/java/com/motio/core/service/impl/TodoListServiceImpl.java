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
import com.motio.core.service.sender.TodoListUpdateSender;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TodoListServiceImpl implements TodoListService {
    private final TodoListRepository todoListRepository;
    private final TodoItemRepository todoItemRepository;
    private final UserRepository userRepository;
    private final TodoListUpdateSender updateSender;

    @Override
    public TodoList saveTodoList(TodoList todoList, String username) {
        User user = userRepository.findByUsername(username).orElseThrow(UserNotFoundException::new);
        todoList.setCreatedByUser(user);
        return todoListRepository.save(todoList);
    }

    @Override
    public TodoList updateTodoList(Long id, TodoList todoList) {
        TodoList updatedList = todoListRepository.findById(id).map(existingList -> {
            existingList.setListName(todoList.getListName());
            existingList.setItems(todoList.getItems());
            existingList.setAccessibleUsers(todoList.getAccessibleUsers());
            return todoListRepository.save(existingList);
        }).orElseThrow(() -> new GenericObjectNotFoundException(TodoList.class));

        updateSender.sendUpdate(updatedList);

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
        todoList.getItems().clear();
        todoList.getItems().addAll(items);
        todoItemRepository.saveAll(items);
        TodoList updatedList = todoListRepository.save(todoList);
        updateSender.sendUpdate(updatedList);
        return updatedList;
    }
}
