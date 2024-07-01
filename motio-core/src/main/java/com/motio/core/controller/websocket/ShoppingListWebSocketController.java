package com.motio.core.controller.websocket;

import com.motio.commons.model.ShoppingList;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class ShoppingListWebSocketController {

    @MessageMapping("/updateShoppingList")
    @SendTo("/topic/shoppingListUpdates")
    public ShoppingList sendUpdate(ShoppingList shoppingList) {
        return shoppingList;
    }
}
