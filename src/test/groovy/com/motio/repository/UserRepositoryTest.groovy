package com.motio.repository

import com.motio.model.User
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import spock.lang.Specification

@DataJpaTest
class UserRepositoryTest extends Specification {

    @Autowired
    UserRepository userRepository

    def "test saving and finding user by username"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        when: "Saving the user"
        userRepository.save(user)
        def foundUser = userRepository.findByUsername("john_doe").orElse(null)

        then: "The user should be found"
        foundUser != null
        foundUser.getUsername() == "john_doe"
    }

    def "test saving and finding user by email"() {
        given: "A user object"
        def user = new User(username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "securepassword123", email: "jane.doe@example.com")

        when: "Saving the user"
        userRepository.save(user)
        def foundUser = userRepository.findByEmail("jane.doe@example.com").orElse(null)

        then: "The user should be found"
        foundUser != null
        foundUser.getEmail() == "jane.doe@example.com"
    }
}
