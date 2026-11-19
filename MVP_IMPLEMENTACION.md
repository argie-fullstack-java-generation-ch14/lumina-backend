# Implementación del MVP estricto - Lumina Backend

Fecha: 2026-11-19
Objetivo: dejar únicamente las entidades `role`, `app_user`, `product`, `user_order`, `order_item` y `custom_candle`, eliminando las tablas de apoyo `order_status`, `product_category` y `coupon` mediante refactor de código.

## Resultado general

- [x] MVP ejecutado y compilando.
- [x] Base H2 levantada y smoke test completo aprobado.
- [x] Paquetes fuera del alcance eliminados.
- [x] Documentación actualizada.

Entidades finales del MVP:

| Tabla | Paquete |
|---|---|
| `role` | `com.lumina.usuario` |
| `app_user` | `com.lumina.usuario` |
| `product` | `com.lumina.producto` |
| `user_order` | `com.lumina.pedido` |
| `order_item` | `com.lumina.pedido` |
| `custom_candle` | `com.lumina.vela` |

Paquetes transversales conservados: `com.lumina.common` y `com.lumina.config`.

---

## Plan ejecutado

### 1. Eliminar paquetes fuera del MVP

- [x] Eliminar `src/main/java/com/lumina/carrito/`
  - Cómo: se borraron los 4 archivos del paquete (`Cart`, `CartItem`, `CartRepository`, `CartItemRepository`).
- [x] Eliminar `src/main/java/com/lumina/favorito/`
  - Cómo: se borraron los 7 archivos del paquete.
- [x] Eliminar `src/main/java/com/lumina/contacto/`
  - Cómo: se borraron los 5 archivos del paquete.
- [x] Eliminar `src/main/java/com/lumina/cupon/`
  - Cómo: se borraron los 6 archivos del paquete.

Verificación: `src/main/java/com/lumina` quedó con los paquetes `usuario`, `producto`, `pedido`, `vela`, `common` y `config`.

### 2. Refactor de `pedido`

- [x] Convertir `OrderStatus` de entidad JPA a enum Java.
  - Cómo: `OrderStatus.java` ahora declara `PENDING`, `CONFIRMED`, `PREPARING`, `COMPLETED` y `CANCELLED`. Ya no genera tabla.
- [x] Eliminar `OrderStatusRepository.java`.
  - Cómo: se borró el repositorio porque los estados ya no viven en base de datos.
- [x] Quitar la FK y relación `order_status_id` de `UserOrder`.
  - Cómo: se reemplazó por `@Enumerated(EnumType.STRING) @Column(name = "status", length = 20) OrderStatus status`.
- [x] Quitar la relación `coupon_id` de `UserOrder`.
  - Cómo: se eliminó el campo `Coupon coupon`, su getter/setter y su import.
- [x] Simplificar `OrderService`.
  - Cómo:
    - Se quitaron `OrderStatusRepository`, `CouponRepository` y `CouponService` del constructor.
    - Todo pedido nuevo inicia en `OrderStatus.PENDING`.
    - Se eliminó el bloque de cupones y el cálculo de descuentos.
    - `discountTotal` queda en `0`.
    - `total` queda igual al `subtotal`.
    - `updateStatus()` valida el estado con `OrderStatus.valueOf(...)`.
- [x] Quitar `couponCode` de `OrderRequest` y `OrderResponse`.
  - Cómo: se eliminó el campo de ambos records y la lectura de `order.getCoupon()`.
- [x] Conservar `OrderStatusRequest` como DTO del endpoint.
  - Cómo: sigue siendo un record con `String status`; no representa una tabla.

### 3. Refactor de `producto`

- [x] Eliminar la entidad y el CRUD de categorías.
  - Cómo: se borraron `ProductCategory`, `ProductCategoryRepository`, `CategoryService`, `CategoryController` y `CategoryRequest`.
- [x] Reemplazar la relación `ProductCategory` por texto en `Product`.
  - Cómo: `Product.category` ahora es `@Column(name = "category", length = 80) String category`.
- [x] Cambiar `categoryId` por `category` en `ProductRequest`.
  - Cómo: el request ahora recibe `String category` con `@NotBlank` y máximo 80 caracteres.
- [x] Actualizar `ProductRepository` y `ProductService`.
  - Cómo:
    - Se reemplazaron `findByCategorySlug*` por `findByCategoryIgnoreCase*`.
    - `ProductService` ya no depende de `CategoryService`.
    - Al guardar un producto se usa `request.category().trim()`.

### 4. Ajustar `config`

- [x] Dejar `DataInitializer` solo con la creación de roles.
  - Cómo: se quitaron los imports y la lógica de `OrderStatus` y `OrderStatusRepository`.
  - Roles creados al arrancar: `ADMIN`, `CUSTOMER` y `STAFF`.

### 5. Actualizar documentación

- [x] Actualizar `README.md`.
  - Cómo:
    - Se quitó `favorito`, `cupon`, `carrito`, `contacto`, `ProductCategory` y `OrderStatus` de la estructura.
    - Se eliminaron los endpoints de categorías, favoritos, cupones y contacto.
    - Se quitó `couponCode` del ejemplo de pedido.
    - Se documentó que el estado es un enum y que todo pedido inicia en `PENDING`.
    - Se documentó que `product.category` es texto.

### 6. Verificación

- [x] Compilar el proyecto.
  - Comando: `mvn -q -DskipTests package`
  - Resultado: `BUILD_OK`.
