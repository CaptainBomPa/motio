package com.motio.core.service;

import com.motio.commons.model.Debt;
import com.motio.commons.model.Transaction;

import java.util.List;

public interface DebtService {
    Debt createDebt(Debt debt);

    Transaction addTransaction(Transaction transaction);

    Transaction updateTransaction(Transaction transaction);

    void deleteTransaction(Long id);

    List<Debt> getDebtsForUser(String username);

    Debt getDebtById(Long id);
}
