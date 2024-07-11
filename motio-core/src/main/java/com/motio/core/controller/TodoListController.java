package com.motio.core.controller;

import com.motio.commons.model.TodoItem;
import com.motio.commons.model.TodoList;
import com.motio.core.service.TodoListService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/todo-lists")
@RequiredArgsConstructor
@Tag(name = "Todo List Management", description = "Operations pertaining to todo lists in Todo Management System")
public class TodoListController {
    private final TodoListService todoListService;

    @PostMapping
    @Operation(summary = "Create a new todo list", description = "Create a new todo list in the system", tags = {"Todo List Management"})
    public ResponseEntity<TodoList> createTodoList(@RequestBody TodoList todoList, Authentication authentication) {
        TodoList createdTodoList = todoListService.saveTodoList(todoList, authentication.getName());
        return ResponseEntity.ok(createdTodoList);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing todo list", description = "Update the details of an existing todo list", tags = {"Todo List Management"})
    public ResponseEntity<TodoList> updateTodoList(@PathVariable Long id, @RequestBody TodoList todoList) {
        TodoList updatedTodoList = todoListService.updateTodoList(id, todoList);
        return ResponseEntity.ok(updatedTodoList);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a todo list", description = "Delete a todo list from the system", tags = {"Todo List Management"})
    public ResponseEntity<Void> deleteTodoList(@PathVariable Long id) {
        todoListService.deleteTodoList(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a todo list by ID", description = "Retrieve a todo list by its ID", tags = {"Todo List Management"})
    public ResponseEntity<TodoList> getTodoListById(@PathVariable Long id) {
        TodoList todoList = todoListService.getTodoListById(id);
        return ResponseEntity.ok(todoList);
    }

    @GetMapping
    @Operation(summary = "Get all todo lists", description = "Retrieve a list of all todo lists", tags = {"Todo List Management"})
    public ResponseEntity<List<TodoList>> getAllTodoLists(Authentication authentication) {
        List<TodoList> todoLists = todoListService.getAllTodoLists(authentication);
        return ResponseEntity.ok(todoLists);
    }

    @PutMapping("/{todoListId}/items")
    @Operation(summary = "Add items to a todo list", description = "Add or update items in a todo list", tags = {"Todo List Management"})
    public ResponseEntity<TodoList> updateItemsInTodoList(@PathVariable Long todoListId, @RequestBody List<TodoItem> items) {
        TodoList updatedTodoList = todoListService.updateItemsInTodoList(todoListId, items);
        return ResponseEntity.ok(updatedTodoList);
    }
}
