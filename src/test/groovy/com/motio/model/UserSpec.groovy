package com.motio.model

import jakarta.validation.Validation
import jakarta.validation.ValidatorFactory
import spock.lang.Specification

class UserSpec extends Specification {

    def "test user model getters and setters"() {
        given: "A user object"
        def user = new User()

        when: "Setting properties"
        user.setUsername("john_doe")
        user.setFirstName("John")
        user.setLastName("Doe")
        user.setPassword("securepassword123")
        user.setEmail("john.doe@example.com")

        then: "Properties should be set correctly"
        user.getUsername() == "john_doe"
        user.getFirstName() == "John"
        user.getLastName() == "Doe"
        user.getPassword() == "securepassword123"
        user.getEmail() == "john.doe@example.com"
    }

    def "test user model validation"() {
        given: "A validator factory and a user object"
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory()
        def validator = factory.getValidator()
        def user = new User()

        when: "Setting invalid properties"
        user.setUsername("")
        user.setFirstName("")
        user.setLastName("")
        user.setPassword("123")
        user.setEmail("invalidemail")

        then: "Validation should fail"
        def violations = validator.validate(user)
        violations.size() == 5
    }

    def "test user details methods"() {
        given: "A user object with default values"
        def user = new User()
        user.setUsername("john_doe")
        user.setFirstName("John")
        user.setLastName("Doe")
        user.setPassword("securepassword123")
        user.setEmail("john.doe@example.com")

        expect: "UserDetails methods should return expected values"
        user.getAuthorities() == null
        user.isAccountNonExpired()
        user.isAccountNonLocked()
        user.isCredentialsNonExpired()
        user.isEnabled()
    }

    def "test user equality and hashCode"() {
        given: "Two user objects with the same properties"
        def user1 = new User(id: 1, username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def user2 = new User(id: 1, username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        expect: "Users should be equal and have the same hash code"
        user1 == user2
        user1.hashCode() == user2.hashCode()
    }

    def "test user inequality"() {
        given: "Two user objects with different properties"
        def user1 = new User(id: 1, username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def user2 = new User(id: 2, username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "anotherpassword123", email: "jane.doe@example.com")

        expect: "Users should not be equal"
        user1 != user2
    }
}
