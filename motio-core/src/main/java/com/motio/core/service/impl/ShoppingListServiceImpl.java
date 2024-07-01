package com.motio.core.service.impl;

import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.ShoppingItem;
import com.motio.commons.model.ShoppingList;
import com.motio.commons.model.User;
import com.motio.commons.repository.UserRepository;
import com.motio.core.repository.ShoppingItemRepository;
import com.motio.core.repository.ShoppingListRepository;
import com.motio.core.service.ShoppingListService;
import com.motio.core.service.sender.ShoppingListUpdateSender;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ShoppingListServiceImpl implements ShoppingListService {
    private final ShoppingListRepository shoppingListRepository;
    private final ShoppingItemRepository shoppingItemRepository;
    private final UserRepository userRepository;
    private final ShoppingListUpdateSender updateSender;

    @Override
    public ShoppingList saveShoppingList(ShoppingList shoppingList, String username) {
        User user = userRepository.findByUsername(username).orElseThrow(UserNotFoundException::new);
        shoppingList.setCreatedByUser(user);
        return shoppingListRepository.save(shoppingList);
    }

    @Override
    public ShoppingList updateShoppingList(Long id, ShoppingList shoppingList) {
        ShoppingList updatedList = shoppingListRepository.findById(id).map(existingList -> {
            existingList.setListName(shoppingList.getListName());
            existingList.setItems(shoppingList.getItems());
            existingList.setAccessibleUsers(shoppingList.getAccessibleUsers());
            return shoppingListRepository.save(existingList);
        }).orElseThrow(() -> new GenericObjectNotFoundException(ShoppingList.class));

        updateSender.sendUpdate(updatedList);

        return updatedList;
    }

    @Override
    public void deleteShoppingList(Long id) {
        shoppingListRepository.deleteById(id);
    }

    @Override
    public ShoppingList getShoppingListById(Long id) {
        return shoppingListRepository.findById(id).orElseThrow(() -> new GenericObjectNotFoundException(ShoppingList.class));
    }

    @Override
    public List<ShoppingList> getAllShoppingLists() {
        return shoppingListRepository.findAll();
    }

    @Override
    public ShoppingList updateItemsInShoppingList(Long shoppingListId, List<ShoppingItem> items) {
        ShoppingList shoppingList = getShoppingListById(shoppingListId);
        shoppingList.getItems().clear();
        shoppingList.getItems().addAll(items);
        shoppingItemRepository.saveAll(items);
        ShoppingList updatedList = shoppingListRepository.save(shoppingList);
        updateSender.sendUpdate(updatedList);
        return updatedList;
    }
}
