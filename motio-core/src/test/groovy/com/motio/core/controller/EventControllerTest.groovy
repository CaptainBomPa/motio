package com.motio.core.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.commons.model.Event
import com.motio.commons.model.User
import com.motio.commons.repository.UserRepository
import com.motio.core.repository.EventRepository
import com.motio.core.service.EventService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import java.time.*

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class EventControllerTest extends Specification {

    @Autowired
    MockMvc mockMvc
    @Autowired
    EventService eventService
    @Autowired
    EventRepository eventRepository
    @Autowired
    UserRepository userRepository
    @Autowired
    ObjectMapper objectMapper

    void setup() {
        eventRepository.deleteAll()
        userRepository.deleteAll()
    }

    void cleanup() {
        eventRepository.deleteAll()
        userRepository.deleteAll()
    }

    @WithMockUser(username = "user1")
    def "test adding an event"() {
        given: "Two users and an event object"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)

        expect:
        mockMvc.perform(post("/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(event)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.eventName').value("Meeting"))
                .andExpect(jsonPath('$.description').value("Project discussion"))
                .andExpect(jsonPath('$.startDateTime').exists())
                .andExpect(jsonPath('$.endDateTime').exists())
                .andExpect(jsonPath('$.invitedPeople[0].username').value("user1"))
                .andExpect(jsonPath('$.invitedPeople[1].username').value("user2"))
                .andExpect(jsonPath('$.createdByUser.username').value("user1"))
    }

    @WithMockUser(username = "user1")
    def "test updating an event"() {
        given: "An event to update"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        event = eventService.addEvent(event)
        event.eventName = "Updated Meeting"
        event.description = "Updated project discussion"

        expect:
        mockMvc.perform(put("/events/${event.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(event)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.eventName').value("Updated Meeting"))
                .andExpect(jsonPath('$.description').value("Updated project discussion"))
                .andExpect(jsonPath('$.createdByUser.username').value("user1"))
    }

    @WithMockUser(username = "user1")
    def "test getting all events"() {
        given: "Two events"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event1 = new Event(eventName: "Meeting 1", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        def event2 = new Event(eventName: "Meeting 2", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        eventService.addEvent(event1)
        eventService.addEvent(event2)

        expect:
        mockMvc.perform(get("/events")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].eventName').value("Meeting 1"))
                .andExpect(jsonPath('$[1].eventName').value("Meeting 2"))
                .andExpect(jsonPath('$[0].createdByUser.username').value("user1"))
                .andExpect(jsonPath('$[1].createdByUser.username').value("user1"))
    }

    @WithMockUser(username = "user1")
    def "test getting events for user"() {
        given: "Two events for a user"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event1 = new Event(eventName: "Meeting 1", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        def event2 = new Event(eventName: "Meeting 2", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        eventService.addEvent(event1)
        eventService.addEvent(event2)

        expect:
        mockMvc.perform(get("/events/user")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].eventName').value("Meeting 1"))
                .andExpect(jsonPath('$[1].eventName').value("Meeting 2"))
                .andExpect(jsonPath('$[0].createdByUser.username').value("user1"))
                .andExpect(jsonPath('$[1].createdByUser.username').value("user1"))
    }

    @WithMockUser(username = "user1")
    def "test deleting an event"() {
        given: "An event to delete"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        event = eventService.addEvent(event)

        expect:
        mockMvc.perform(delete("/events/${event.getId()}")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNoContent())
    }

    @WithMockUser(username = "user1")
    def "test adding event with different timezone"() {
        given: "Two users and an event object with different timezone"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def event = new Event(
                eventName: "Meeting in different timezone",
                description: "Project discussion",
                startDateTime: ZonedDateTime.now(ZoneId.of("America/New_York")),
                endDateTime: ZonedDateTime.now(ZoneId.of("America/New_York")).plusHours(1),
                invitedPeople: [user1, user2],
                createdByUser: user1
        )

        when:
        def result = mockMvc.perform(post("/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(event)))
                .andExpect(status().isOk())
                .andReturn()
        def responseJson = objectMapper.readTree(result.response.contentAsString)

        then:
        responseJson.path("eventName").asText() == "Meeting in different timezone"
        responseJson.path("description").asText() == "Project discussion"
        responseJson.path("startDateTime").asText().startsWith(event.startDateTime.withZoneSameInstant(ZoneOffset.UTC).toLocalDateTime().toString().substring(0, 19))
        responseJson.path("endDateTime").asText().startsWith(event.endDateTime.withZoneSameInstant(ZoneOffset.UTC).toLocalDateTime().toString().substring(0, 19))
        responseJson.path("invitedPeople")[0].path("username").asText() == "user1"
        responseJson.path("invitedPeople")[1].path("username").asText() == "user2"
        responseJson.path("createdByUser").path("username").asText() == "user1"
    }

    @WithMockUser(username = "user1")
    def "test getting events for user on specific date"() {
        given: "Two events for a user on specific dates"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def date = LocalDate.now().atTime(LocalTime.of(12, 0)).atZone(ZoneId.systemDefault())
        def event1 = new Event(eventName: "Meeting 1",
                description: "Project discussion",
                startDateTime: date,
                endDateTime: date.plusHours(1),
                invitedPeople: [user1, user2],
                createdByUser: user1
        )
        def event2 = new Event(eventName: "Meeting 2",
                description: "Project discussion",
                startDateTime: date.plusDays(1),
                endDateTime: date.plusDays(1).plusHours(1),
                invitedPeople: [user1, user2],
                createdByUser: user1
        )
        eventService.addEvent(event1)
        eventService.addEvent(event2)

        expect:
        mockMvc.perform(get("/events/user/date")
                .param("date", date.toLocalDate().toString())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].eventName').value("Meeting 1"))
                .andExpect(jsonPath('$[0].createdByUser.username').value("user1"))
    }

}
