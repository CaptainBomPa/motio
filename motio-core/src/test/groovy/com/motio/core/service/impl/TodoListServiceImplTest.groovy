package com.motio.core.service.impl


import com.motio.commons.model.TodoItem
import com.motio.commons.model.TodoList
import com.motio.commons.model.User
import com.motio.commons.repository.UserRepository
import com.motio.core.config.TestConfig
import com.motio.core.repository.TodoItemRepository
import com.motio.core.repository.TodoListRepository
import com.motio.core.service.TodoListService
import com.motio.core.service.notification.TodoListNotificationSender
import com.motio.core.service.sender.TodoListUpdateSender
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import org.springframework.context.annotation.Import
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import spock.lang.Specification

@DataJpaTest
@Import(TestConfig)
class TodoListServiceImplTest extends Specification {

    @Autowired
    TodoListRepository todoListRepository
    @Autowired
    TodoItemRepository todoItemRepository
    @Autowired
    UserRepository userRepository
    @Autowired
    TestEntityManager entityManager
    @Autowired
    TodoListUpdateSender todoListUpdateSender
    @Autowired
    TodoListNotificationSender todoListNotificationSender

    TodoListService todoListService

    void setup() {
        todoListService = new TodoListServiceImpl(todoListRepository, todoItemRepository, userRepository, todoListUpdateSender, todoListNotificationSender)
    }

    def "should save todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def todoList = new TodoList(listName: "test_list")

        when:
        TodoList savedTodoList = todoListService.saveTodoList(todoList, user.getUsername())

        then:
        savedTodoList != null
        savedTodoList.getId() != null
        savedTodoList.getCreatedByUser() == user
    }

    def "should update todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def todoList = new TodoList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(todoList)
        def newItems = [new TodoItem(description: "Milk"), new TodoItem(description: "Bread")]

        when:
        TodoList updatedTodoList = todoListService.updateItemsInTodoList(todoList.getId(), newItems)

        then:
        updatedTodoList.getItems().size() == 2
        updatedTodoList.getItems()*.getDescription().containsAll(["Milk", "Bread"])
    }

    def "should delete todo list"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def todoList = new TodoList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(todoList)

        when:
        todoListService.deleteTodoList(todoList.getId())

        then:
        todoListRepository.findById(todoList.getId()).isEmpty()
    }

    def "should get todo list by ID"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def todoList = new TodoList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(todoList)

        when:
        TodoList foundTodoList = todoListService.getTodoListById(todoList.getId())

        then:
        foundTodoList != null
        foundTodoList.getId() == todoList.getId()
    }

    def "should get all todo lists"() {
        given:
        def user = new User(username: "user123", firstName: "John", lastName: "Doe", password: "password123", email: "john.doe@example.com")
        entityManager.persistAndFlush(user)
        def todoList1 = new TodoList(listName: "test_list", createdByUser: user)
        def todoList2 = new TodoList(listName: "test_list", createdByUser: user)
        entityManager.persistAndFlush(todoList1)
        entityManager.persistAndFlush(todoList2)

        Authentication authentication = createAuthentication(user)

        when:
        List<TodoList> todoLists = todoListService.getAllTodoLists(authentication)

        then:
        todoLists.size() == 2
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
