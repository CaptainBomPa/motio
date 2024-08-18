package com.motio.core.service.notification.impl;

import com.motio.commons.model.MessageType;
import com.motio.commons.model.NotificationMessage;
import com.motio.commons.model.TodoList;
import com.motio.commons.model.User;
import com.motio.core.service.notification.TodoListNotificationSender;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.ZonedDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class TodoListNotificationSenderImpl implements TodoListNotificationSender {
    private final RestTemplate restTemplate;

    @Value("${notification.send.address.url}")
    private String notificationServerUrl;

    @Override
    public void sendAddNewSharedUsers(TodoList todoList, User newSharedUser) {
        NotificationMessage notificationMessage = new NotificationMessage();
        notificationMessage.setMessageType(MessageType.SINGLE_RECEIVER);
        if (newSharedUser.getNotificationToken() == null || newSharedUser.getNotificationToken().isEmpty()) {
            log.info("Ignoring sending notifications for user: {}", newSharedUser.getUsername());
            return;
        }
        notificationMessage.setReceiver(newSharedUser);
        notificationMessage.setTitle("Zostałeś dodany do listy \"" + todoList.getListName() + "\"");
        StringBuilder bodyBuilder = new StringBuilder();
        bodyBuilder.append("Użytkownik");
        bodyBuilder.append(" ");
        bodyBuilder.append(todoList.getCreatedByUser().getFirstName() + " " + todoList.getCreatedByUser().getLastName());
        bodyBuilder.append(" ");
        bodyBuilder.append("dodał Cię do Todo Listy o nazwie");
        bodyBuilder.append(" ");
        bodyBuilder.append(todoList.getListName());
        notificationMessage.setBody(bodyBuilder.toString());
        notificationMessage.setSendDateTime(ZonedDateTime.now());
        send(notificationMessage);
    }

    private void send(NotificationMessage notificationMessage) {
        restTemplate.postForObject(notificationServerUrl, notificationMessage, Void.class);
    }
}
