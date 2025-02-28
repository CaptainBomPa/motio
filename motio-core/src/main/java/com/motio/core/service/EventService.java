package com.motio.core.service;

import com.motio.commons.model.Event;

import java.time.LocalDate;
import java.util.List;

public interface EventService {
    Event addEvent(Event event);

    Event updateEvent(Long id, Event event);

    List<Event> getAllEvents();

    List<Event> getAllEventsForUsername(String username);

    List<Event> getEventsForUsernameOnDate(String username, LocalDate date);

    List<Event> getEventsForUsernameWithDateRange(String username, LocalDate startDate, LocalDate endDate);

    void deleteEvent(Long id);
}
