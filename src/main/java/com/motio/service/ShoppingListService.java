package com.motio.service;

import com.motio.model.ShoppingItem;
import com.motio.model.ShoppingList;

import java.util.List;

public interface ShoppingListService {
    ShoppingList saveShoppingList(ShoppingList shoppingList, String username);

    ShoppingList updateShoppingList(Long id, ShoppingList shoppingList);

    void deleteShoppingList(Long id);

    ShoppingList getShoppingListById(Long id);

    List<ShoppingList> getAllShoppingLists();

    ShoppingList updateItemsInShoppingList(Long shoppingListId, List<ShoppingItem> items);
}