- [x] Buscar referencias obsoletas.
  - Comando: búsqueda de `cupon`, `Coupon`, `favorito`, `carrito`, `contacto`, `ProductCategory`, `CategoryService`, `categoryId`, `OrderStatusRepository`, `order_status`, `coupon_id` y `product_category_id` en `src/main/java`.
  - Resultado: `SIN_REFERENCIAS_OBSOLETAS`.
- [x] Levantar la aplicación con H2.
  - Comando: `mvn spring-boot:run -Dspring-boot.run.profiles=h2 -Dspring-boot.run.arguments=--server.port=18080`
  - Resultado: aplicación arrancó correctamente.
- [x] Ejecutar smoke test de los flujos del MVP.
  - Casos probados:
    - Registro de usuario: `POST /api/registro`.
    - Creación de producto con categoría de texto: `POST /api/productos`.
    - Creación de pedido sin cupón: `POST /api/pedidos`.
    - Cambio de estado del pedido: `PUT /api/pedidos/{id}/estado`.
    - Creación de vela personalizada: `POST /api/velas-personalizadas`.
    - Filtro de productos por categoría: `GET /api/productos?categoria=navidad`.
  - Resultados:
    - `USER_ID=1`
    - `PRODUCT_ID=1`
    - `ORDER_ID=1`
    - `ORDER_STATUS=CONFIRMED`
    - `ORDER_TOTAL=90000.00`
    - `PRODUCT_STOCK=8` (se descontaron 2 unidades de 10)
    - `CANDLE_ID=1`
    - `FILTER_COUNT=1`
    - Resultado final: `SMOKE_TEST_OK`.
- [x] Confirmar liberación del puerto de prueba.
  - Resultado: puerto `18080` libre (`PORT_FREE`).
- [x] Documentar el plan y el estado final.
  - Cómo: este archivo `MVP_IMPLEMENTACION.md`.

---

## Estructura final

```
src/main/java/com/lumina
├── LuminaApiApplication.java
├── common/
│   ├── ApiError.java
│   ├── BadRequestException.java
│   ├── ConflictException.java
│   ├── GlobalExceptionHandler.java
│   ├── ResourceNotFoundException.java
│   └── UnauthorizedException.java
├── config/
│   ├── DataInitializer.java
│   └── WebConfig.java
├── pedido/
│   ├── OrderController.java
│   ├── OrderItem.java
│   ├── OrderItemRepository.java
│   ├── OrderItemRequest.java
│   ├── OrderRequest.java
│   ├── OrderResponse.java
│   ├── OrderService.java
│   ├── OrderStatus.java
│   ├── OrderStatusRequest.java
│   ├── UserOrder.java
│   └── UserOrderRepository.java
├── producto/
│   ├── Product.java
│   ├── ProductController.java
│   ├── ProductRepository.java
│   ├── ProductRequest.java
│   ├── ProductService.java
│   └── SlugUtil.java
├── usuario/
│   ├── AppUser.java
│   ├── AppUserRepository.java
│   ├── LoginRequest.java
│   ├── RegisterRequest.java
│   ├── Role.java
│   ├── RoleRepository.java
│   ├── UpdateUserRequest.java
│   ├── UserController.java
│   ├── UserResponse.java
│   └── UserService.java
└── vela/
    ├── CustomCandle.java
    ├── CustomCandleController.java
    ├── CustomCandleRepository.java
    ├── CustomCandleRequest.java
    └── CustomCandleService.java
```

---

## Cambios de contrato de API

- [x] `POST /api/productos` y `PUT /api/productos/{id}`:
  - Antes: `categoryId` (Long).
  - Ahora: `category` (String, obligatorio, máximo 80 caracteres).
- [x] `POST /api/pedidos`:
  - Antes: aceptaba `couponCode`.
  - Ahora: ya no acepta cupones.
- [x] Respuestas de pedido:
  - Antes: incluían `couponCode`.
  - Ahora: ya no lo incluyen.
- [x] Estados de pedido:
  - Antes: tabla `order_status`.
  - Ahora: enum almacenado como texto en `user_order.status`.
- [x] Endpoints eliminados:
  - `/api/categorias`
  - `/api/favoritos`
  - `/api/cupones`
  - `/api/contacto`

---

## Notas sobre base de datos

- [x] En H2 el esquema se crea limpio con `ddl-auto=create-drop`.
- [ ] En MySQL existente, las tablas y columnas viejas no se eliminan automáticamente.
  - Tablas viejas a limpiar manualmente si se desea un esquema estrictamente limpio:
    - `order_status`
    - `product_category`
    - `coupon`
    - `cart`
    - `cart_item`
    - `favorite`
    - `contact_message`
  - Columnas FK viejas a limpiar manualmente:
    - `user_order.order_status_id`
    - `user_order.coupon_id`
    - `product.product_category_id`
- Recomendación: recrear la base de datos de desarrollo para la entrega del MVP o ejecutar los `ALTER TABLE`/`DROP TABLE` correspondientes.

---

## Pendientes fuera de este alcance

- [ ] Actualizar el frontend para enviar `category` en lugar de `categoryId`.
- [ ] Actualizar el frontend para dejar de enviar `couponCode`.
- [ ] Agregar pruebas automatizadas (el proyecto no tiene `src/test`).
- [ ] Agregar autenticación JWT si se requiere para la entrega final.
