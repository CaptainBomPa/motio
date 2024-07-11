package com.motio.core.service;

import com.motio.commons.model.TodoItem;
import com.motio.commons.model.TodoList;
import org.springframework.security.core.Authentication;

import java.util.List;

public interface TodoListService {
    TodoList saveTodoList(TodoList todoList, String username);

    TodoList updateTodoList(Long id, TodoList todoList);

    void deleteTodoList(Long id);

    TodoList getTodoListById(Long id);

    List<TodoList> getAllTodoLists(Authentication authentication);

    TodoList updateItemsInTodoList(Long todoListId, List<TodoItem> items);
}
