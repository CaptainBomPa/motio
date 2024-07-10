package com.motio.core.config.dev.impl;

import com.motio.commons.model.ShoppingItem;
import com.motio.commons.model.ShoppingList;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.service.ShoppingListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Component
@RequiredArgsConstructor
public class ShoppingListItemModelInitializer implements ModelInitializer<ShoppingList> {
    private static final Random random = new Random();
    private final ShoppingListService shoppingListService;
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
    public Collection<ShoppingList> initializeObjects() {
        final List<ShoppingList> loadedLists = new LinkedList<>();
        final List<User> users = userService.getAllUsers();

        IntStream.range(1, 15).forEach(i -> {
            ShoppingList shoppingList = new ShoppingList();
            shoppingList.setListName(LIST_NAMES.get(random.nextInt(LIST_NAMES.size())));
            User selectedUser = users.get(random.nextInt(users.size()));
            Set<User> sharedUsers = new HashSet<>(getRandomElements(users, users.size()));
            shoppingList.setAccessibleUsers(sharedUsers);

            List<ShoppingItem> shoppingItems = new LinkedList<>();
            getRandomElements(ITEM_NAMES, random.nextInt(8))
                    .forEach(name -> shoppingItems.add(ShoppingItem.builder().checked(false).description(name).build()));
            shoppingList.setItems(shoppingItems);
            loadedLists.add(shoppingListService.saveShoppingList(shoppingList, selectedUser.getUsername()));
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
