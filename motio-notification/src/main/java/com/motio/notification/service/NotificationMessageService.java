package com.motio.notification.service;

import com.motio.commons.model.NotificationMessage;

import java.util.List;

public interface NotificationMessageService {

    void addNotificationMessage(NotificationMessage notificationMessage);

    void addBroadcastNotificationMessage(NotificationMessage notificationMessage);

    List<NotificationMessage> getNotificationMessages(String username);
}
