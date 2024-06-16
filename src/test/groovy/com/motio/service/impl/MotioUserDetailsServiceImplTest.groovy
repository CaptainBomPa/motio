package com.motio.service.impl

import com.motio.model.User
import com.motio.repository.UserRepository
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UsernameNotFoundException
import spock.lang.Specification

class MotioUserDetailsServiceImplTest extends Specification {

    UserRepository userRepository = Mock()
    MotioUserDetailsServiceImpl userDetailsService = new MotioUserDetailsServiceImpl(userRepository)

    def "loadUserByUsername should return UserDetails when user is found"() {
        given: "A username and a corresponding user in the repository"
        def username = "john_doe"
        def user = new User(username: username, password: "password", email: "john.doe@example.com")
        userRepository.findByUsername(username) >> Optional.of(user)

        when: "Loading user by username"
        UserDetails userDetails = userDetailsService.loadUserByUsername(username)

        then: "UserDetails should be returned"
        userDetails.username == username
        userDetails.password == user.password
    }

    def "loadUserByUsername should throw UsernameNotFoundException when user is not found"() {
        given: "A username that does not exist in the repository"
        def username = "non_existent_user"
        userRepository.findByUsername(username) >> Optional.empty()

        when: "Loading user by username"
        userDetailsService.loadUserByUsername(username)

        then: "UsernameNotFoundException should be thrown"
        thrown(UsernameNotFoundException)
    }
}
