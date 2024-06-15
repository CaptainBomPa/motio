package com.motio.model

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
}
