package com.motio.core.service.impl

import com.motio.commons.exception.throwable.DebtAlreadyExistsException
import com.motio.commons.model.Debt
import com.motio.commons.model.Transaction
import com.motio.commons.model.User
import com.motio.commons.service.UserService
import com.motio.core.repository.DebtRepository
import com.motio.core.service.DebtService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import spock.lang.Specification

import java.time.LocalDateTime

@DataJpaTest
class DebtServiceImplSpec extends Specification {

    @Autowired
    DebtRepository debtRepository
    @Autowired
    UserService userService
    @Autowired
    TestEntityManager entityManager
    DebtService debtService

    void setup() {
        debtService = new DebtServiceImpl(debtRepository, userService)
    }

    def "should create debt"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt = new Debt(user1: user1, user2: user2)

        when:
        Debt createdDebt = debtService.createDebt(debt)

        then:
        createdDebt != null
        createdDebt.getId() != null
        createdDebt.getBalance() == BigDecimal.ZERO
        createdDebt.getUser1() == user1
        createdDebt.getUser2() == user2
        createdDebt.getTransactionHistories().isEmpty()
    }

    def "should not create duplicate debt"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def existingDebt = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        entityManager.persistAndFlush(existingDebt)
        def newDebt = new Debt(user1: user1, user2: user2)

        when:
        debtService.createDebt(newDebt)

        then:
        thrown(DebtAlreadyExistsException)
    }

    def "should add transaction"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        entityManager.persistAndFlush(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan")

        when:
        Transaction createdTransaction = debtService.addTransaction(transaction)

        then:
        createdTransaction != null
        createdTransaction.getId() != null
        debt.getTransactionHistories().contains(createdTransaction)
        debt.getBalance() == new BigDecimal("100.00")
        createdTransaction.getTransactionDate() != null
    }

    def "should update transaction"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        entityManager.persistAndFlush(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan", debt: debt, transactionDate: LocalDateTime.now())
        debt.getTransactionHistories().add(transaction)
        debt.setBalance(new BigDecimal(100.0))
        entityManager.persistAndFlush(debt)
        transaction.setId(entityManager.persistAndGetId(transaction))

        def updatedTransaction = new Transaction(id: transaction.getId(), fromUser: user1, toUser: user2, amount: new BigDecimal("150.00"), title: "Updated Loan")

        when:
        Transaction result = debtService.updateTransaction(updatedTransaction)

        then:
        result != null
        result.getAmount() == new BigDecimal("150.00")
        debt.getBalance() == new BigDecimal("150.00")
    }

    def "should delete transaction"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt = new Debt(user1: user1, user2: user2, balance: new BigDecimal("100.00"))
        entityManager.persistAndFlush(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan", debt: debt, transactionDate: LocalDateTime.now())
        debt.getTransactionHistories().add(transaction)
        entityManager.persistAndFlush(debt)
        transaction.setId(entityManager.persistAndGetId(transaction))

        when:
        debtService.deleteTransaction(transaction.getId())

        then:
        debt.getTransactionHistories().isEmpty()
        debt.getBalance() == BigDecimal.ZERO
    }

    def "should get debts for user"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt1 = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        def debt2 = new Debt(user1: user2, user2: user1, balance: BigDecimal.ZERO)
        entityManager.persistAndFlush(debt1)
        entityManager.persistAndFlush(debt2)

        when:
        List<Debt> debts = debtService.getDebtsForUser(user1.getUsername())

        then:
        debts.size() == 2
        debts.contains(debt1)
        debts.contains(debt2)
    }

    def "should get debt by ID"() {
        given:
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        entityManager.persistAndFlush(user1)
        entityManager.persistAndFlush(user2)
        def debt = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        entityManager.persistAndFlush(debt)
        Long debtId = debt.getId()

        when:
        Debt foundDebt = debtService.getDebtById(debtId)

        then:
        foundDebt != null
        foundDebt.getId() == debtId
    }
}
