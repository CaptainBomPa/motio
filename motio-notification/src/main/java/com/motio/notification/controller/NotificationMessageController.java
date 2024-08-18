package com.motio.notification.controller;

import com.motio.commons.model.NotificationMessage;
import com.motio.notification.service.NotificationMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
public class NotificationMessageController {
    private final NotificationMessageService notificationMessageService;

    @PostMapping("/single")
    public ResponseEntity<Void> sendNotificationMessage(@RequestBody NotificationMessage notificationMessage) {
        notificationMessageService.addNotificationMessage(notificationMessage);
        log.info("Notification message sent successfully");
        return ResponseEntity.ok().build();
    }

    @PostMapping("/broadcast")
    public ResponseEntity<Void> sendBroadcastNotificationMessage(@RequestBody NotificationMessage notificationMessage) {
        notificationMessageService.addBroadcastNotificationMessage(notificationMessage);
        log.info("Broadcast Notification message sent successfully");
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<NotificationMessage>> getNotificationMessages(Authentication authentication) {
        return ResponseEntity.ok(notificationMessageService.getNotificationMessages(authentication.getName()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNotificationMessage(@PathVariable Long id) {
        notificationMessageService.deleteNotificationMessage(id);
        return ResponseEntity.ok().build();
    }
}
