package com.lumina.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

// Datos para crear o editar un producto
public record ProductRequest(

    @NotBlank(message = "El nombre es obligatorio.")
    @Size(max = 120, message = "El nombre es muy largo.")
    String name,

    // si viene vacío, se arma solo a partir del nombre (Noche de Paz -> noche-de-paz)
    @Size(max = 140, message = "El slug es muy largo.")
    String slug,

    @Size(max = 500, message = "La URL de la imagen es muy larga.")
    String imageUrl,

    @NotBlank(message = "La categoría es obligatoria.")
    @Size(max = 80, message = "La categoría es muy larga.")
    String category,

    @Size(max = 120, message = "El aroma es muy largo.")
    String scent,

    @Min(value = 1, message = "El peso debe ser mayor a 0.")
    Integer weightGrams,

    @Size(max = 120, message = "El color es muy largo.")
    String color,

    String description,

    @NotNull(message = "El precio es obligatorio.")
    @DecimalMin(value = "0.0", inclusive = false, message = "El precio debe ser mayor a 0.")
    BigDecimal price,

    @NotNull(message = "El stock es obligatorio.")
    @Min(value = 0, message = "El stock no puede ser negativo.")
    Integer stock,

    Boolean available) {
}
