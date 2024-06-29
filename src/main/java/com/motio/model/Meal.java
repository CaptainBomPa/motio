package com.motio.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
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
@Table(name = "meals")
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Meal name is mandatory")
    @Column(nullable = false)
    private String mealName;

    @ManyToOne
    @JoinColumn(name = "created_by_user_id", nullable = false)
    private User createdByUser;

    @ManyToMany
    @JoinTable(
            name = "meal_user_access",
            joinColumns = @JoinColumn(name = "meal_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    private Set<User> accessibleUsers = new HashSet<>();

    @ManyToMany
    @JoinTable(
            name = "meal_and_meal_category_association",
            joinColumns = @JoinColumn(name = "meal_id"),
            inverseJoinColumns = @JoinColumn(name = "meal_category_id")
    )
    private Set<MealCategory> categories;

    @ElementCollection
    @CollectionTable(name = "meal_steps", joinColumns = @JoinColumn(name = "meal_id"))
    @Column(name = "step")
    private List<String> steps = new LinkedList<>();

    @ElementCollection
    @CollectionTable(name = "meal_ingredients", joinColumns = @JoinColumn(name = "meal_id"))
    @Column(name = "ingredient")
    private List<String> ingredients = new LinkedList<>();

    @Column
    private String imagePath;
}
