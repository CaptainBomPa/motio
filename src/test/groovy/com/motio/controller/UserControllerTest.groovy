package com.motio.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.model.User
import com.motio.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest extends Specification {
    @Autowired
    MockMvc mockMvc
    @Autowired
    UserRepository userRepository
    @Autowired
    ObjectMapper objectMapper

    def setup() {
        userRepository.deleteAll()
    }

    def cleanup() {
        userRepository.deleteAll()
    }

    def "test creating a user"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        expect:
        mockMvc.perform(post("/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.username').value("john_doe"))
    }

    def "test updating a user"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def savedUser = userRepository.save(user)

        and: "Updated user details"
        def updatedUser = new User(username: "johnny_doe", firstName: "Johnny", lastName: "Doey", password: "newpassword123", email: "johnny.doe@example.com")

        expect:
        mockMvc.perform(put("/users/${savedUser.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.username').value("johnny_doe"))
    }

    def "test deleting a user"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def savedUser = userRepository.save(user)

        expect:
        mockMvc.perform(delete("/users/${savedUser.getId()}"))
                .andExpect(status().isNoContent())
    }

    def "test getting a user by ID"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def savedUser = userRepository.save(user)

        expect:
        mockMvc.perform(get("/users/${savedUser.getId()}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.username').value("john_doe"))
    }

    def "test getting all users"() {
        given: "Multiple users"
        def user1 = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def user2 = new User(username: "jane_doe", firstName: "Jane", lastName: "Doe", password: "securepassword123", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)

        expect:
        mockMvc.perform(get("/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].username').value("john_doe"))
                .andExpect(jsonPath('$[1].username').value("jane_doe"))
    }

    def "test getting a user by username"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        userRepository.save(user)

        expect:
        mockMvc.perform(get("/users/username/john_doe"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.username').value("john_doe"))
    }

    def "test getting a user by email"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        userRepository.save(user)

        expect:
        mockMvc.perform(get("/users/email/john.doe@example.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.email').value("john.doe@example.com"))
    }
}
