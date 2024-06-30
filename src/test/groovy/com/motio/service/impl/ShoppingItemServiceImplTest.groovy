package com.motio.service.impl

import com.motio.model.ShoppingItem
import com.motio.model.ShoppingList
import com.motio.model.User
import com.motio.repository.ShoppingItemRepository
import com.motio.repository.ShoppingListRepository
import com.motio.repository.UserRepository
import com.motio.service.ShoppingItemService
import com.motio.service.ShoppingListService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import spock.lang.Specification

@DataJpaTest
class ShoppingItemServiceImplTest extends Specification {

    @Autowired
    ShoppingItemRepository shoppingItemRepository

    @Autowired
    ShoppingListRepository shoppingListRepository

    @Autowired
    UserRepository userRepository

    @Autowired
    TestEntityManager entityManager

    ShoppingItemService shoppingItemService
    ShoppingListService shoppingListService

    void setup() {
        shoppingItemService = new ShoppingItemServiceImpl(shoppingItemRepository)
        shoppingListService = new ShoppingListServiceImpl(shoppingListRepository, shoppingItemRepository, userRepository)
    }

    def "should save shopping item"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def shoppingItem = new ShoppingItem(description: "Milk")

        when:
        ShoppingItem savedShoppingItem = shoppingItemService.saveShoppingItem(shoppingItem)

        then:
        savedShoppingItem != null
        savedShoppingItem.getId() != null
        savedShoppingItem.getDescription() == "Milk"
    }

    def "should update shopping item"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def shoppingItem = new ShoppingItem(description: "Milk")
        entityManager.persistAndFlush(shoppingItem)
        def updatedItem = new ShoppingItem(description: "Bread")

        when:
        ShoppingItem result = shoppingItemService.updateShoppingItem(shoppingItem.getId(), updatedItem)

        then:
        result != null
        result.getDescription() == "Bread"
    }

    def "should delete shopping item"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def shoppingItem = new ShoppingItem(description: "Milk")
        entityManager.persistAndFlush(shoppingItem)

        when:
        shoppingItemService.deleteShoppingItem(shoppingItem.getId())

        then:
        shoppingItemRepository.findById(shoppingItem.getId()).isEmpty()
    }

    def "should get shopping item by ID"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def shoppingItem = new ShoppingItem(description: "Milk")
        entityManager.persistAndFlush(shoppingItem)

        when:
        ShoppingItem foundShoppingItem = shoppingItemService.getShoppingItemById(shoppingItem.getId())

        then:
        foundShoppingItem != null
        foundShoppingItem.getId() == shoppingItem.getId()
        foundShoppingItem.getDescription() == "Milk"
    }

    def "should get all shopping items"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def shoppingList = new ShoppingList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(shoppingList)
        def shoppingItem1 = new ShoppingItem(description: "Milk")
        def shoppingItem2 = new ShoppingItem(description: "Bread")
        entityManager.persistAndFlush(shoppingItem1)
        entityManager.persistAndFlush(shoppingItem2)

        when:
        List<ShoppingItem> shoppingItems = shoppingItemService.getAllShoppingItems()

        then:
        shoppingItems.size() == 2
        shoppingItems*.getDescription().containsAll(["Milk", "Bread"])
    }
}
