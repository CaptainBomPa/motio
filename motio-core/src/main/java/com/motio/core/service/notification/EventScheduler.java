package com.motio.core.service.notification;

import com.motio.commons.model.Event;
import com.motio.commons.model.MessageType;
import com.motio.commons.model.NotificationMessage;
import com.motio.commons.model.User;
import com.motio.core.service.EventService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collection;
import java.util.LinkedList;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventScheduler {
    private final EventService eventService;
    private final RestTemplate restTemplate;

    @Value("${notification.send.address.url}")
    private String notificationServerUrl;

    @Scheduled(cron = "0 * * * * *")
    public void perform() {
        Collection<Event> events = eventService.getAllEvents().stream()
                .filter(event -> event.getReminderMinutesBefore() != null)
                .collect(Collectors.toSet());
        LinkedList<NotificationMessage> messagesToSend = new LinkedList<>();
        final ZonedDateTime now = ZonedDateTime.now(ZoneId.of("UTC")).withSecond(0).withNano(0);

        for (Event event : events) {
            if (event.getStartDateTime().minusMinutes(event.getReminderMinutesBefore()).minusSeconds(59).isBefore(now)) {
                NotificationMessage notificationMessage = createNotificationMessage(event, event.getCreatedByUser());

                sendNotification(notificationMessage);
                messagesToSend.add(notificationMessage);

                for (User otherUserToRemind : event.getInvitedPeople()) {
                    NotificationMessage otherNotificationMessage = createNotificationMessage(event, otherUserToRemind);
                    sendNotification(otherNotificationMessage);
                    messagesToSend.add(otherNotificationMessage);
                }

                event.setReminderMinutesBefore(null);
                eventService.updateEvent(event.getId(), event);
            }
        }
        if (!messagesToSend.isEmpty()) {
            log.info("{} notification messages were sent", messagesToSend.size());
        }
    }

    private NotificationMessage createNotificationMessage(Event event, User receiver) {
        NotificationMessage notificationMessage = new NotificationMessage();
        notificationMessage.setMessageType(MessageType.SINGLE_RECEIVER);
        notificationMessage.setReceiver(receiver);
        notificationMessage.setTitle("Przypomnienie o wydarzeniu " + event.getEventName());
        notificationMessage.setBody("Wydarzenie rozpocznie się za " + event.getReminderMinutesBefore() + " minut");
        notificationMessage.setSendDateTime(ZonedDateTime.now());
        return notificationMessage;
    }

    private void sendNotification(NotificationMessage notificationMessage) {
        restTemplate.postForObject(notificationServerUrl, notificationMessage, Void.class);
    }
}
