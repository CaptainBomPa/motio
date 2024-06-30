package com.motio.service.impl;

import com.motio.exception.throwable.GenericObjectNotFoundException;
import com.motio.exception.throwable.UserNotFoundException;
import com.motio.model.ShoppingItem;
import com.motio.model.ShoppingList;
import com.motio.model.User;
import com.motio.repository.ShoppingItemRepository;
import com.motio.repository.ShoppingListRepository;
import com.motio.repository.UserRepository;
import com.motio.service.ShoppingListService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ShoppingListServiceImpl implements ShoppingListService {
    private final ShoppingListRepository shoppingListRepository;
    private final ShoppingItemRepository shoppingItemRepository;
    private final UserRepository userRepository;

    @Override
    public ShoppingList saveShoppingList(ShoppingList shoppingList, String username) {
        User user = userRepository.findByUsername(username).orElseThrow(UserNotFoundException::new);
        shoppingList.setCreatedByUser(user);
        return shoppingListRepository.save(shoppingList);
    }

    @Override
    public ShoppingList updateShoppingList(Long id, ShoppingList shoppingList) {
        return shoppingListRepository.findById(id).map(existingList -> {
            existingList.setListName(shoppingList.getListName());
            existingList.setItems(shoppingList.getItems());
            existingList.setAccessibleUsers(shoppingList.getAccessibleUsers());
            return shoppingListRepository.save(existingList);
        }).orElseThrow(() -> new GenericObjectNotFoundException(ShoppingList.class));
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
        return shoppingListRepository.save(shoppingList);
    }
}
