package com.motio.service.impl

import com.motio.model.User
import com.motio.repository.UserRepository
import com.motio.security.util.JwtTokenUtil
import com.motio.service.AuthenticationService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import spock.lang.Specification
import spock.lang.Stepwise

import static org.mockito.ArgumentMatchers.any
import static org.mockito.ArgumentMatchers.eq
import static org.mockito.Mockito.when

@SpringBootTest
@Stepwise
class AuthenticationServiceImplTest extends Specification {
    @Autowired
    AuthenticationService authenticationService
    @Autowired
    UserRepository userRepository
    @MockBean
    JwtTokenUtil jwtTokenUtil

    BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder()

    def cleanup() {
        userRepository.deleteAll()
    }

    def "registerUser should encode password and save user"() {
        given: "A user object"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: "securepassword123", email: "john.doe@example.com")

        when: "Registering the user"
        def response = authenticationService.registerUser(user)

        then: "The user should be saved and the password should be hashed"
        response != null
        def savedUser = userRepository.findByUsername("john_doe").get()
        savedUser.getPassword() != "securepassword123"
        bCryptPasswordEncoder.matches("securepassword123", savedUser.getPassword())
    }

    def "loginUser should return JWT tokens if credentials are valid"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: bCryptPasswordEncoder.encode("securepassword123"), email: "john.doe@example.com")
        userRepository.save(user)

        def accessToken = "accessToken"
        def refreshToken = "refreshToken"
        when(jwtTokenUtil.generateToken(any(UserDetails))).thenReturn(accessToken)
        when(jwtTokenUtil.generateRefreshToken(any(UserDetails))).thenReturn(refreshToken)

        when: "Logging in the user with correct credentials"
        def response = authenticationService.loginUser("john_doe", "securepassword123")

        then: "JWT tokens should be returned"
        response != null
        response.accessToken == accessToken
        response.refreshToken == refreshToken
    }

    def "loginUser should throw exception if credentials are invalid"() {
        given: "An existing user"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: bCryptPasswordEncoder.encode("securepassword123"), email: "john.doe@example.com")
        userRepository.save(user)

        when: "Logging in the user with incorrect credentials"
        authenticationService.loginUser("john_doe", "wrongpassword")

        then: "An exception should be thrown"
        thrown(RuntimeException)
    }

    def "refreshAccessToken should return new access token if refresh token is valid"() {
        given: "An existing user and valid refresh token"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: bCryptPasswordEncoder.encode("securepassword123"), email: "john.doe@example.com")
        userRepository.save(user)
        def userDetails = userDetailsFromUser(user)
        def refreshToken = "validRefreshToken"
        def newAccessToken = "newAccessToken"

        when(jwtTokenUtil.getUsernameFromToken(refreshToken)).thenReturn("john_doe")
        when(jwtTokenUtil.validateToken(any(), any())).thenReturn(true)
        when(jwtTokenUtil.generateToken(any())).thenReturn(newAccessToken)
        when(jwtTokenUtil.getExpirationDateFromToken(refreshToken)).thenReturn(new Date(System.currentTimeMillis() + 72 * 60 * 60 * 1000))

        when: "Refreshing the access token with a valid refresh token"
        def response = authenticationService.refreshAccessToken(refreshToken)

        then: "A new access token should be returned"
        response != null
        response.accessToken == newAccessToken
        response.refreshToken == refreshToken
    }

    def "refreshAccessToken should return new access and refresh token if refresh token is about to expire"() {
        given: "An existing user and a refresh token that is about to expire"
        def user = new User(username: "john_doe", firstName: "John", lastName: "Doe", password: bCryptPasswordEncoder.encode("securepassword123"), email: "john.doe@example.com")
        userRepository.save(user)
        def userDetails = userDetailsFromUser(user)
        def refreshToken = "validRefreshToken"
        def newAccessToken = "newAccessToken"
        def newRefreshToken = "newRefreshToken"

        when(jwtTokenUtil.getUsernameFromToken(refreshToken)).thenReturn("john_doe")
        when(jwtTokenUtil.validateToken(any(), any())).thenReturn(true)
        when(jwtTokenUtil.generateToken(any())).thenReturn(newAccessToken)
        when(jwtTokenUtil.getExpirationDateFromToken(refreshToken)).thenReturn(new Date(System.currentTimeMillis() + 12 * 60 * 60 * 1000))
        when(jwtTokenUtil.generateRefreshToken(any())).thenReturn(newRefreshToken)

        when: "Refreshing the access token with a refresh token that is about to expire"
        def response = authenticationService.refreshAccessToken(refreshToken)

        then: "New access and refresh tokens should be returned"
        response != null
        response.accessToken == newAccessToken
        response.refreshToken == newRefreshToken
    }

    def "refreshAccessToken should throw exception if refresh token is invalid"() {
        given: "An invalid refresh token"
        def refreshToken = "invalidRefreshToken"

        when(jwtTokenUtil.getUsernameFromToken(refreshToken)).thenReturn("john_doe")
        when(jwtTokenUtil.validateToken(eq(refreshToken), any())).thenReturn(false)

        when: "Refreshing the access token with an invalid refresh token"
        authenticationService.refreshAccessToken(refreshToken)

        then: "An exception should be thrown"
        thrown(RuntimeException)
    }

    private UserDetails userDetailsFromUser(User user) {
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities(new ArrayList<>())
                .build()
    }
}
