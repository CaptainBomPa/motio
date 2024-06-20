package com.motio.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "meal_categories")
public class MealCategory {

    @Id
    @NotBlank(message = "Category name is mandatory")
    @Column(nullable = false, unique = true)
    private String name;

    @NotBlank(message = "Image URL link is mandatory")
    @Column(nullable = false)
    private String imageUrl;
}
