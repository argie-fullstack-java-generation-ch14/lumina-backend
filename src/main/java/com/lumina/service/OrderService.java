package com.lumina.service;

import com.lumina.dto.request.OrderItemRequest;
import com.lumina.dto.request.OrderRequest;
import com.lumina.dto.request.OrderStatusRequest;
import com.lumina.dto.response.OrderResponse;
import com.lumina.exception.BadRequestException;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.model.OrderItem;
import com.lumina.model.OrderStatus;
import com.lumina.model.Product;
import com.lumina.model.UserOrder;
import com.lumina.repository.OrderItemRepository;
import com.lumina.repository.ProductRepository;
import com.lumina.repository.UserOrderRepository;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

  private final UserOrderRepository orders;
  private final OrderItemRepository orderItems;
  private final ProductRepository products;
  private final UserService userService;

  public OrderService(UserOrderRepository orders, OrderItemRepository orderItems,
      ProductRepository products, UserService userService) {
    this.orders = orders;
    this.orderItems = orderItems;
    this.products = products;
    this.userService = userService;
  }

  // Si algo falla a la mitad (por ejemplo, no hay stock), no se guarda nada: es una sola transacción
  @Transactional
  public OrderResponse create(OrderRequest request) {
    UserOrder order = new UserOrder();
    order.setUser(userService.getUser(request.userId()));
    order.setStatus(OrderStatus.PENDING);

    // 1) armo las líneas del pedido con el precio real de cada producto
    List<OrderItem> items = new ArrayList<>();
    BigDecimal subtotal = BigDecimal.ZERO;

    for (OrderItemRequest line : request.items()) {
      Product product = products.findById(line.productId())
          .orElseThrow(() -> new ResourceNotFoundException("No existe el producto " + line.productId() + "."));

      if (!Boolean.TRUE.equals(product.getAvailable())) {
        throw new BadRequestException("El producto '" + product.getName() + "' no está disponible.");
      }
      if (product.getStock() < line.quantity()) {
        throw new BadRequestException("No hay stock suficiente de '" + product.getName() + "'. Quedan " + product.getStock() + ".");
      }

      // descuento las unidades del inventario
      product.setStock(product.getStock() - line.quantity());
      products.save(product);

      BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(line.quantity()));
      subtotal = subtotal.add(lineTotal);

      OrderItem item = new OrderItem();
      item.setProduct(product);
      item.setProductName(product.getName());
      item.setUnitPrice(product.getPrice());
      item.setQuantity(line.quantity());
      item.setLineTotal(lineTotal);
      items.add(item);
    }

    // 2) totales (por ahora sin impuestos ni descuentos)
    order.setSubtotal(subtotal);
    order.setDiscountTotal(BigDecimal.ZERO);
    order.setTaxTotal(BigDecimal.ZERO);
    order.setTotal(subtotal);

    // 3) guardo el pedido, le pongo su número (LUM-000001) y guardo sus líneas
    order = orders.save(order);
    order.setOrderNumber(String.format("LUM-%06d", order.getId()));
    order = orders.save(order);

    for (OrderItem item : items) {
      item.setOrder(order);
    }
    orderItems.saveAll(items);

    return OrderResponse.from(order, items);
  }

  public List<OrderResponse> findAll(Long userId) {
    List<UserOrder> found = (userId == null)
        ? orders.findAllByOrderByCreatedAtDesc()
        : orders.findByUserIdOrderByCreatedAtDesc(userId);
    return found.stream().map(this::toResponse).toList();
  }

  public OrderResponse findById(Long id) {
    return toResponse(getOrder(id));
  }

  @Transactional
  public OrderResponse updateStatus(Long id, OrderStatusRequest request) {
    UserOrder order = getOrder(id);
    OrderStatus newStatus = parseStatus(request.status());
    boolean wasCancelled = OrderStatus.CANCELLED.equals(order.getStatus());
    boolean nowCancelled = OrderStatus.CANCELLED.equals(newStatus);

    // si se cancela el pedido, las unidades vuelven al inventario
    if (nowCancelled && !wasCancelled) {
      for (OrderItem item : orderItems.findByOrderId(id)) {
        Product product = item.getProduct();
        if (product != null) {
          product.setStock(product.getStock() + item.getQuantity());
          products.save(product);
        }
      }
    }

    order.setStatus(newStatus);
    return toResponse(orders.save(order));
  }

  private OrderResponse toResponse(UserOrder order) {
    return OrderResponse.from(order, orderItems.findByOrderId(order.getId()));
  }

  private UserOrder getOrder(Long id) {
    return orders.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("No existe el pedido " + id + "."));
  }

  private OrderStatus parseStatus(String name) {
    try {
      return OrderStatus.valueOf(name.trim().toUpperCase());
    } catch (IllegalArgumentException | NullPointerException ex) {
      throw new BadRequestException("El estado '" + name + "' no existe.");
    }
  }
}
