package com.motio.core.service.impl

import com.motio.commons.model.Event
import com.motio.commons.model.User
import com.motio.commons.service.UserService
import com.motio.core.repository.EventRepository
import com.motio.core.service.EventService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import spock.lang.Specification

import java.time.ZonedDateTime

@DataJpaTest
class EventServiceImplTest extends Specification {

    @Autowired
    EventRepository eventRepository
    @Autowired
    UserService userService
    @Autowired
    TestEntityManager entityManager
    EventService eventService

    void setup() {
        eventService = new EventServiceImpl(eventRepository, userService)
    }

    def "should add event"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)

        when:
        Event createdEvent = eventService.addEvent(event)

        then:
        createdEvent != null
        createdEvent.getId() != null
        createdEvent.getEventName() == "Meeting"
        createdEvent.getDescription() == "Project discussion"
        createdEvent.getStartDateTime() != null
        createdEvent.getEndDateTime() != null
        createdEvent.getInvitedPeople().size() == 2
        createdEvent.getCreatedByUser() == user1
    }

    def "should update event"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        entityManager.persistAndFlush(event)

        def updatedEvent = new Event(id: event.getId(), eventName: "Updated Meeting", description: "Updated project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(2), invitedPeople: [user1, user2], createdByUser: user1)

        when:
        Event result = eventService.updateEvent(event.getId(), updatedEvent)

        then:
        result != null
        result.getEventName() == "Updated Meeting"
        result.getDescription() == "Updated project discussion"
        result.getStartDateTime() != null
        result.getEndDateTime() != null
        result.getInvitedPeople().size() == 2
        result.getCreatedByUser() == user1
    }

    def "should get all events"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def event1 = new Event(eventName: "Meeting 1", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        def event2 = new Event(eventName: "Meeting 2", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        entityManager.persistAndFlush(event1)
        entityManager.persistAndFlush(event2)

        when:
        List<Event> events = eventService.getAllEvents()

        then:
        events.size() == 2
        events.contains(event1)
        events.contains(event2)
    }

    def "should get all events for username"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def event1 = new Event(eventName: "Meeting 1", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        def event2 = new Event(eventName: "Meeting 2", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        entityManager.persistAndFlush(event1)
        entityManager.persistAndFlush(event2)

        when:
        List<Event> events = eventService.getAllEventsForUsername(user1.getUsername())

        then:
        events.size() == 2
        events.contains(event1)
        events.contains(event2)
    }

    def "should delete event"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def event = new Event(eventName: "Meeting", description: "Project discussion", startDateTime: ZonedDateTime.now(), endDateTime: ZonedDateTime.now().plusHours(1), invitedPeople: [user1, user2], createdByUser: user1)
        entityManager.persistAndFlush(event)

        when:
        eventService.deleteEvent(event.getId())

        then:
        !eventRepository.existsById(event.getId())
    }
}
