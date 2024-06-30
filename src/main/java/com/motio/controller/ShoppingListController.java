package com.motio.controller;

import com.motio.model.ShoppingItem;
import com.motio.model.ShoppingList;
import com.motio.service.ShoppingListService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/shopping-lists")
@RequiredArgsConstructor
@Tag(name = "Shopping List Management", description = "Operations pertaining to shopping lists in Shopping Management System")
public class ShoppingListController {
    private final ShoppingListService shoppingListService;

    @PostMapping
    @Operation(summary = "Create a new shopping list", description = "Create a new shopping list in the system", tags = {"Shopping List Management"})
    public ResponseEntity<ShoppingList> createShoppingList(@RequestBody ShoppingList shoppingList, Authentication authentication) {
        ShoppingList createdShoppingList = shoppingListService.saveShoppingList(shoppingList, authentication.getName());
        return ResponseEntity.ok(createdShoppingList);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing shopping list", description = "Update the details of an existing shopping list", tags = {"Shopping List Management"})
    public ResponseEntity<ShoppingList> updateShoppingList(@PathVariable Long id, @RequestBody ShoppingList shoppingList) {
        ShoppingList updatedShoppingList = shoppingListService.updateShoppingList(id, shoppingList);
        return ResponseEntity.ok(updatedShoppingList);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a shopping list", description = "Delete a shopping list from the system", tags = {"Shopping List Management"})
    public ResponseEntity<Void> deleteShoppingList(@PathVariable Long id) {
        shoppingListService.deleteShoppingList(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a shopping list by ID", description = "Retrieve a shopping list by its ID", tags = {"Shopping List Management"})
    public ResponseEntity<ShoppingList> getShoppingListById(@PathVariable Long id) {
        ShoppingList shoppingList = shoppingListService.getShoppingListById(id);
        return ResponseEntity.ok(shoppingList);
    }

    @GetMapping
    @Operation(summary = "Get all shopping lists", description = "Retrieve a list of all shopping lists", tags = {"Shopping List Management"})
    public ResponseEntity<List<ShoppingList>> getAllShoppingLists() {
        List<ShoppingList> shoppingLists = shoppingListService.getAllShoppingLists();
        return ResponseEntity.ok(shoppingLists);
    }

    @PutMapping("/{shoppingListId}/items")
    @Operation(summary = "Add items to a shopping list", description = "Add or update items in a shopping list", tags = {"Shopping List Management"})
    public ResponseEntity<ShoppingList> updateItemsInShoppingList(@PathVariable Long shoppingListId, @RequestBody List<ShoppingItem> items) {
        ShoppingList updatedShoppingList = shoppingListService.updateItemsInShoppingList(shoppingListId, items);
        return ResponseEntity.ok(updatedShoppingList);
    }
}
