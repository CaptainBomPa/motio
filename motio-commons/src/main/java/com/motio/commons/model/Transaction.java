package com.motio.commons.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "transactions")
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String title;

    @ManyToOne
    @JoinColumn(name = "from_user_id", nullable = false)
    private User fromUser;

    @ManyToOne
    @JoinColumn(name = "to_user_id", nullable = false)
    private User toUser;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private LocalDateTime transactionDate;

    @ManyToOne
    @JoinColumn(name = "debt_id", nullable = false)
    @JsonBackReference
    @ToString.Exclude
    private Debt debt;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Transaction that)) return false;
        return getTitle().equals(that.getTitle()) &&
                getFromUser().equals(that.getFromUser()) &&
                getToUser().equals(that.getToUser()) &&
                getAmount().equals(that.getAmount()) &&
                getTransactionDate().equals(that.getTransactionDate()) &&
                getDebt().equals(that.getDebt());
    }

    @Override
    public int hashCode() {
        return Objects.hash(getTitle(), getFromUser(), getToUser(), getAmount(), getTransactionDate(), getDebt());
    }
}
