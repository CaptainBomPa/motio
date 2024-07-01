package com.motio.core.service;


import com.motio.commons.model.ShoppingItem;

import java.util.List;

public interface ShoppingItemService {
    ShoppingItem saveShoppingItem(ShoppingItem shoppingItem);

    ShoppingItem updateShoppingItem(Long id, ShoppingItem shoppingItem);

    void deleteShoppingItem(Long id);

    ShoppingItem getShoppingItemById(Long id);

    List<ShoppingItem> getAllShoppingItems();
}
