package com.motio.core.config.dev.impl;

import com.motio.commons.model.TodoItem;
import com.motio.commons.model.TodoList;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.service.TodoListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Component
@RequiredArgsConstructor
public class TodoListItemModelInitializer implements ModelInitializer<TodoList> {
    private static final Random random = new Random();
    private final TodoListService todoListService;
    private final UserService userService;

    private final List<String> LIST_NAMES = List.of("Zakupy na dziś", "Na impreze", "Do pracy", "Na wyjazd", "Na wakacje");
    private final List<String> ITEM_NAMES = List.of("Pomidory 3 sztuki", "Kiełbasa", "Keczup", "Kebab", "Nowe klapki", "Podkoszulek", "Opakowanie jajek",
            "Burgery", "Wódka");

    private static <T> List<T> getRandomElements(List<T> list, int count) {
        return random.ints(0, list.size())
                .distinct()
                .limit(count)
                .mapToObj(list::get)
                .collect(Collectors.toList());
    }

    @Override
    public Collection<TodoList> initializeObjects() {
        final List<TodoList> loadedLists = new LinkedList<>();
        final List<User> users = userService.getAllUsers();

        IntStream.range(1, 15).forEach(i -> {
            TodoList todoList = new TodoList();
            todoList.setListName(LIST_NAMES.get(random.nextInt(LIST_NAMES.size())));
            User selectedUser = users.get(random.nextInt(users.size()));
            Set<User> sharedUsers = new HashSet<>(getRandomElements(users, users.size()));
            todoList.setAccessibleUsers(sharedUsers);

            List<TodoItem> todoItems = new LinkedList<>();
            getRandomElements(ITEM_NAMES, random.nextInt(8))
                    .forEach(name -> todoItems.add(TodoItem.builder().checked(false).description(name).build()));
            todoList.setItems(todoItems);
            loadedLists.add(todoListService.saveTodoList(todoList, selectedUser.getUsername()));
        });

        return loadedLists;
    }

    @Override
    public void addContextObjects(Collection<?> objects, Class<?> type) {

    }

    @Override
    public void destroy() throws Exception {

    }
}
