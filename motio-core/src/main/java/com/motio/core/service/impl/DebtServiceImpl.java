package com.motio.core.service.impl;

import com.motio.commons.exception.throwable.DebtAlreadyExistsException;
import com.motio.commons.exception.throwable.DebtNotFoundException;
import com.motio.commons.exception.throwable.TransactionNotFoundException;
import com.motio.commons.exception.throwable.UserNotFoundException;
import com.motio.commons.model.Debt;
import com.motio.commons.model.Transaction;
import com.motio.commons.model.User;
import com.motio.commons.service.UserService;
import com.motio.core.repository.DebtRepository;
import com.motio.core.service.DebtService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DebtServiceImpl implements DebtService {
    private final DebtRepository debtRepository;
    private final UserService userService;

    @Override
    @Transactional
    public Debt createDebt(Debt debt) {
        final Long user1Id = debt.getUser1().getId();
        final Long user2Id = debt.getUser2().getId();
        boolean debtExists = debtRepository.findAll().stream()
                .anyMatch(existingDebt -> (existingDebt.getUser1().getId().equals(user1Id) && existingDebt.getUser2().getId().equals(user2Id)) ||
                        (existingDebt.getUser1().getId().equals(user2Id) && existingDebt.getUser2().getId().equals(user1Id)));

        if (debtExists) {
            throw new DebtAlreadyExistsException(user1Id, user2Id);
        }

        debt.setBalance(BigDecimal.ZERO);
        return sortTransactionHistories(debtRepository.save(debt));
    }

    @Override
    @Transactional
    public Transaction addTransaction(Transaction transaction) {
        Debt debt = findDebtByUsers(transaction.getFromUser().getId(), transaction.getToUser().getId());
        updateDebtBalance(debt, transaction.getFromUser(), transaction.getToUser(), transaction.getAmount());
        transaction.setTransactionDate(LocalDateTime.now());
        debt.getTransactionHistories().add(transaction);
        transaction.setDebt(debt);
        return sortTransactionHistories(debtRepository.save(debt)).getTransactionHistories().stream()
                .filter(t -> t.equals(transaction))
                .findFirst()
                .orElseThrow(() -> new TransactionNotFoundException(transaction.getId()));
    }

    @Override
    @Transactional
    public Transaction updateTransaction(Transaction transaction) {
        Debt debt = findDebtByUsers(transaction.getFromUser().getId(), transaction.getToUser().getId());

        Transaction existingTransaction = debt.getTransactionHistories().stream()
                .filter(t -> t.getId().equals(transaction.getId()))
                .findFirst()
                .orElseThrow(() -> new TransactionNotFoundException(transaction.getId()));

        BigDecimal difference = transaction.getAmount().subtract(existingTransaction.getAmount());
        updateDebtBalance(debt, existingTransaction.getFromUser(), existingTransaction.getToUser(), difference);

        existingTransaction.setAmount(transaction.getAmount());
        existingTransaction.setTitle(transaction.getTitle());
        existingTransaction.setTransactionDate(transaction.getTransactionDate());
        existingTransaction.setDebt(debt);
        debtRepository.save(debt);

        return sortTransactionHistories(debt).getTransactionHistories().stream()
                .filter(t -> t.getId().equals(transaction.getId()))
                .findFirst()
                .orElseThrow(() -> new TransactionNotFoundException(transaction.getId()));
    }

    @Override
    @Transactional
    public void deleteTransaction(Long id) {
        Transaction existingTransaction = debtRepository.findAll().stream()
                .flatMap(debt -> debt.getTransactionHistories().stream())
                .filter(transaction -> transaction.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new TransactionNotFoundException(id));

        Debt debt = existingTransaction.getDebt();
        updateDebtBalance(debt, existingTransaction.getFromUser(), existingTransaction.getToUser(), existingTransaction.getAmount().negate());
        debt.getTransactionHistories().remove(existingTransaction);
        debtRepository.save(debt);
    }


    @Override
    public List<Debt> getDebtsForUser(String username) {
        User user = userService.getUserByUsername(username).orElseThrow(() -> new UserNotFoundException(username));
        return debtRepository.findAll().stream()
                .filter(debt -> debt.getUser1().equals(user) || debt.getUser2().equals(user))
                .map(this::sortTransactionHistories)
                .toList();
    }

    @Override
    public Debt getDebtById(Long id) {
        return debtRepository.findById(id)
                .map(this::sortTransactionHistories)
                .orElseThrow(() -> new DebtNotFoundException(id));
    }

    private Debt findDebtByUsers(Long user1Id, Long user2Id) {
        return debtRepository.findAll().stream()
                .filter(debt -> (debt.getUser1().getId().equals(user1Id) && debt.getUser2().getId().equals(user2Id)) ||
                        (debt.getUser1().getId().equals(user2Id) && debt.getUser2().getId().equals(user1Id)))
                .findFirst()
                .orElseThrow(DebtNotFoundException::new);
    }

    private void updateDebtBalance(Debt debt, User fromUser, User toUser, BigDecimal amount) {
        if (fromUser.equals(debt.getUser1()) && toUser.equals(debt.getUser2())) {
            debt.setBalance(debt.getBalance().add(amount));
        } else if (fromUser.equals(debt.getUser2()) && toUser.equals(debt.getUser1())) {
            debt.setBalance(debt.getBalance().subtract(amount));
        } else {
            throw new DebtNotFoundException();
        }
    }

    private Debt sortTransactionHistories(Debt debt) {
        debt.getTransactionHistories().sort(Comparator.comparing(Transaction::getTransactionDate).reversed());
        return debt;
    }
}
