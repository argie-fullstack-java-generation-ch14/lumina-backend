package com.lumina.controller;

import com.lumina.service.OrderService;
import com.lumina.dto.request.OrderRequest;
import com.lumina.dto.request.OrderStatusRequest;
import com.lumina.dto.response.OrderResponse;

import jakarta.validation.Valid;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/pedidos")
public class OrderController {

  private final OrderService orderService;

  public OrderController(OrderService orderService) {
    this.orderService = orderService;
  }

  // POST /api/pedidos
  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public OrderResponse create(@Valid @RequestBody OrderRequest request) {
    return orderService.create(request);
  }

  // GET /api/pedidos            (todos, para el administrador)
  // GET /api/pedidos?usuarioId=2 (los de una persona)
  @GetMapping
  public List<OrderResponse> findAll(@RequestParam(required = false) Long usuarioId) {
    return orderService.findAll(usuarioId);
  }

  // GET /api/pedidos/1
  @GetMapping("/{id}")
  public OrderResponse findById(@PathVariable Long id) {
    return orderService.findById(id);
  }

  // PUT /api/pedidos/1/estado   { "status": "CONFIRMED" }
  @PutMapping("/{id}/estado")
  @PreAuthorize("hasAnyRole('ADMIN','STAFF')")
  public OrderResponse updateStatus(@PathVariable Long id, @Valid @RequestBody OrderStatusRequest request) {
    return orderService.updateStatus(id, request);
  }
}
