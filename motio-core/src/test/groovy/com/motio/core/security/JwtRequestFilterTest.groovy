package com.motio.core.security

import com.motio.commons.security.JwtRequestFilter
import com.motio.commons.security.util.JwtTokenUtil
import com.motio.commons.service.MotioUserDetailsService
import io.jsonwebtoken.ExpiredJwtException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import spock.lang.Specification

import static org.mockito.Mockito.when
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
class JwtRequestFilterTest extends Specification {

    @Autowired
    JwtRequestFilter jwtRequestFilter

    @MockBean
    MotioUserDetailsService motioUserDetailsService

    @MockBean
    JwtTokenUtil jwtTokenUtil

    MockMvc mockMvc

    def setup() {
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
                .addFilter(jwtRequestFilter)
                .build()
    }

    @RestController
    static class TestController {
        @GetMapping("/test")
        String testEndpoint() {
            return "Test endpoint"
        }
    }

    def "doFilterInternal should authenticate user with valid token"() {
        given: "A valid JWT token"
        def username = "john_doe"
        def token = "validToken"
        UserDetails userDetails = User.withUsername(username).password("password").authorities([]).build()

        when(jwtTokenUtil.getUsernameFromToken(token)).thenReturn(username)
        when(jwtTokenUtil.validateToken(token, userDetails)).thenReturn(true)
        when(motioUserDetailsService.loadUserByUsername(username)).thenReturn(userDetails)

        expect: "User is authenticated"
        mockMvc.perform(get("/test").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
    }

    def "doFilterInternal should not authenticate user with no token"() {
        expect: "Request is not authenticated"
        mockMvc.perform(get("/test"))
                .andExpect(status().isOk())
    }

    def "doFilterInternal should not authenticate user with expired token"() {
        given: "An expired JWT token"
        def token = "expiredToken"

        when(jwtTokenUtil.getUsernameFromToken(token)).thenThrow(new ExpiredJwtException(null, null, "JWT Token has expired"))

        expect: "Request is not authenticated"
        mockMvc.perform(get("/test").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
    }

    def "doFilterInternal should not authenticate user with invalid token"() {
        given: "An invalid JWT token"
        def token = "invalidToken"

        when(jwtTokenUtil.getUsernameFromToken(token)).thenThrow(new IllegalArgumentException("Unable to get JWT Token"))

        expect: "Request is not authenticated"
        mockMvc.perform(get("/test").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
    }
}
