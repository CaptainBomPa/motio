package com.motio.core.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.commons.model.TodoItem
import com.motio.commons.model.TodoList
import com.motio.commons.model.User
import com.motio.commons.service.UserService
import com.motio.core.repository.TodoListRepository
import com.motio.core.service.TodoListService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class TodoListControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc

    @Autowired
    TodoListService todoListService

    @Autowired
    TodoListRepository todoListRepository

    @Autowired
    UserService userService

    @Autowired
    ObjectMapper objectMapper

    void setup() {
        todoListRepository.findAll().each { todoListService.deleteTodoList(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    void cleanup() {
        todoListRepository.findAll().each { todoListService.deleteTodoList(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    def "test creating a todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def todoList = new TodoList(listName: "test_list")
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(post("/todo-lists")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(todoList)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').isNotEmpty())
                .andExpect(jsonPath('$.createdByUser.username').value("user123"))
    }

    def "test updating a todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def todoList = todoListService.saveTodoList(new TodoList(listName: "test_list"), user.getUsername())
        def items = [new TodoItem(description: "Milk"), new TodoItem(description: "Bread")]
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(put("/todo-lists/${todoList.getId()}/items")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(items)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.items[0].description').value("Milk"))
                .andExpect(jsonPath('$.items[1].description').value("Bread"))
    }

    def "test deleting a todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def todoList = todoListService.saveTodoList(new TodoList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(delete("/todo-lists/${todoList.getId()}")
                .with(authentication(auth)))
                .andExpect(status().isNoContent())
    }

    def "test getting a todo list by ID"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def todoList = todoListService.saveTodoList(new TodoList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(get("/todo-lists/${todoList.getId()}")
                .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').value(todoList.getId()))
                .andExpect(jsonPath('$.createdByUser.username').value("user123"))
    }

    def "test getting all todo lists"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def todoList1 = todoListService.saveTodoList(new TodoList(listName: "test_list"), user.getUsername())
        def todoList2 = todoListService.saveTodoList(new TodoList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(get("/todo-lists")
                .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].id').value(todoList1.getId()))
                .andExpect(jsonPath('$[1].id').value(todoList2.getId()))
    }
}
