package com.motio.notification.service.impl;

import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.model.MessageType;
import com.motio.commons.model.NotificationMessage;
import com.motio.notification.NotificationService;
import com.motio.notification.repository.NotificationMessageRepository;
import com.motio.notification.service.NotificationMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationMessageServiceImpl implements NotificationMessageService {
    private final NotificationMessageRepository notificationMessageRepository;
    private final NotificationService notificationService;

    @Override
    public void addNotificationMessage(NotificationMessage notificationMessage) {
        String firebaseId = notificationService.sendNotification(notificationMessage);
        notificationMessage.setFirebaseGeneratedId(firebaseId);
        notificationMessageRepository.save(notificationMessage);
    }

    @Override
    public void addBroadcastNotificationMessage(NotificationMessage notificationMessage) {
        String firebaseId = notificationService.sendNotificationToAll(notificationMessage);
        notificationMessage.setFirebaseGeneratedId(firebaseId);
        notificationMessageRepository.save(notificationMessage);
    }

    @Override
    public List<NotificationMessage> getNotificationMessages(String username) {
        return notificationMessageRepository.findAll().stream()
                .filter(notificationMessage -> notificationMessage.getMessageType() == MessageType.BROADCAST ||
                        (notificationMessage.getReceiver() != null && notificationMessage.getReceiver().getUsername().equals(username)))
                .sorted(Comparator.comparing(NotificationMessage::getSendDateTime))
                .limit(50)
                .toList();
    }

    @Override
    public void deleteNotificationMessage(Long notificationMessageId) {
        NotificationMessage messageToDelete = notificationMessageRepository.findById(notificationMessageId)
                .orElseThrow(() -> new GenericObjectNotFoundException(NotificationMessage.class));
        notificationMessageRepository.deleteById(messageToDelete.getId());
    }
}
