package com.motio.core.config.dev.impl;

import com.motio.commons.model.Debt;
import com.motio.commons.model.Transaction;
import com.motio.commons.model.User;
import com.motio.core.config.dev.ModelInitializer;
import com.motio.core.repository.DebtRepository;
import com.motio.core.service.DebtService;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.Validate;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.stream.IntStream;

@Component
@RequiredArgsConstructor
public class DebtModelInitializer implements ModelInitializer<Debt> {
    private static final Random random = new Random();
    private static final List<String> possibleTitles = List.of(
            "Loan", "Dinner", "Rent", "Groceries", "Tickets", "Fuel", "Utilities", "Gift", "Party", "Holiday"
    );
    private final DebtService debtService;
    private final DebtRepository debtRepository;
    private Collection<User> providedUsers;

    @Override
    @SuppressWarnings("unchecked")
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        if (type.isAssignableFrom(User.class)) {
            providedUsers = (Collection<User>) objects;
        } else {
            throw new RuntimeException("Could not apply context objects during data initialization");
        }
    }

    @Override
    public Collection<Debt> initializeObjects() {
        Validate.notEmpty(providedUsers);

        List<User> users = List.copyOf(providedUsers);

        List<Debt> loadedDebts = new LinkedList<>();

        IntStream.range(1, 21).forEach(i -> {
            User user1 = users.get(random.nextInt(users.size()));
            User user2 = users.stream().filter(user -> !user.equals(user1)).toList().get(random.nextInt(users.size() - 1));

            if (debtRepository.existsByUser1AndUser2(user1, user2) || debtRepository.existsByUser1AndUser2(user2, user1)) {
                // Skip if the debt already exists between these users
                return;
            }

            Debt debt = new Debt();
            debt.setUser1(user1);
            debt.setUser2(user2);
            debt.setBalance(BigDecimal.ZERO);

            List<Transaction> transactions = new LinkedList<>();
            int transactionCount = 5 + random.nextInt(6); // Generate between 5 and 10 transactions

            for (int j = 0; j < transactionCount; j++) {
                Transaction transaction = new Transaction();
                transaction.setTitle(possibleTitles.get(random.nextInt(possibleTitles.size())));
                transaction.setFromUser(random.nextBoolean() ? user1 : user2);
                transaction.setToUser(transaction.getFromUser().equals(user1) ? user2 : user1);
                transaction.setAmount(BigDecimal.valueOf(random.nextInt(1000) + 1).setScale(2, BigDecimal.ROUND_HALF_UP));
                transaction.setTransactionDate(LocalDateTime.now().minusDays(random.nextInt(100)));
                transaction.setDebt(debt);
                transactions.add(transaction);
                debt.setBalance(debt.getBalance().add(transaction.getFromUser().equals(user1) ? transaction.getAmount() : transaction.getAmount().negate()));
            }

            debt.setTransactionHistories(transactions);
            loadedDebts.add(debtService.createDebt(debt));
        });

        return loadedDebts;
    }

    @Override
    public void destroy() {
        // do nothing
    }
}
