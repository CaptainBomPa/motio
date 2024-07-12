package com.motio.core.controller;

import com.motio.commons.model.Debt;
import com.motio.commons.model.Transaction;
import com.motio.core.service.DebtService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/debts")
@RequiredArgsConstructor
@Tag(name = "Debt Management System", description = "Operations pertaining to debts and transactions")
public class DebtController {
    private final DebtService debtService;

    @PostMapping
    @Operation(summary = "Create a new debt", description = "Create a new debt between two users", tags = {"Debt Management System"})
    public ResponseEntity<Debt> createDebt(@RequestBody Debt debt) {
        Debt createdDebt = debtService.createDebt(debt);
        return ResponseEntity.ok(createdDebt);
    }

    @PostMapping("/transaction")
    @Operation(summary = "Add a new transaction", description = "Add a new transaction to an existing debt", tags = {"Debt Management System"})
    public ResponseEntity<Transaction> addTransaction(@RequestBody Transaction transaction) {
        Transaction createdTransaction = debtService.addTransaction(transaction);
        return ResponseEntity.ok(createdTransaction);
    }

    @PutMapping("/transaction")
    @Operation(summary = "Update an existing transaction", description = "Update an existing transaction within a debt", tags = {"Debt Management System"})
    public ResponseEntity<Transaction> updateTransaction(@RequestBody Transaction transaction) {
        Transaction updatedTransaction = debtService.updateTransaction(transaction);
        return ResponseEntity.ok(updatedTransaction);
    }

    @DeleteMapping("/transaction/{id}")
    @Operation(summary = "Delete a transaction", description = "Delete a transaction from a debt by transaction ID", tags = {"Debt Management System"})
    public ResponseEntity<Void> deleteTransaction(@PathVariable Long id) {
        debtService.deleteTransaction(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping
    @Operation(summary = "Get debts for user", description = "Retrieve all debts associated with the authenticated user", tags = {"Debt Management System"})
    public ResponseEntity<List<Debt>> getDebtsForUser(Authentication authentication) {
        List<Debt> debts = debtService.getDebtsForUser(authentication.getName());
        return ResponseEntity.ok(debts);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a debt by ID", description = "Retrieve a debt by its ID", tags = {"Debt Management System"})
    public ResponseEntity<Debt> getDebtById(@PathVariable Long id) {
        Debt debt = debtService.getDebtById(id);
        return ResponseEntity.ok(debt);
    }
}
