package com.motio.service.impl;

import com.motio.exception.throwable.GenericObjectNotFoundException;
import com.motio.model.ShoppingItem;
import com.motio.repository.ShoppingItemRepository;
import com.motio.service.ShoppingItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ShoppingItemServiceImpl implements ShoppingItemService {
    private final ShoppingItemRepository shoppingItemRepository;

    @Override
    public ShoppingItem saveShoppingItem(ShoppingItem shoppingItem) {
        return shoppingItemRepository.save(shoppingItem);
    }

    @Override
    public ShoppingItem updateShoppingItem(Long id, ShoppingItem shoppingItem) {
        return shoppingItemRepository.findById(id).map(existingItem -> {
            existingItem.setChecked(shoppingItem.isChecked());
            existingItem.setDescription(shoppingItem.getDescription());
            return shoppingItemRepository.save(existingItem);
        }).orElseThrow(() -> new GenericObjectNotFoundException(ShoppingItem.class));
    }

    @Override
    public void deleteShoppingItem(Long id) {
        shoppingItemRepository.deleteById(id);
    }

    @Override
    public ShoppingItem getShoppingItemById(Long id) {
        return shoppingItemRepository.findById(id)
                .orElseThrow(() -> new GenericObjectNotFoundException(ShoppingItem.class));
    }

    @Override
    public List<ShoppingItem> getAllShoppingItems() {
        return shoppingItemRepository.findAll();
    }
}
