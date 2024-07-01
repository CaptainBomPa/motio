package com.motio.auth.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.auth.service.AuthenticationService
import com.motio.commons.model.User
import com.motio.commons.security.dto.JwtResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import spock.lang.Specification

import static org.mockito.ArgumentMatchers.any
import static org.mockito.ArgumentMatchers.anyString
import static org.mockito.Mockito.when
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
class AuthenticationControllerTest extends Specification {

    @Autowired
    AuthenticationController authenticationController
    @MockBean
    AuthenticationService authenticationService
    MockMvc mockMvc

    def setup() {
        mockMvc = MockMvcBuilders.standaloneSetup(authenticationController).build()
    }

    def "registerUser should register a new user"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")
        def registeredUser = new User(id: 1L, username: "john_doe", firstName: "John", lastName: "Doe", password: "encodedPassword", email: "john.doe@example.com")
        when(authenticationService.registerUser(any(User))).thenReturn(registeredUser)

        def objectMapper = new ObjectMapper()
        def userJson = objectMapper.writeValueAsString(user)

        expect: "User is registered"
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.id').value(1))
                .andExpect(jsonPath('$.username').value("john_doe"))
                .andExpect(jsonPath('$.password').value("encodedPassword"))
    }

    def "loginUser should authenticate user and return JWT tokens"() {
        given: "A user object and valid login credentials"
        def user = new User(username: "john_doe", password: "securepassword123")
        def jwtResponse = new JwtResponse("accessToken", "refreshToken")
        when(authenticationService.loginUser(anyString(), anyString())).thenReturn(jwtResponse)

        def objectMapper = new ObjectMapper()
        def userJson = objectMapper.writeValueAsString(user)

        expect: "User is authenticated and JWT tokens are returned"
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.accessToken').value("accessToken"))
                .andExpect(jsonPath('$.refreshToken').value("refreshToken"))
    }

    def "refreshToken should return new JWT tokens"() {
        given: "A valid refresh token"
        def jwtResponse = new JwtResponse("newAccessToken", "refreshToken")
        when(authenticationService.refreshAccessToken(anyString())).thenReturn(jwtResponse)

        def objectMapper = new ObjectMapper()
        def jwtResponseJson = objectMapper.writeValueAsString(new JwtResponse(null, "refreshToken"))

        expect: "New JWT tokens are returned"
        mockMvc.perform(post("/auth/refresh-token")
                .contentType(MediaType.APPLICATION_JSON)
                .content(jwtResponseJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.accessToken').value("newAccessToken"))
                .andExpect(jsonPath('$.refreshToken').value("refreshToken"))
    }
}
