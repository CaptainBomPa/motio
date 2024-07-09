package com.motio.core.service;


import com.motio.commons.model.ShoppingItem;
import com.motio.commons.model.ShoppingList;
import org.springframework.security.core.Authentication;

import java.util.List;

public interface ShoppingListService {
    ShoppingList saveShoppingList(ShoppingList shoppingList, String username);

    ShoppingList updateShoppingList(Long id, ShoppingList shoppingList);

    void deleteShoppingList(Long id);

    ShoppingList getShoppingListById(Long id);

    List<ShoppingList> getAllShoppingLists(Authentication authentication);

    ShoppingList updateItemsInShoppingList(Long shoppingListId, List<ShoppingItem> items);
}
