package com.lumina.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

// Pedido que crea el cliente. Los precios NO vienen aquí: se leen de la base de datos.
public record OrderRequest(

    @NotNull(message = "El usuario es obligatorio.")
    Long userId,

    @NotEmpty(message = "El pedido debe tener al menos un producto.")
    @Valid
    List<OrderItemRequest> items) {
}
