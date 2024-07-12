package com.motio.core.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.motio.commons.model.Debt
import com.motio.commons.model.Transaction
import com.motio.commons.model.User
import com.motio.commons.repository.UserRepository
import com.motio.core.repository.DebtRepository
import com.motio.core.service.DebtService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.MockMvc
import spock.lang.Specification

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
class DebtControllerTest extends Specification {

    @Autowired
    MockMvc mockMvc
    @Autowired
    DebtService debtService
    @Autowired
    DebtRepository debtRepository
    @Autowired
    UserRepository userRepository
    @Autowired
    ObjectMapper objectMapper

    void setup() {
        debtRepository.deleteAll()
        userRepository.deleteAll()
    }

    void cleanup() {
        debtRepository.deleteAll()
        userRepository.deleteAll()
    }

    @WithMockUser(username = "user1")
    def "test creating a debt"() {
        given: "Two users and a debt object"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def debt = new Debt(user1: user1, user2: user2)

        expect:
        mockMvc.perform(post("/debts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(debt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.user1.username').value("user1"))
                .andExpect(jsonPath('$.user2.username').value("user2"))
                .andExpect(jsonPath('$.balance').value(0))
    }

    @WithMockUser(username = "user1")
    def "test adding a transaction"() {
        given: "Two users and a debt with a transaction"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def debt = new Debt(user1: user1, user2: user2)
        debtService.createDebt(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan")

        expect:
        mockMvc.perform(post("/debts/transaction")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(transaction)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.fromUser.username').value("user1"))
                .andExpect(jsonPath('$.toUser.username').value("user2"))
                .andExpect(jsonPath('$.amount').value(100.0))
    }

    @WithMockUser(username = "user1")
    def "test updating a transaction"() {
        given: "Two users and a debt with a transaction to update"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def debt = new Debt(user1: user1, user2: user2)
        debtService.createDebt(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan")
        def addedTransaction = debtService.addTransaction(transaction)
        addedTransaction.amount = new BigDecimal("150.00")
        addedTransaction.title = "Updated Loan"

        expect:
        mockMvc.perform(put("/debts/transaction")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(addedTransaction)))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.amount').value(150.0))
                .andExpect(jsonPath('$.title').value("Updated Loan"))
    }

    @WithMockUser(username = "user1")
    def "test deleting a transaction"() {
        given: "Two users and a debt with a transaction to delete"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def debt = new Debt(user1: user1, user2: user2)
        debtService.createDebt(debt)
        def transaction = new Transaction(fromUser: user1, toUser: user2, amount: new BigDecimal("100.00"), title: "Loan")
        def addedTransaction = debtService.addTransaction(transaction)

        expect:
        mockMvc.perform(delete("/debts/transaction/${addedTransaction.getId()}")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(transaction)))
                .andExpect(status().isNoContent())
    }

    @WithMockUser(username = "user1")
    def "test getting debts for user"() {
        given: "A user with multiple debts"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        def user3 = new User(username: "user3", firstName: "Jim", lastName: "Beam", password: "password", email: "jim.beam@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        userRepository.save(user3)
        def debt1 = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        def debt2 = new Debt(user1: user1, user2: user3, balance: BigDecimal.ZERO)
        debtService.createDebt(debt1)
        debtService.createDebt(debt2)

        expect:
        mockMvc.perform(get("/debts")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$[0].user1.username').value("user1"))
                .andExpect(jsonPath('$[1].user1.username').value("user1"))
    }

    @WithMockUser(username = "user1")
    def "test getting debt by ID"() {
        given: "A debt with a specific ID"
        def user1 = new User(username: "user1", firstName: "John", lastName: "Doe", password: "password", email: "john.doe@example.com")
        def user2 = new User(username: "user2", firstName: "Jane", lastName: "Doe", password: "password", email: "jane.doe@example.com")
        userRepository.save(user1)
        userRepository.save(user2)
        def debt = new Debt(user1: user1, user2: user2, balance: BigDecimal.ZERO)
        debtService.createDebt(debt)
        def debtId = debt.getId()

        expect:
        mockMvc.perform(get("/debts/${debtId}")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath('$.user1.username').value("user1"))
                .andExpect(jsonPath('$.user2.username').value("user2"))
                .andExpect(jsonPath('$.balance').value(0))
    }
}
