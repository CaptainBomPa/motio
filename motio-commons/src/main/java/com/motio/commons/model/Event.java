package com.motio.commons.model;

import com.motio.commons.exception.throwable.InvalidEventDatesException;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.HashSet;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String eventName;

    @Column
    private String description;

    @ManyToOne
    @JoinColumn(name = "created_by_user_id", nullable = false)
    private User createdByUser;

    @ManyToMany
    @JoinTable(
            name = "event_users",
            joinColumns = @JoinColumn(name = "event_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    private Set<User> invitedPeople = new HashSet<>();

    @Column
    private LocalDate allDayDate;

    @Column
    private ZonedDateTime startDateTime;

    @Column
    private ZonedDateTime endDateTime;

    @PrePersist
    @PreUpdate
    private void prePersistAndUpdate() {
        validateDates();
        convertToUTC();
    }

    private void validateDates() {
        if (allDayDate != null) {
            if (startDateTime != null || endDateTime != null) {
                throw new InvalidEventDatesException("If allDayDate is set, startDateTime and endDateTime must be null.");
            }
        } else {
            if (startDateTime == null || endDateTime == null) {
                throw new InvalidEventDatesException("If allDayDate is not set, both startDateTime and endDateTime must be provided.");
            }
        }
    }

    private void convertToUTC() {
        if (startDateTime != null) {
            startDateTime = startDateTime.withZoneSameInstant(ZoneOffset.UTC);
        }
        if (endDateTime != null) {
            endDateTime = endDateTime.withZoneSameInstant(ZoneOffset.UTC);
        }
    }
}
