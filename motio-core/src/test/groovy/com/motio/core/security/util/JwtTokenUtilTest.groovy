package com.motio.core.security.util

import com.motio.commons.security.util.JwtTokenUtil
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.io.Decoders
import io.jsonwebtoken.security.Keys
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import spock.lang.Specification

import javax.crypto.SecretKey

class JwtTokenUtilTest extends Specification {

    JwtTokenUtil jwtTokenUtil = new JwtTokenUtil()

    def setup() {
        jwtTokenUtil = new JwtTokenUtil()
    }

    def "generateToken should return a valid JWT token"() {
        given: "User details"
        UserDetails userDetails = User.withUsername("john_doe")
                .password("password")
                .authorities([])
                .build()

        when: "Generating token"
        String token = jwtTokenUtil.generateToken(userDetails)

        then: "Token should not be null"
        token != null
    }

    def "getUsernameFromToken should return the username from token"() {
        given: "A valid JWT token"
        UserDetails userDetails = User.withUsername("john_doe")
                .password("password")
                .authorities([])
                .build()
        String token = jwtTokenUtil.generateToken(userDetails)

        when: "Extracting username from token"
        String username = jwtTokenUtil.getUsernameFromToken(token)

        then: "Username should be extracted correctly"
        username == "john_doe"
    }

    def "getExpirationDateFromToken should return the expiration date from token"() {
        given: "A valid JWT token"
        UserDetails userDetails = User.withUsername("john_doe")
                .password("password")
                .authorities([])
                .build()
        String token = jwtTokenUtil.generateToken(userDetails)

        when: "Extracting expiration date from token"
        Date expirationDate = jwtTokenUtil.getExpirationDateFromToken(token)

        then: "Expiration date should be after current time"
        expirationDate.after(new Date())
    }

    def "isTokenExpired should return false for a valid token"() {
        given: "A valid JWT token"
        UserDetails userDetails = User.withUsername("john_doe")
                .password("password")
                .authorities([])
                .build()
        String token = jwtTokenUtil.generateToken(userDetails)

        when: "Checking if token is expired"
        boolean isExpired = jwtTokenUtil.isTokenExpired(token)

        then: "Token should not be expired"
        !isExpired
    }

    def "isTokenExpired should return true for an expired token"() {
        given: "An expired JWT token"
        SecretKey secretKey = Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtTokenUtil.SECRET_KEY_BASE64))
        String token = Jwts.builder()
                .subject("john_doe")
                .issuedAt(new Date(System.currentTimeMillis() - 10 * 60 * 1000)) // 10 minutes ago
                .expiration(new Date(System.currentTimeMillis() - 5 * 60 * 1000)) // 5 minutes ago
                .signWith(secretKey)
                .compact()

        when: "Checking if token is expired"
        boolean isExpired = jwtTokenUtil.isTokenExpired(token)

        then: "Token should be expired"
        isExpired
    }

    def "validateToken should return true for a valid token"() {
        given: "A valid JWT token"
        UserDetails userDetails = User.withUsername("john_doe")
                .password("password")
                .authorities([])
                .build()
        String token = jwtTokenUtil.generateToken(userDetails)

        when: "Validating token"
        boolean isValid = jwtTokenUtil.validateToken(token, userDetails)

        then: "Token should be valid"
        isValid
    }
}
