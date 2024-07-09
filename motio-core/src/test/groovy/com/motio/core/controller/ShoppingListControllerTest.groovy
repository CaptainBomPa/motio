package com.motio.core.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.commons.model.ShoppingItem
import com.motio.commons.model.ShoppingList
import com.motio.commons.model.User
import com.motio.commons.service.UserService
import com.motio.core.repository.ShoppingListRepository
import com.motio.core.service.ShoppingListService
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
class ShoppingListControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc

    @Autowired
    ShoppingListService shoppingListService

    @Autowired
    ShoppingListRepository shoppingListRepository

    @Autowired
    UserService userService

    @Autowired
    ObjectMapper objectMapper

    void setup() {
        shoppingListRepository.findAll().each { shoppingListService.deleteShoppingList(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    void cleanup() {
        shoppingListRepository.findAll().each { shoppingListService.deleteShoppingList(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    def "test creating a shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList = new ShoppingList(listName: "test_list")
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(post("/shopping-lists")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(shoppingList)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').isNotEmpty())
                .andExpect(jsonPath('$.createdByUser.username').value("user123"))
    }

    def "test updating a shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list"), user.getUsername())
        def items = [new ShoppingItem(description: "Milk"), new ShoppingItem(description: "Bread")]
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(put("/shopping-lists/${shoppingList.getId()}/items")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(items)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.items[0].description').value("Milk"))
                .andExpect(jsonPath('$.items[1].description').value("Bread"))
    }

    def "test deleting a shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(delete("/shopping-lists/${shoppingList.getId()}")
                .with(authentication(auth)))
                .andExpect(status().isNoContent())
    }

    def "test getting a shopping list by ID"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(get("/shopping-lists/${shoppingList.getId()}")
                .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').value(shoppingList.getId()))
                .andExpect(jsonPath('$.createdByUser.username').value("user123"))
    }

    def "test getting all shopping lists"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList1 = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list"), user.getUsername())
        def shoppingList2 = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list"), user.getUsername())
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(user.getUsername(), "password123", [new SimpleGrantedAuthority("ROLE_USER")])
        SecurityContextHolder.getContext().setAuthentication(auth)

        expect:
        mockMvc.perform(get("/shopping-lists")
                .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].id').value(shoppingList1.getId()))
                .andExpect(jsonPath('$[1].id').value(shoppingList2.getId()))
    }
}
