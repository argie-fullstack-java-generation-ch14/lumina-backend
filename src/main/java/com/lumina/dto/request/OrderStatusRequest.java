package com.lumina.dto.request;

import jakarta.validation.constraints.NotBlank;

// PENDING, CONFIRMED, PREPARING, COMPLETED o CANCELLED
public record OrderStatusRequest(

    @NotBlank(message = "El estado es obligatorio.")
    String status) {
}
