package com.motio.core.service.sender;

import com.motio.commons.model.TodoList;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class TodoListUpdateSender {
    public static final String TODO_LIST_UPDATES_TOPIC = "/topic/todo/ListUpdates";
    private final SimpMessagingTemplate messagingTemplate;

    public TodoListUpdateSender(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    public void sendUpdate(TodoList todoList) {
        messagingTemplate.convertAndSend(TODO_LIST_UPDATES_TOPIC, todoList);
    }
}