package com.motio.core.service.notification;

import com.motio.commons.model.TodoList;
import com.motio.commons.model.User;

public interface TodoListNotificationSender {

    void sendAddNewSharedUsers(TodoList todoList, User newSharedUser);
}
