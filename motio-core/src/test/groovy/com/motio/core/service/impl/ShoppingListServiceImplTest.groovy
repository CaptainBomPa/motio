package com.motio.core.service.impl

import com.motio.commons.model.ShoppingItem
import com.motio.commons.model.ShoppingList
import com.motio.commons.model.User
import com.motio.commons.repository.UserRepository
import com.motio.core.config.TestConfig
import com.motio.core.repository.ShoppingItemRepository
import com.motio.core.repository.ShoppingListRepository
import com.motio.core.service.ShoppingListService
import com.motio.core.service.sender.ShoppingListUpdateSender
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import org.springframework.context.annotation.Import
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import spock.lang.Specification

@DataJpaTest
@Import(TestConfig)
class ShoppingListServiceImplTest extends Specification {

    @Autowired
    ShoppingListRepository shoppingListRepository
    @Autowired
    ShoppingItemRepository shoppingItemRepository
    @Autowired
    UserRepository userRepository
    @Autowired
    TestEntityManager entityManager
    @Autowired
    ShoppingListUpdateSender shoppingListUpdateSender
    ShoppingListService shoppingListService

    void setup() {
        shoppingListService = new ShoppingListServiceImpl(shoppingListRepository, shoppingItemRepository, userRepository, shoppingListUpdateSender)
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

        Authentication authentication = createAuthentication(user)

        when:
        List<ShoppingList> shoppingLists = shoppingListService.getAllShoppingLists(authentication)

        then:
        shoppingLists.size() == 2
    }

    private Authentication createAuthentication(User user) {
        return new Authentication() {
            @Override
            Collection<? extends GrantedAuthority> getAuthorities() {
                return user.getAuthorities()
            }

            @Override
            Object getCredentials() {
                return null
            }

            @Override
            Object getDetails() {
                return null
            }

            @Override
            Object getPrincipal() {
                return null
            }

            @Override
            boolean isAuthenticated() {
                return false
            }

            @Override
            void setAuthenticated(boolean isAuthenticated) throws IllegalArgumentException {

            }

            @Override
            String getName() {
                return user.getUsername()
            }
        }
    }
}
