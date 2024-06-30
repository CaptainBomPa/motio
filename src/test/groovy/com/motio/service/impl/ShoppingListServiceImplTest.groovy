package com.motio.service.impl

import com.motio.model.ShoppingItem
import com.motio.model.ShoppingList
import com.motio.model.User
import com.motio.repository.ShoppingItemRepository
import com.motio.repository.ShoppingListRepository
import com.motio.repository.UserRepository
import com.motio.service.ShoppingListService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import spock.lang.Specification

@DataJpaTest
class ShoppingListServiceImplTest extends Specification {

    @Autowired
    ShoppingListRepository shoppingListRepository

    @Autowired
    ShoppingItemRepository shoppingItemRepository

    @Autowired
    UserRepository userRepository

    @Autowired
    TestEntityManager entityManager

    ShoppingListService shoppingListService

    void setup() {
        shoppingListService = new ShoppingListServiceImpl(shoppingListRepository, shoppingItemRepository, userRepository)
    }

    def "should save shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list")

        when:
        ShoppingList savedShoppingList = shoppingListService.saveShoppingList(shoppingList, user.getUsername())

        then:
        savedShoppingList != null
        savedShoppingList.getId() != null
        savedShoppingList.getCreatedByUser() == user
    }

    def "should update shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def newItems = [new ShoppingItem(description: "Milk"), new ShoppingItem(description: "Bread")]

        when:
        ShoppingList updatedShoppingList = shoppingListService.updateItemsInShoppingList(shoppingList.getId(), newItems)

        then:
        updatedShoppingList.getItems().size() == 2
        updatedShoppingList.getItems()*.getDescription().containsAll(["Milk", "Bread"])
    }

    def "should delete shopping list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)

        when:
        shoppingListService.deleteShoppingList(shoppingList.getId())

        then:
        shoppingListRepository.findById(shoppingList.getId()).isEmpty()
    }

    def "should get shopping list by ID"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)

        when:
        ShoppingList foundShoppingList = shoppingListService.getShoppingListById(shoppingList.getId())

        then:
        foundShoppingList != null
        foundShoppingList.getId() == shoppingList.getId()
    }

    def "should get all shopping lists"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList1 = new ShoppingList(listName: "test_list", createdByUser: user)
        def shoppingList2 = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList1)
        entityManager.persistAndFlush(shoppingList2)

        when:
        List<ShoppingList> shoppingLists = shoppingListService.getAllShoppingLists()

        then:
        shoppingLists.size() == 2
    }
}
