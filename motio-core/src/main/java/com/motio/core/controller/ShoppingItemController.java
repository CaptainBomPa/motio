package com.motio.core.controller;

import com.motio.commons.model.ShoppingItem;
import com.motio.core.service.ShoppingItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/shopping-items")
@RequiredArgsConstructor
@Tag(name = "Shopping Item Management", description = "Operations pertaining to shopping items in Shopping Management System")
public class ShoppingItemController {
    private final ShoppingItemService shoppingItemService;

    @PostMapping
    @Operation(summary = "Create a new shopping item", description = "Create a new shopping item in the system", tags = {"Shopping Item Management"})
    public ResponseEntity<ShoppingItem> createShoppingItem(@RequestBody ShoppingItem shoppingItem) {
        ShoppingItem createdShoppingItem = shoppingItemService.saveShoppingItem(shoppingItem);
        return ResponseEntity.ok(createdShoppingItem);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing shopping item", description = "Update the details of an existing shopping item", tags = {"Shopping Item Management"})
    public ResponseEntity<ShoppingItem> updateShoppingItem(@PathVariable Long id, @RequestBody ShoppingItem shoppingItem) {
        ShoppingItem updatedShoppingItem = shoppingItemService.updateShoppingItem(id, shoppingItem);
        return ResponseEntity.ok(updatedShoppingItem);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a shopping item", description = "Delete a shopping item from the system", tags = {"Shopping Item Management"})
    public ResponseEntity<Void> deleteShoppingItem(@PathVariable Long id) {
        shoppingItemService.deleteShoppingItem(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a shopping item by ID", description = "Retrieve a shopping item by its ID", tags = {"Shopping Item Management"})
    public ResponseEntity<ShoppingItem> getShoppingItemById(@PathVariable Long id) {
        ShoppingItem shoppingItem = shoppingItemService.getShoppingItemById(id);
        return ResponseEntity.ok(shoppingItem);
    }

    @GetMapping
    @Operation(summary = "Get all shopping items", description = "Retrieve a list of all shopping items", tags = {"Shopping Item Management"})
    public ResponseEntity<List<ShoppingItem>> getAllShoppingItems() {
        List<ShoppingItem> shoppingItems = shoppingItemService.getAllShoppingItems();
        return ResponseEntity.ok(shoppingItems);
    }
}
