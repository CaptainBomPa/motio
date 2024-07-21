package com.motio.core.service.impl;

import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.Event;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import com.motio.core.repository.EventRepository;
import com.motio.core.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EventServiceImpl implements EventService {
    private final EventRepository eventRepository;
    private final UserService userService;

    @Override
    @Transactional
    public Event addEvent(Event event) {
        return eventRepository.save(event);
    }

    @Override
    @Transactional
    public Event updateEvent(Long id, Event event) {
        Event existingEvent = eventRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(Event.class));
        existingEvent.setEventName(event.getEventName());
        existingEvent.setDescription(event.getDescription());
        existingEvent.setAllDayDate(event.getAllDayDate());
        existingEvent.setStartDateTime(event.getStartDateTime());
        existingEvent.setEndDateTime(event.getEndDateTime());
        existingEvent.setInvitedPeople(event.getInvitedPeople());
        return eventRepository.save(existingEvent);
    }

    @Override
    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    @Override
    public List<Event> getAllEventsForUsername(String username) {
        User user = userService.getUserByUsername(username).orElseThrow(() -> new UserNotFoundException(username));
        return eventRepository.findAll().stream()
                .filter(event -> event.getInvitedPeople().contains(user) || event.getCreatedByUser().equals(user))
                .toList();
    }

//    getAllEventsForUsername(username).stream().filter(event -> (event.getAllDayDate() != null && event.getAllDayDate().equals(date)) || (event.getStartDateTime() != null && event.getStartDateTime().toLocalDate().equals(date))).toList()

    @Override
    public List<Event> getEventsForUsernameOnDate(String username, LocalDate date) {
        return getAllEventsForUsername(username).stream()
                .filter(event -> (event.getAllDayDate() != null && event.getAllDayDate().equals(date)) ||
                        (event.getStartDateTime() != null && event.getStartDateTime().toLocalDate().equals(date)))
                .toList();
    }

    @Override
    @Transactional
    public void deleteEvent(Long id) {
        Event event = eventRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(Event.class));
        eventRepository.delete(event);
    }
}
