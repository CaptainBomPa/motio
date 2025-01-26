package com.motio.core.controller;

import com.motio.commons.model.Event;
import com.motio.core.service.EventService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/events")
@RequiredArgsConstructor
@Tag(name = "Event Management System", description = "Operations pertaining to events")
public class EventController {
    private final EventService eventService;

    @PostMapping
    @Operation(summary = "Create a new event",
            description = "Create a new event",
            tags = {"Event Management System"})
    public ResponseEntity<Event> addEvent(@RequestBody Event event) {
        Event createdEvent = eventService.addEvent(event);
        return ResponseEntity.ok(createdEvent);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing event",
            description = "Update an existing event",
            tags = {"Event Management System"})
    public ResponseEntity<Event> updateEvent(@PathVariable Long id, @RequestBody Event event) {
        Event updatedEvent = eventService.updateEvent(id, event);
        return ResponseEntity.ok(updatedEvent);
    }

    @GetMapping
    @Operation(summary = "Get all events",
            description = "Retrieve all events",
            tags = {"Event Management System"})
    public ResponseEntity<List<Event>> getAllEvents() {
        List<Event> events = eventService.getAllEvents();
        return ResponseEntity.ok(events);
    }

    @GetMapping("/user")
    @Operation(summary = "Get events for user",
            description = "Retrieve all events associated with the authenticated user",
            tags = {"Event Management System"})
    public ResponseEntity<List<Event>> getAllEventsForUsername(Authentication authentication) {
        List<Event> events = eventService.getAllEventsForUsername(authentication.getName());
        return ResponseEntity.ok(events);
    }

    @GetMapping("/user/date")
    @Operation(summary = "Get events for user on specific date",
            description = "Retrieve all events associated with the authenticated user on a specific date",
            tags = {"Event Management System"})
    public ResponseEntity<List<Event>> getEventsForUsernameOnDate(Authentication authentication, @RequestParam("date") LocalDate date) {
        List<Event> events = eventService.getEventsForUsernameOnDate(authentication.getName(), date);
        return ResponseEntity.ok(events);
    }

    @GetMapping("/user/date-range")
    @Operation(
            summary = "Get events for user within a date range",
            description = "Retrieve all events associated with the authenticated user within the specified date range",
            tags = {"Event Management System"}
    )
    public ResponseEntity<List<Event>> getEventsForUsernameInRange(Authentication authentication, @RequestParam("startDate") LocalDate startDate, @RequestParam("endDate") LocalDate endDate) {
        List<Event> events = eventService.getEventsForUsernameWithDateRange(authentication.getName(), startDate, endDate);
        return ResponseEntity.ok(events);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete an event",
            description = "Delete an event by ID",
            tags = {"Event Management System"})
    public ResponseEntity<Void> deleteEvent(@PathVariable Long id) {
        eventService.deleteEvent(id);
        return ResponseEntity.noContent().build();
    }
}
