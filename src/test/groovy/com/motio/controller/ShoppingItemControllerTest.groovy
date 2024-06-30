package com.motio.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.model.ShoppingItem
import com.motio.model.ShoppingList
import com.motio.model.User
import com.motio.repository.UserRepository
import com.motio.service.ShoppingItemService
import com.motio.service.ShoppingListService
import com.motio.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.authentication.TestingAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class ShoppingItemControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc
    @Autowired
    ShoppingItemService shoppingItemService
    @Autowired
    ShoppingListService shoppingListService
    @Autowired
    UserRepository userRepository
    @Autowired
    UserService userService
    @Autowired
    ObjectMapper objectMapper

    void setup() {
        shoppingListService.getAllShoppingLists().each { shoppingListService.deleteShoppingList(it.id) }
        shoppingItemService.getAllShoppingItems().each { shoppingItemService.deleteShoppingItem(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    void cleanup() {
        shoppingListService.getAllShoppingLists().each { shoppingListService.deleteShoppingList(it.id) }
        shoppingItemService.getAllShoppingItems().each { shoppingItemService.deleteShoppingItem(it.id) }
        userService.getAllUsers().each { userService.deleteUser(it.id) }
    }

    def "test creating a shopping item"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list", createdByUser: user), user.getUsername())
        def shoppingItem = new ShoppingItem(description: "Milk")
        def auth = new TestingAuthenticationToken(user.getUsername(), "password")
        SecurityContextHolder.getContext().setAuthentication(auth)

        when:
        shoppingList.getItems().add(shoppingItem)
        shoppingListService.updateShoppingList(shoppingList.getId(), shoppingList)

        then:
        def response = mockMvc.perform(post("/shopping-items")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(shoppingItem)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').isNotEmpty())
                .andExpect(jsonPath('$.description').value("Milk"))
                .andReturn()

        def updatedShoppingList = shoppingListService.getShoppingListById(shoppingList.getId())
        updatedShoppingList.getItems().size() == 1
        updatedShoppingList.getItems().get(0).getDescription() == "Milk"
    }

    def "test updating a shopping item"() {
        given:
        def user = new User(username: "user124", firstName: "John", lastName: "Doe", password: "password124", email: "john.doe2@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list", createdByUser: user), user.getUsername())
        def shoppingItem = shoppingItemService.saveShoppingItem(new ShoppingItem(description: "Milk"))
        shoppingList.getItems().add(shoppingItem)
        shoppingListService.updateShoppingList(shoppingList.getId(), shoppingList)
        def updatedItem = new ShoppingItem(description: "Bread")

        when:
        shoppingList.getItems().set(0, updatedItem)
        shoppingListService.updateShoppingList(shoppingList.getId(), shoppingList)

        then:
        mockMvc.perform(put("/shopping-items/${shoppingItem.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedItem)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.description').value("Bread"))
    }

    def "test getting a shopping item by ID"() {
        given:
        def user = new User(username: "user126", firstName: "John", lastName: "Doe", password: "password126", email: "john.doe4@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list", createdByUser: user), user.getUsername())
        def shoppingItem = shoppingItemService.saveShoppingItem(new ShoppingItem(description: "Milk"))
        shoppingList.getItems().add(shoppingItem)
        shoppingListService.updateShoppingList(shoppingList.getId(), shoppingList)

        when:
        def response = mockMvc.perform(get("/shopping-items/${shoppingItem.getId()}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').value(shoppingItem.getId()))
                .andExpect(jsonPath('$.description').value("Milk"))
                .andReturn()

        def updatedShoppingList = shoppingListService.getShoppingListById(shoppingList.getId())
        then:
        updatedShoppingList.getItems().size() == 1
        updatedShoppingList.getItems().get(0).getDescription() == "Milk"
    }

    def "test getting all shopping items"() {
        given:
        def user = new User(username: "user127", firstName: "John", lastName: "Doe", password: "password127", email: "john.doe5@example.com")
        userService.saveUser(user)
        def shoppingList = shoppingListService.saveShoppingList(new ShoppingList(listName: "test_list", createdByUser: user), user.getUsername())
        def shoppingItem1 = shoppingItemService.saveShoppingItem(new ShoppingItem(description: "Milk"))
        def shoppingItem2 = shoppingItemService.saveShoppingItem(new ShoppingItem(description: "Bread"))
        shoppingList.getItems().addAll([shoppingItem1, shoppingItem2])
        shoppingListService.updateShoppingList(shoppingList.getId(), shoppingList)

        when:
        def response = mockMvc.perform(get("/shopping-items"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].description').value("Milk"))
                .andExpect(jsonPath('$[1].description').value("Bread"))
                .andReturn()

        def updatedShoppingList = shoppingListService.getShoppingListById(shoppingList.getId())
        then:
        updatedShoppingList.getItems().size() == 2
        updatedShoppingList.getItems().get(0).getDescription() == "Milk"
        updatedShoppingList.getItems().get(1).getDescription() == "Bread"
    }
}
