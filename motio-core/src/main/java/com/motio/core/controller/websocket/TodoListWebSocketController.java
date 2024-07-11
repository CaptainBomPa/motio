package com.motio.core.controller.websocket;

import com.motio.commons.model.TodoList;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class TodoListWebSocketController {

    @MessageMapping("/updateTodoList")
    @SendTo("/topic/todoListUpdates")
    public TodoList sendUpdate(TodoList todoList) {
        return todoList;
    }
}
