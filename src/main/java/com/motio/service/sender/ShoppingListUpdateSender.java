package com.motio.service.sender;

import com.motio.model.ShoppingList;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class ShoppingListUpdateSender {

    public static final String SHOPPING_LIST_UPDATES_TOPIC = "/topic/shoppingListUpdates";
    private final SimpMessagingTemplate messagingTemplate;

    public ShoppingListUpdateSender(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    public void sendUpdate(ShoppingList shoppingList) {
        messagingTemplate.convertAndSend(SHOPPING_LIST_UPDATES_TOPIC, shoppingList);
    }
}