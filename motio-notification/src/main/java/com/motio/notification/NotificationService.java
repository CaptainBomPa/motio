package com.motio.notification;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.motio.commons.model.NotificationMessage;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    public String sendNotification(NotificationMessage notificationMessage) {
        Notification notification = Notification.builder()
                .setTitle(notificationMessage.getTitle())
                .setBody(notificationMessage.getBody())
                .build();

        Message message = Message.builder()
                .setNotification(notification)
                .setToken(notificationMessage.getReceiver().getNotificationToken())
                .build();

        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String sendNotificationToAll(NotificationMessage notificationMessage) {
        Notification notification = Notification.builder()
                .setTitle(notificationMessage.getTitle())
                .setBody(notificationMessage.getBody())
                .build();

        Message message = Message.builder()
                .setNotification(notification)
                .setTopic("all_users")
                .build();

        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
