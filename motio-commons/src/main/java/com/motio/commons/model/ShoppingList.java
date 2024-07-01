package com.motio.commons.model;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "shopping_list")
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
public class ShoppingList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String listName;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ShoppingItem> items = new LinkedList<>();

    @ManyToOne
    @JoinColumn(name = "created_by_user_id", nullable = false)
    private User createdByUser;

    @ManyToMany
    @JoinTable(
            name = "shopping_list_access",
            joinColumns = @JoinColumn(name = "shopping_list_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    private Set<User> accessibleUsers = new HashSet<>();
}
