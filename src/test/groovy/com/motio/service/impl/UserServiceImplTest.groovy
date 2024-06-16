package com.motio.service.impl

import com.motio.model.User
import com.motio.repository.UserRepository
import com.motio.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import spock.lang.Specification
import spock.lang.Stepwise

@SpringBootTest
@Stepwise
class UserServiceImplTest extends Specification {
    @Autowired
    UserService userService
    @Autowired
    UserRepository userRepository
    BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder()

    def cleanup() {
        userRepository.deleteAll()
    }

    def "test saving a user with hashed password"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        when: "Saving the user"
        def savedUser = userService.saveUser(user)

        then: "The user should be saved and the password should be hashed"
        savedUser != null
        savedUser.getPassword() != "securepassword123"
        bCryptPasswordEncoder.matches("securepassword123", savedUser.getPassword())
    }

    def "test updating a user with hashed password"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def savedUser = userRepository.save(user)

        and: "Updated user details"
        def updatedUser = new User(username: "johnny_doe", firstName: "Johnny", lastName: "Doey", password: "newpassword123", email: "johnny.doe@example.com")

        when: "Updating the user"
        def result = userService.updateUser(savedUser.getId(), updatedUser)

        then: "The user should be updated and the password should be hashed"
        result != null
        result.getPassword() != "newpassword123"
        bCryptPasswordEncoder.matches("newpassword123", result.getPassword())
    }

    def "test deleting a user"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def savedUser = userRepository.save(user)

        when: "Deleting the user"
        userService.deleteUser(savedUser.getId())

        then: "The user should be deleted"
        def foundUser = userRepository.findById(savedUser.getId())
        foundUser.isEmpty()
    }

    def "test finding user by username"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        userRepository.save(user)

        when: "Finding the user by username"
        def foundUser = userService.getUserByUsername("john_doe")

        then: "The user should be found"
        foundUser.isPresent()
        foundUser.get().getUsername() == "john_doe"
    }

    def "test finding user by email"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        userRepository.save(user)

        when: "Finding the user by email"
        def foundUser = userService.getUserByEmail("john.doe@example.com")

        then: "The user should be found"
        foundUser.isPresent()
        foundUser.get().getEmail() == "john.doe@example.com"
    }

    def "test getting all users"() {
        given: "Multiple users"
        def user1 = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def user2 = new User(username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "securepassword123", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)

        when: "Getting all users"
        def users = userService.getAllUsers()

        then: "All users should be returned"
        users.size() == 2
        users.contains(user1)
        users.contains(user2)
    }
}
