package com.motio.core.config.dev.impl;

import com.motio.commons.model.Event;
import com.motio.commons.model.User;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.service.EventService;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.Validate;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.stream.IntStream;

@Component
@RequiredArgsConstructor
public class EventModelInitializer implements ModelInitializer<Event> {
    private static final Random random = new Random();
    private static final List<String> possibleEventNames = List.of(
            "Meeting", "Lunch", "Workout", "Conference", "Birthday Party", "Wedding", "Concert", "Workshop", "Dinner", "Holiday"
    );

    private final EventService eventService;
    private Collection<User> providedUsers;

    @Override
    @SuppressWarnings("unchecked")
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        if (type.isAssignableFrom(User.class)) {
            providedUsers = (Collection<User>) objects;
        } else {
            throw new RuntimeException("Could not apply context objects during data initialization");
        }
    }

    @Override
    public Collection<Event> initializeObjects() {
        Validate.notEmpty(providedUsers);

        List<User> users = List.copyOf(providedUsers);

        List<Event> loadedEvents = new LinkedList<>();

        IntStream.range(1, 30).forEach(i -> {
            Event event = new Event();
            event.setEventName(possibleEventNames.get(random.nextInt(possibleEventNames.size())));
            event.setDescription("Description for " + event.getEventName());

            // Determine if it's an all-day event or a specific time event
            if (random.nextBoolean()) {
                // All-day event
                event.setAllDayDate(LocalDate.now().plusDays(random.nextInt(14) - 7));
                event.setStartDateTime(null);
                event.setEndDateTime(null);
            } else {
                // Specific time event
                event.setAllDayDate(null);
                ZonedDateTime startDateTime = ZonedDateTime.now().plusDays(random.nextInt(14) - 7)
                        .withHour(random.nextInt(18))
                        .withMinute(random.nextInt(60));
                event.setStartDateTime(startDateTime);
                event.setEndDateTime(startDateTime.plusHours(1 + random.nextInt(4)));
            }

            // Select the creator of the event
            User creator = users.get(random.nextInt(users.size()));
            event.setCreatedByUser(creator);

            // Add invited people
            int invitedCount = random.nextInt(users.size());
            for (int j = 0; j < invitedCount; j++) {
                User invitedUser = users.get(random.nextInt(users.size()));
                if (!invitedUser.equals(creator)) {
                    event.getInvitedPeople().add(invitedUser);
                }
            }

            loadedEvents.add(eventService.addEvent(event));
        });

        return loadedEvents;
    }

    @Override
    public void destroy() {
        // do nothing
    }
}
