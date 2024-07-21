package com.motio.core.service;

import com.motio.commons.model.Event;

import java.util.List;

public interface EventService {
    Event addEvent(Event event);

    Event updateEvent(Long id, Event event);

    List<Event> getAllEvents();

    List<Event> getAllEventsForUsername(String username);

    void deleteEvent(Long id);
}
