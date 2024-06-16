package com.motio.repository

import com.motio.config.CacheConfig
import com.motio.model.User
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import org.springframework.cache.CacheManager
import org.springframework.context.annotation.Import
import spock.lang.Specification

@DataJpaTest
@Import(CacheConfig)
class UserRepositoryTest extends Specification {
    @Autowired
    UserRepository userRepository
    @Autowired
    TestEntityManager entityManager
    @Autowired
    CacheManager cacheManager

    def "test saving and finding user by username"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        when: "Saving the user"
        userRepository.saveAndFlush(user)
        def foundUser = userRepository.findByUsername("john_doe").orElse(null)

        then: "The user should be found in the repository"
        foundUser != null
        foundUser.getUsername() == "john_doe"

        when: "Fetching the user again"
        def cachedUser = cacheManager.getCache("users").get("john_doe", User.class)

        then: "The user should be cached"
        cachedUser != null
        cachedUser.getUsername() == "john_doe"
    }

    def "test saving and finding user by email"() {
        given: "A user object"
        def user = new User(username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "securepassword123", email: "jane.doe@example.com")

        when: "Saving the user"
        userRepository.saveAndFlush(user)
        def foundUser = userRepository.findByEmail("jane.doe@example.com").orElse(null)

        then: "The user should be found in the repository"
        foundUser != null
        foundUser.getEmail() == "jane.doe@example.com"

        when: "Fetching the user again"
        def cachedUser = cacheManager.getCache("users").get("jane.doe@example.com", User.class)

        then: "The user should be cached"
        cachedUser != null
        cachedUser.getEmail() == "jane.doe@example.com"
    }
}
