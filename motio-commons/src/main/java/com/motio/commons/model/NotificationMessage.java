package com.motio.commons.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "notification_message")
public class NotificationMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String firebaseGeneratedId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MessageType messageType;

    @ManyToOne
    @JoinColumn(name = "receiver_id")
    private User receiver;  // null == broadcast message

    @Column
    private String title;

    @Column
    private String body;

    @Column
    private ZonedDateTime sendDateTime;
}
