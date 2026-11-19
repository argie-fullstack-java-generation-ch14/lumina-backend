# Migración a arquitectura MVC (Modelo-Vista-Controlador)

Estado: **planificado, sin ejecutar**. Este documento solo define el plan y el reparto de trabajo; la migración todavía no se ha realizado.

## Objetivo

Reorganizar el backend de Lumina desde paquetes por dominio (`usuario`, `producto`, `pedido`, `vela`, `common`) hacia una estructura MVC (Modelo-Vista-Controlador) por capas, sin cambiar:

- Endpoints REST (estilo de API sobre HTTP).
- Nombres de clases.
- DTOs (objetos de transferencia de datos).
- Esquema de base de datos.
- Lógica de negocio.

Los nombres de los paquetes nuevos irán en inglés. El código, las rutas y los mensajes seguirán en español.

## Estructura objetivo

```text
src/main/java/com/lumina
├── LuminaApiApplication.java
├── config/
│   ├── DataInitializer.java
│   └── WebConfig.java
├── controller/
│   ├── CustomCandleController.java
│   ├── OrderController.java
│   ├── ProductController.java
│   └── UserController.java
├── dto/
│   ├── request/
│   │   ├── CustomCandleRequest.java
│   │   ├── LoginRequest.java
│   │   ├── OrderItemRequest.java
│   │   ├── OrderRequest.java
│   │   ├── OrderStatusRequest.java
│   │   ├── ProductRequest.java
│   │   ├── RegisterRequest.java
│   │   └── UpdateUserRequest.java
│   └── response/
│       ├── ApiError.java
│       ├── OrderResponse.java
│       └── UserResponse.java
├── exception/
│   ├── BadRequestException.java
│   ├── ConflictException.java
│   ├── GlobalExceptionHandler.java
│   ├── ResourceNotFoundException.java
│   └── UnauthorizedException.java
├── model/
│   ├── AppUser.java
│   ├── CustomCandle.java
│   ├── OrderItem.java
│   ├── OrderStatus.java
│   ├── Product.java
│   ├── Role.java
│   └── UserOrder.java
├── repository/
│   ├── AppUserRepository.java
│   ├── CustomCandleRepository.java
│   ├── OrderItemRepository.java
│   ├── ProductRepository.java
│   ├── RoleRepository.java
│   └── UserOrderRepository.java
├── service/
│   ├── CustomCandleService.java
│   ├── OrderService.java
│   ├── ProductService.java
│   └── UserService.java
└── util/
    └── SlugUtil.java
```

## Contrato de paquetes

Este contrato es fijo. Todos los integrantes deben escribir sus imports apuntando a estos paquetes, aunque la otra persona todavía no haya terminado.

| Elemento | Paquete |
|---|---|
| Entidades JPA (API de persistencia de Java) y enum (tipo de valores fijos) `OrderStatus` | `com.lumina.model` |
| Repositorios Spring Data (framework de acceso a datos) | `com.lumina.repository` |
| Servicios | `com.lumina.service` |
| Controladores REST (estilo de API sobre HTTP) | `com.lumina.controller` |
| DTOs (objetos de transferencia de datos) de entrada | `com.lumina.dto.request` |
| DTOs (objetos de transferencia de datos) de salida | `com.lumina.dto.response` |
| Excepciones y `GlobalExceptionHandler` | `com.lumina.exception` |
| Utilidades | `com.lumina.util` |
| Configuración | `com.lumina.config` |
| Clase principal | `com.lumina` |

No se renombran clases. Esto evita cambios en JSON (formato de texto para intercambiar datos), rutas y pruebas funcionales.

## Contrato interno de nombres y firmas

**Regla:** ningún nombre de clase, interfaz, record, enum, método, constructor ni componente de record cambia. Solo cambia el `package` y, por tanto, el `import`.

Todo el código nuevo debe escribirse usando los nombres completos finales de este contrato, aunque el archivo todavía no haya sido movido por su dueño.

### Glosario breve

- **FQCN** (nombre completo de la clase, incluyendo su paquete): por ejemplo, `com.lumina.model.AppUser`.
- **DTO** (objeto de transferencia de datos): clase o record que transporta datos entre la API y las capas internas.
- **Record** (clase de Java para transportar datos inmutables): en este proyecto se usa para los DTOs.
- **Enum** (tipo de valores fijos): en este proyecto se usa para `OrderStatus`.
- **JPA** (API de persistencia de Java): tecnología que mapea clases Java a tablas de base de datos.
- **CRUD** (crear, leer, actualizar y borrar): operaciones básicas de persistencia.
- **Optional** (contenedor que puede tener un valor o estar vacío): se usa cuando una búsqueda puede no encontrar nada.
- **BigDecimal** (número decimal de precisión fija): se usa para precios y totales.
- **LocalDateTime** (fecha y hora local): se usa para fechas de creación y actualización.
- **ResponseEntity** (respuesta HTTP completa): incluye código de estado, cabeceras y cuerpo.
- **Smoke test** (prueba rápida de funcionamiento): prueba manual breve para confirmar que los flujos principales funcionan.

### 1. Mapa de FQCN (nombre completo con paquete): actual → nuevo

#### Modelo

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.AppUser` | `com.lumina.model.AppUser` |
| `com.lumina.usuario.Role` | `com.lumina.model.Role` |
| `com.lumina.producto.Product` | `com.lumina.model.Product` |
| `com.lumina.pedido.UserOrder` | `com.lumina.model.UserOrder` |
| `com.lumina.pedido.OrderItem` | `com.lumina.model.OrderItem` |
| `com.lumina.pedido.OrderStatus` | `com.lumina.model.OrderStatus` |
| `com.lumina.vela.CustomCandle` | `com.lumina.model.CustomCandle` |

#### Repositorios

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.AppUserRepository` | `com.lumina.repository.AppUserRepository` |
| `com.lumina.usuario.RoleRepository` | `com.lumina.repository.RoleRepository` |
| `com.lumina.producto.ProductRepository` | `com.lumina.repository.ProductRepository` |
| `com.lumina.pedido.UserOrderRepository` | `com.lumina.repository.UserOrderRepository` |
| `com.lumina.pedido.OrderItemRepository` | `com.lumina.repository.OrderItemRepository` |
| `com.lumina.vela.CustomCandleRepository` | `com.lumina.repository.CustomCandleRepository` |

#### Servicios

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.UserService` | `com.lumina.service.UserService` |
| `com.lumina.producto.ProductService` | `com.lumina.service.ProductService` |
| `com.lumina.pedido.OrderService` | `com.lumina.service.OrderService` |
| `com.lumina.vela.CustomCandleService` | `com.lumina.service.CustomCandleService` |

#### Controladores

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.UserController` | `com.lumina.controller.UserController` |
| `com.lumina.producto.ProductController` | `com.lumina.controller.ProductController` |
| `com.lumina.pedido.OrderController` | `com.lumina.controller.OrderController` |
| `com.lumina.vela.CustomCandleController` | `com.lumina.controller.CustomCandleController` |

#### DTOs de entrada

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.LoginRequest` | `com.lumina.dto.request.LoginRequest` |
| `com.lumina.usuario.RegisterRequest` | `com.lumina.dto.request.RegisterRequest` |
| `com.lumina.usuario.UpdateUserRequest` | `com.lumina.dto.request.UpdateUserRequest` |
| `com.lumina.producto.ProductRequest` | `com.lumina.dto.request.ProductRequest` |
| `com.lumina.pedido.OrderRequest` | `com.lumina.dto.request.OrderRequest` |
| `com.lumina.pedido.OrderItemRequest` | `com.lumina.dto.request.OrderItemRequest` |
| `com.lumina.pedido.OrderStatusRequest` | `com.lumina.dto.request.OrderStatusRequest` |
| `com.lumina.vela.CustomCandleRequest` | `com.lumina.dto.request.CustomCandleRequest` |

#### DTOs de salida

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.usuario.UserResponse` | `com.lumina.dto.response.UserResponse` |
| `com.lumina.pedido.OrderResponse` | `com.lumina.dto.response.OrderResponse` |
| `com.lumina.common.ApiError` | `com.lumina.dto.response.ApiError` |

#### Excepciones y utilidades

| FQCN actual (nombre con paquete) | FQCN nuevo (nombre con paquete) |
|---|---|
| `com.lumina.common.BadRequestException` | `com.lumina.exception.BadRequestException` |
| `com.lumina.common.ConflictException` | `com.lumina.exception.ConflictException` |
| `com.lumina.common.ResourceNotFoundException` | `com.lumina.exception.ResourceNotFoundException` |
| `com.lumina.common.UnauthorizedException` | `com.lumina.exception.UnauthorizedException` |
| `com.lumina.common.GlobalExceptionHandler` | `com.lumina.exception.GlobalExceptionHandler` |
| `com.lumina.producto.SlugUtil` | `com.lumina.util.SlugUtil` |

No se mueven: `LuminaApiApplication`, `config/DataInitializer` y `config/WebConfig`. `DataInitializer` solo actualiza sus imports, pero conserva su nombre y su paquete.

### 2. Modelos: nombres y propiedades públicas

Todos los modelos son clases con constructor vacío implícito y accesores públicos `getX()`/`setX()` para cada propiedad.

| Clase final | Tabla | Propiedades y tipos |
|---|---|---|
| `AppUser` | `app_user` | `id: Long`, `fullName: String`, `phone: String`, `email: String`, `passwordHash: String`, `role: Role`, `createdAt: LocalDateTime`, `updatedAt: LocalDateTime` |
| `Role` | `role` | `id: Long`, `name: String`, `description: String`, `createdAt: LocalDateTime`, `updatedAt: LocalDateTime` |
| `Product` | `product` | `id: Long`, `name: String`, `slug: String`, `imageUrl: String`, `category: String`, `scent: String`, `weightGrams: Integer`, `color: String`, `description: String`, `price: BigDecimal`, `stock: Integer`, `available: Boolean`, `createdAt: LocalDateTime`, `updatedAt: LocalDateTime` |
| `UserOrder` | `user_order` | `id: Long`, `orderNumber: String`, `user: AppUser`, `status: OrderStatus`, `subtotal: BigDecimal`, `discountTotal: BigDecimal`, `taxTotal: BigDecimal`, `total: BigDecimal`, `createdAt: LocalDateTime`, `updatedAt: LocalDateTime` |
| `OrderItem` | `order_item` | `id: Long`, `order: UserOrder`, `product: Product`, `customCandle: CustomCandle`, `productName: String`, `unitPrice: BigDecimal`, `quantity: Integer`, `lineTotal: BigDecimal` |
| `CustomCandle` | `custom_candle` | `id: Long`, `user: AppUser`, `intention: String`, `scent: String`, `designColor: String`, `message: String`, `previewImageUrl: String`, `price: BigDecimal`, `createdAt: LocalDateTime` |

`OrderStatus` es un enum (tipo de valores fijos), no una tabla:

```text
OrderStatus.PENDING
OrderStatus.CONFIRMED
OrderStatus.PREPARING
OrderStatus.COMPLETED
OrderStatus.CANCELLED
```

### 3. Repositorios: interfaces y métodos declarados

Todos heredan de `JpaRepository` (interfaz de Spring que aporta operaciones CRUD: crear, leer, actualizar y borrar). Los métodos heredados (`save`, `saveAll`, `findById`, `findAll`, `delete`, `deleteById`, `existsById`, `count`) conservan sus nombres.

| Interfaz final | Métodos declarados |
|---|---|
| `AppUserRepository` | `Optional<AppUser> findByEmail(String email)` · `boolean existsByEmail(String email)` |
| `RoleRepository` | `Optional<Role> findByName(String name)` |
| `ProductRepository` | `Optional<Product> findBySlug(String slug)` · `boolean existsBySlug(String slug)` · `List<Product> findByAvailableTrue()` · `List<Product> findByCategoryIgnoreCase(String category)` · `List<Product> findByCategoryIgnoreCaseAndAvailableTrue(String category)` |
| `UserOrderRepository` | `List<UserOrder> findByUserIdOrderByCreatedAtDesc(Long userId)` · `List<UserOrder> findAllByOrderByCreatedAtDesc()` |
| `OrderItemRepository` | `List<OrderItem> findByOrderId(Long orderId)` |
| `CustomCandleRepository` | `List<CustomCandle> findByUserId(Long userId)` |

### 4. Servicios: nombres y firmas públicas

Los constructores conservan su nombre y sus parámetros; solo cambian los nombres completos de sus dependencias.

| Servicio final | Métodos públicos |
|---|---|
| `UserService` | `register(RegisterRequest): UserResponse` · `login(LoginRequest): UserResponse` · `findAll(): List<UserResponse>` · `findById(Long): UserResponse` · `update(Long, UpdateUserRequest): UserResponse` · `delete(Long): void` · `getUser(Long): AppUser` |
| `ProductService` | `findAll(String category, boolean onlyAvailable): List<Product>` · `findById(Long): Product` · `findBySlug(String): Product` · `create(ProductRequest): Product` · `update(Long, ProductRequest): Product` · `delete(Long): void` |
| `OrderService` | `create(OrderRequest): OrderResponse` · `findAll(Long userId): List<OrderResponse>` · `findById(Long): OrderResponse` · `updateStatus(Long, OrderStatusRequest): OrderResponse` |
| `CustomCandleService` | `create(CustomCandleRequest): CustomCandle` · `findByUser(Long userId): List<CustomCandle>` · `findById(Long): CustomCandle` · `delete(Long): void` |

### 5. Controladores: rutas y métodos existentes

| Controlador final | Método y ruta |
|---|---|
| `UserController` | `POST /api/registro` → `register(RegisterRequest): UserResponse` · `POST /api/login` → `login(LoginRequest): UserResponse` · `GET /api/usuarios` → `findAll(): List<UserResponse>` · `GET /api/usuarios/{id}` → `findById(Long): UserResponse` · `PUT /api/usuarios/{id}` → `update(Long, UpdateUserRequest): UserResponse` · `DELETE /api/usuarios/{id}` → `delete(Long): void` |
| `ProductController` | `GET /api/productos` → `findAll(String categoria, boolean disponibles): List<Product>` · `GET /api/productos/{id}` → `findById(Long): Product` · `GET /api/productos/slug/{slug}` → `findBySlug(String): Product` · `POST /api/productos` → `create(ProductRequest): Product` · `PUT /api/productos/{id}` → `update(Long, ProductRequest): Product` · `DELETE /api/productos/{id}` → `delete(Long): void` |
| `OrderController` | `POST /api/pedidos` → `create(OrderRequest): OrderResponse` · `GET /api/pedidos` → `findAll(Long usuarioId): List<OrderResponse>` · `GET /api/pedidos/{id}` → `findById(Long): OrderResponse` · `PUT /api/pedidos/{id}/estado` → `updateStatus(Long, OrderStatusRequest): OrderResponse` |
| `CustomCandleController` | `POST /api/velas-personalizadas` → `create(CustomCandleRequest): CustomCandle` · `GET /api/velas-personalizadas?usuarioId=` → `findByUser(Long): List<CustomCandle>` · `GET /api/velas-personalizadas/{id}` → `findById(Long): CustomCandle` · `DELETE /api/velas-personalizadas/{id}` → `delete(Long): void` |

No se cambian anotaciones como `@RestController`, `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PathVariable`, `@RequestParam` ni `@RequestBody`.

### 6. DTOs de entrada: componentes de los records

En los records (clases de Java para transportar datos inmutables), los accesores son `nombre()` y no `getNombre()`. Los nombres de los componentes no cambian.

| Record final | Componentes |
|---|---|
| `LoginRequest` | `email: String`, `password: String` |
| `RegisterRequest` | `fullName: String`, `phone: String`, `email: String`, `password: String` |
| `UpdateUserRequest` | `fullName: String`, `phone: String` |
| `ProductRequest` | `name: String`, `slug: String`, `imageUrl: String`, `category: String`, `scent: String`, `weightGrams: Integer`, `color: String`, `description: String`, `price: BigDecimal`, `stock: Integer`, `available: Boolean` |
| `OrderRequest` | `userId: Long`, `items: List<OrderItemRequest>` |
| `OrderItemRequest` | `productId: Long`, `quantity: Integer` |
| `OrderStatusRequest` | `status: String` |
| `CustomCandleRequest` | `userId: Long`, `intention: String`, `scent: String`, `designColor: String`, `message: String`, `previewImageUrl: String`, `price: BigDecimal` |

### 7. DTOs de salida: componentes y métodos estáticos

| Record final | Componentes y métodos |
|---|---|
| `UserResponse` | `id: Long`, `fullName: String`, `phone: String`, `email: String`, `role: String`, `createdAt: LocalDateTime` · `static from(AppUser): UserResponse` |
| `OrderResponse` | `id: Long`, `orderNumber: String`, `userId: Long`, `status: String`, `subtotal: BigDecimal`, `discountTotal: BigDecimal`, `taxTotal: BigDecimal`, `total: BigDecimal`, `createdAt: LocalDateTime`, `items: List<OrderResponse.Item>` · `static from(UserOrder, List<OrderItem>): OrderResponse` |
| `OrderResponse.Item` | `productId: Long`, `productName: String`, `unitPrice: BigDecimal`, `quantity: Integer`, `lineTotal: BigDecimal` |
| `ApiError` | `status: int`, `error: String`, `message: String`, `details: List<String>`, `timestamp: LocalDateTime` · `static of(int, String, String, List<String>): ApiError` |

`OrderResponse.Item` sigue siendo un record anidado dentro de `OrderResponse`.

### 8. Excepciones y manejador global

Constructores existentes, todos con `String message`:

| Clase final | Constructor público |
|---|---|
| `BadRequestException` | `BadRequestException(String message)` |
| `ConflictException` | `ConflictException(String message)` |
| `ResourceNotFoundException` | `ResourceNotFoundException(String message)` |
| `UnauthorizedException` | `UnauthorizedException(String message)` |

Métodos públicos de `GlobalExceptionHandler` (`ResponseEntity` es la respuesta HTTP completa):

| Método | Firma |
|---|---|
| `notFound` | `ResponseEntity<ApiError> notFound(ResourceNotFoundException ex)` |
| `conflict` | `ResponseEntity<ApiError> conflict(ConflictException ex)` |
| `badRequest` | `ResponseEntity<ApiError> badRequest(BadRequestException ex)` |
| `unauthorized` | `ResponseEntity<ApiError> unauthorized(UnauthorizedException ex)` |
| `validation` | `ResponseEntity<ApiError> validation(MethodArgumentNotValidException ex)` |
| `unreadable` | `ResponseEntity<ApiError> unreadable(Exception ex)` |
| `integrity` | `ResponseEntity<ApiError> integrity(DataIntegrityViolationException ex)` |

### 9. Utilidad

| Clase final | Método |
|---|---|
| `SlugUtil` | `public static String toSlug(String text)` |

### 10. Guía rápida para llamadas entre roles

Esta tabla evita preguntar “¿cómo se va a llamar?” o “¿en qué paquete queda?”.

| Necesidad | Contrato final | Import final |
|---|---|---|
| Pedido necesita validar/cargar usuario | `UserService.getUser(Long): AppUser` | `com.lumina.service.UserService` |
| Pedido necesita leer producto | `ProductRepository.findById(Long): Optional<Product>` | `com.lumina.repository.ProductRepository` |
| Pedido necesita producto por servicio | `ProductService.findById(Long): Product` | `com.lumina.service.ProductService` |
| Pedido necesita el tipo de vela personalizada | `CustomCandle` | `com.lumina.model.CustomCandle` |
| Vela necesita cargar usuario | `UserService.getUser(Long): AppUser` | `com.lumina.service.UserService` |
| `DataInitializer` necesita roles | `RoleRepository.findByName(String): Optional<Role>` | `com.lumina.repository.RoleRepository` |
| `GlobalExceptionHandler` necesita el error | `ApiError.of(int, String, String, List<String>): ApiError` | `com.lumina.dto.response.ApiError` |
| Un servicio necesita lanzar errores | `BadRequestException`, `ConflictException`, `ResourceNotFoundException`, `UnauthorizedException` | `com.lumina.exception.*` |
| `ProductService` necesita slug | `SlugUtil.toSlug(String): String` | `com.lumina.util.SlugUtil` |
| `OrderService` necesita respuesta de pedido | `OrderResponse.from(UserOrder, List<OrderItem>): OrderResponse` | `com.lumina.dto.response.OrderResponse` |
| `UserService` necesita respuesta de usuario | `UserResponse.from(AppUser): UserResponse` | `com.lumina.dto.response.UserResponse` |

### 11. Checklist del contrato

- [ ] No renombrar ninguna clase, interfaz, record, enum, constructor o método.
- [ ] No cambiar firmas de métodos ni componentes de records.
- [ ] No cambiar rutas REST ni anotaciones de Spring.
- [ ] Escribir los imports nuevos usando los nombres completos de este contrato.
- [ ] No usar imports de los paquetes viejos en código nuevo.
- [ ] Verificar que `OrderStatus` sigue siendo enum y que `OrderStatusRequest` sigue siendo un record.
- [ ] Verificar que `OrderResponse.Item` sigue siendo un record anidado.
- [ ] Verificar que `ApiError.of`, `UserResponse.from` y `OrderResponse.from` conservan su nombre y firma.

Con esta sección, cada integrante puede escribir, por ejemplo, `import com.lumina.model.AppUser;` o llamar `userService.getUser(id)` sin esperar a que el rol A o B termine su migración. El build (compilación y empaquetado) seguirá siendo rojo hasta integrar los 4 roles, pero los nombres ya no serán una incógnita.

## Regla importante sobre la compilación

La migración es **atómica para el compilador**: no se puede compilar correctamente mientras solo una parte de los paquetes esté movida.

Ejemplo: si `Product` se mueve a `com.lumina.model` pero `ProductService` todavía importa `com.lumina.producto.Product`, el build (compilación y empaquetado) falla. Lo mismo ocurre con cualquier entidad, repositorio o DTO.

Por eso:

- El trabajo se puede repartir y hacer en paralelo, pero **el build verde se valida en la rama de integración cuando estén los 4 roles unidos**.
- La división por archivos evita conflictos de Git y edición cruzada; no evita que una rama parcial no compile por sí sola.
- `main` no se toca hasta que la rama de integración compile y pase el smoke test (prueba rápida de funcionamiento).
- Si se necesita un build verde en cada paso, la alternativa es que una sola persona haga toda la migración en un único commit. No es lo recomendado si se quiere repartir entre 4.

## Estrategia de ramas

1. El responsable de integración crea la rama base desde `main`:

```bash
git switch main
git pull
git switch -c refactor/mvc-integration
git push -u origin refactor/mvc-integration
```

2. Cada integrante crea su rama desde `refactor/mvc-integration`:

```bash
git switch refactor/mvc-integration
git pull
git switch -c refactor/mvc-rol-a-modelo
```

Nombres sugeridos:

| Rol | Rama |
|---|---|
| A | `refactor/mvc-rol-a-modelo` |
| B | `refactor/mvc-rol-b-persistencia` |
| C | `refactor/mvc-rol-c-servicios` |
| D | `refactor/mvc-rol-d-api` |

3. Cada integrante trabaja solo en los archivos de su rol.
4. Cada integrante hace commit en su rama y abre un PR (solicitud de cambio en Git) hacia `refactor/mvc-integration`.
5. El responsable de integración une los 4 PR en este orden recomendado: A, B, C, D.
6. El build y el smoke test se ejecutan al final, con los 4 roles integrados.
7. Si todo pasa, `refactor/mvc-integration` se fusiona a `main`.

## Reparto de trabajo entre 4 integrantes

| Rol | Responsabilidad | Cantidad de archivos | Dueño sugerido |
|---|---|---|---|
| A | Modelo y utilidades | 8 | Integrante A |
| B | Persistencia, excepciones y configuración | 12 | Integrante B |
| C | Servicios y DTOs de entrada | 12 | Integrante C |
| D | Controladores, DTOs de salida, documentación e integración | 7 + documentación | Integrante D |

La suma cubre los 38 archivos que cambian de paquete. `LuminaApiApplication` y `config/WebConfig` no se mueven.

Antes de empezar, cada integrante debe leer la sección **Contrato interno de nombres y firmas**. Ahí están los nombres que no cambian, sus métodos públicos y los imports finales que puede usar aunque el otro rol todavía no haya terminado.

---

## Rol A: modelo y utilidades

### Archivos

Mover a `com.lumina.model`:

- `usuario/AppUser.java`
- `usuario/Role.java`
- `producto/Product.java`
- `pedido/UserOrder.java`
- `pedido/OrderItem.java`
- `pedido/OrderStatus.java`
- `vela/CustomCandle.java`

Mover a `com.lumina.util`:

- `producto/SlugUtil.java`

### Comandos

```bash
mkdir -p src/main/java/com/lumina/model src/main/java/com/lumina/util

git mv src/main/java/com/lumina/usuario/AppUser.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/usuario/Role.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/producto/Product.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/UserOrder.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/OrderItem.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/OrderStatus.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/vela/CustomCandle.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/producto/SlugUtil.java src/main/java/com/lumina/util/
```

### Ajustes

- Cambiar `package` a `com.lumina.model` en las 7 entidades/enum.
- Cambiar `package` a `com.lumina.util` en `SlugUtil`.
- En `UserOrder`, eliminar el import de `com.lumina.usuario.AppUser`; ahora está en el mismo paquete `model`.
- En `OrderItem`, eliminar los imports de `com.lumina.producto.Product` y `com.lumina.vela.CustomCandle`; ahora están en el mismo paquete `model`.
- En `CustomCandle`, eliminar el import de `com.lumina.usuario.AppUser`; ahora está en el mismo paquete `model`.
- No tocar lógica, anotaciones JPA ni nombres de campos.

### Criterio de terminado

- [ ] Las 7 entidades/enum están en `src/main/java/com/lumina/model/`.
- [ ] `SlugUtil` está en `src/main/java/com/lumina/util/`.
- [ ] No quedan imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido` ni `com.lumina.vela` dentro de los archivos de este rol.
- [ ] El commit del rol está subido y el PR apunta a `refactor/mvc-integration`.

---

## Rol B: persistencia, excepciones y configuración

### Archivos

Mover a `com.lumina.repository`:

- `usuario/AppUserRepository.java`
- `usuario/RoleRepository.java`
- `producto/ProductRepository.java`
- `pedido/UserOrderRepository.java`
- `pedido/OrderItemRepository.java`
- `vela/CustomCandleRepository.java`

Mover a `com.lumina.exception`:

- `common/BadRequestException.java`
- `common/ConflictException.java`
- `common/ResourceNotFoundException.java`
- `common/UnauthorizedException.java`
- `common/GlobalExceptionHandler.java`

Actualizar imports (sin mover):

- `config/DataInitializer.java`

### Comandos

```bash
mkdir -p src/main/java/com/lumina/repository src/main/java/com/lumina/exception

git mv src/main/java/com/lumina/usuario/AppUserRepository.java src/main/java/com/lumina/repository/
git mv src/main/java/com/lumina/usuario/RoleRepository.java src/main/java/com/lumina/repository/
git mv src/main/java/com/lumina/producto/ProductRepository.java src/main/java/com/lumina/repository/
git mv src/main/java/com/lumina/pedido/UserOrderRepository.java src/main/java/com/lumina/repository/
git mv src/main/java/com/lumina/pedido/OrderItemRepository.java src/main/java/com/lumina/repository/
git mv src/main/java/com/lumina/vela/CustomCandleRepository.java src/main/java/com/lumina/repository/

git mv src/main/java/com/lumina/common/BadRequestException.java src/main/java/com/lumina/exception/
git mv src/main/java/com/lumina/common/ConflictException.java src/main/java/com/lumina/exception/
git mv src/main/java/com/lumina/common/ResourceNotFoundException.java src/main/java/com/lumina/exception/
git mv src/main/java/com/lumina/common/UnauthorizedException.java src/main/java/com/lumina/exception/
git mv src/main/java/com/lumina/common/GlobalExceptionHandler.java src/main/java/com/lumina/exception/
```

### Ajustes

- Cambiar `package` a `com.lumina.repository` en los 6 repositorios.
- Cada repositorio debe importar su entidad desde `com.lumina.model`.
- Cambiar `package` a `com.lumina.exception` en las 5 clases de excepción/manejador.
- `GlobalExceptionHandler` debe importar `com.lumina.dto.response.ApiError`.
- Las excepciones quedan en el mismo paquete `exception`, por lo que no necesitan imports entre ellas.
- `config/DataInitializer` debe importar:
  - `com.lumina.model.Role`
  - `com.lumina.repository.RoleRepository`
- No tocar las consultas derivadas (`findByEmail`, `findByUserId`, etc.) ni la lógica de excepciones.

### Criterio de terminado

- [ ] Los 6 repositorios están en `com.lumina.repository` e importan sus entidades de `com.lumina.model`.
- [ ] Las 5 clases de excepciones están en `com.lumina.exception`.
- [ ] `GlobalExceptionHandler` importa `com.lumina.dto.response.ApiError`.
- [ ] `DataInitializer` importa `com.lumina.model.Role` y `com.lumina.repository.RoleRepository`.
- [ ] No quedan imports de `com.lumina.common` en los archivos de este rol.
- [ ] El commit del rol está subido y el PR apunta a `refactor/mvc-integration`.

---

## Rol C: servicios y DTOs de entrada

### Archivos

Mover a `com.lumina.service`:

- `usuario/UserService.java`
- `producto/ProductService.java`
- `pedido/OrderService.java`
- `vela/CustomCandleService.java`

Mover a `com.lumina.dto.request`:

- `usuario/LoginRequest.java`
- `usuario/RegisterRequest.java`
- `usuario/UpdateUserRequest.java`
- `producto/ProductRequest.java`
- `pedido/OrderRequest.java`
- `pedido/OrderItemRequest.java`
- `pedido/OrderStatusRequest.java`
- `vela/CustomCandleRequest.java`

### Comandos

```bash
mkdir -p src/main/java/com/lumina/service src/main/java/com/lumina/dto/request

git mv src/main/java/com/lumina/usuario/UserService.java src/main/java/com/lumina/service/
git mv src/main/java/com/lumina/producto/ProductService.java src/main/java/com/lumina/service/
git mv src/main/java/com/lumina/pedido/OrderService.java src/main/java/com/lumina/service/
git mv src/main/java/com/lumina/vela/CustomCandleService.java src/main/java/com/lumina/service/

git mv src/main/java/com/lumina/usuario/LoginRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/usuario/RegisterRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/usuario/UpdateUserRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/producto/ProductRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/pedido/OrderRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/pedido/OrderItemRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/pedido/OrderStatusRequest.java src/main/java/com/lumina/dto/request/
git mv src/main/java/com/lumina/vela/CustomCandleRequest.java src/main/java/com/lumina/dto/request/
```

### Ajustes de imports

`service/UserService.java`:

- `com.lumina.model.AppUser`
- `com.lumina.model.Role`
- `com.lumina.repository.AppUserRepository`
- `com.lumina.repository.RoleRepository`
- `com.lumina.exception.ConflictException`
- `com.lumina.exception.ResourceNotFoundException`
- `com.lumina.exception.UnauthorizedException`
- `com.lumina.dto.request.RegisterRequest`
- `com.lumina.dto.request.LoginRequest`
- `com.lumina.dto.request.UpdateUserRequest`
- `com.lumina.dto.response.UserResponse`

`service/ProductService.java`:

- `com.lumina.model.Product`
- `com.lumina.repository.ProductRepository`
- `com.lumina.exception.ConflictException`
- `com.lumina.exception.ResourceNotFoundException`
- `com.lumina.dto.request.ProductRequest`
- `com.lumina.util.SlugUtil`

`service/OrderService.java`:

- `com.lumina.model.OrderItem`
- `com.lumina.model.OrderStatus`
- `com.lumina.model.UserOrder`
- `com.lumina.repository.OrderItemRepository`
- `com.lumina.repository.ProductRepository`
- `com.lumina.repository.UserOrderRepository`
- `com.lumina.exception.BadRequestException`
- `com.lumina.exception.ResourceNotFoundException`
- `com.lumina.dto.request.OrderItemRequest`
- `com.lumina.dto.request.OrderRequest`
- `com.lumina.dto.request.OrderStatusRequest`
- `com.lumina.dto.response.OrderResponse`

`service/CustomCandleService.java`:

- `com.lumina.model.CustomCandle`
- `com.lumina.repository.CustomCandleRepository`
- `com.lumina.exception.ResourceNotFoundException`
- `com.lumina.dto.request.CustomCandleRequest`

Notas:

- `UserService` y `CustomCandleService` quedan en el mismo paquete `service`, así que se elimina el import cruzado entre ellos.
- Los DTOs de `dto/request` no necesitan imports de `com.lumina`, salvo que referencien otro DTO del mismo paquete.
- No cambiar validaciones, lógica ni nombres de métodos.

### Criterio de terminado

- [ ] Los 4 servicios están en `com.lumina.service`.
- [ ] Los 8 DTOs de entrada están en `com.lumina.dto.request`.
- [ ] Cada servicio importa sus dependencias desde `model`, `repository`, `exception`, `dto.request`, `dto.response` y `util`.
- [ ] No quedan imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido`, `com.lumina.vela` ni `com.lumina.common` en los archivos de este rol.
- [ ] El commit del rol está subido y el PR apunta a `refactor/mvc-integration`.

---

## Rol D: controladores, DTOs de salida, documentación e integración

### Archivos

Mover a `com.lumina.controller`:

- `usuario/UserController.java`
- `producto/ProductController.java`
- `pedido/OrderController.java`
- `vela/CustomCandleController.java`

Mover a `com.lumina.dto.response`:

- `usuario/UserResponse.java`
- `pedido/OrderResponse.java`
- `common/ApiError.java`

Documentación:

- Crear o mantener `MIGRACION_MVC.md`.
- Actualizar `README.md` con la nueva estructura.
- Agregar una nota en `MVP_IMPLEMENTACION.md` indicando que su estructura corresponde a la entrega anterior.

### Comandos

```bash
mkdir -p src/main/java/com/lumina/controller src/main/java/com/lumina/dto/response

git mv src/main/java/com/lumina/usuario/UserController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/producto/ProductController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/pedido/OrderController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/vela/CustomCandleController.java src/main/java/com/lumina/controller/

git mv src/main/java/com/lumina/usuario/UserResponse.java src/main/java/com/lumina/dto/response/
git mv src/main/java/com/lumina/pedido/OrderResponse.java src/main/java/com/lumina/dto/response/
git mv src/main/java/com/lumina/common/ApiError.java src/main/java/com/lumina/dto/response/
```

### Ajustes de imports

`controller/UserController.java`:

- `com.lumina.dto.request.LoginRequest`
- `com.lumina.dto.request.RegisterRequest`
- `com.lumina.dto.request.UpdateUserRequest`
- `com.lumina.dto.response.UserResponse`
- `com.lumina.service.UserService`

`controller/ProductController.java`:

- `com.lumina.dto.request.ProductRequest`
- `com.lumina.model.Product`
- `com.lumina.service.ProductService`

`controller/OrderController.java`:

- `com.lumina.dto.request.OrderRequest`
- `com.lumina.dto.request.OrderStatusRequest`
- `com.lumina.dto.response.OrderResponse`
- `com.lumina.service.OrderService`

`controller/CustomCandleController.java`:

- `com.lumina.dto.request.CustomCandleRequest`
- `com.lumina.model.CustomCandle`
- `com.lumina.service.CustomCandleService`

`dto/response/UserResponse.java`:

- `com.lumina.model.AppUser`

`dto/response/OrderResponse.java`:

- `com.lumina.model.UserOrder`
- `com.lumina.model.OrderItem`

`dto/response/ApiError.java`:

- Sin imports de `com.lumina`.

No cambiar rutas, anotaciones `@RequestMapping`, códigos HTTP ni nombres de DTOs.

### Responsabilidad de integración

El Rol D actúa como responsable de integración:

- [ ] Crear la rama `refactor/mvc-integration` desde `main`.
- [ ] Revisar que cada rol respete el contrato de paquetes.
- [ ] Unir los PR en orden A, B, C, D.
- [ ] Ejecutar el build final.
- [ ] Ejecutar el smoke test.
- [ ] Corregir únicamente imports o referencias faltantes; no rediseñar ni cambiar lógica.
- [ ] Actualizar este documento con los checks marcados y los resultados.
- [ ] Fusionar a `main` solo cuando todo esté verde.

### Criterio de terminado

- [ ] Los 4 controladores están en `com.lumina.controller`.
- [ ] Los 3 DTOs de salida están en `com.lumina.dto.response`.
- [ ] `README.md` muestra la estructura MVC.
- [ ] `MIGRACION_MVC.md` está actualizado.
- [ ] `MVP_IMPLEMENTACION.md` tiene la nota de estructura histórica.
- [ ] Los 4 roles están integrados.
- [ ] El build y el smoke test pasan.
- [ ] `main` sigue intacto hasta el merge final.

---

## Verificación final de integración

Ejecutar en `refactor/mvc-integration` después de unir los 4 roles:

```bash
mvn -q -DskipTests package
```

Debe terminar sin errores.

Buscar paquetes viejos:

```bash
grep -REn "package com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
```

Ambos comandos deben quedar sin resultados.

Verificar la estructura:

```bash
find src/main/java/com/lumina -maxdepth 3 -type d | sort
```

Debe mostrar:

```text
com/lumina/controller
com/lumina/dto/request
com/lumina/dto/response
com/lumina/exception
com/lumina/model
com/lumina/repository
com/lumina/service
com/lumina/util
com/lumina/config
```

## Smoke test final

Como el proyecto no tiene tests automatizados en `src/test`, validar con H2:

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2 -Dspring-boot.run.arguments=--server.port=18080
```

Probar:

1. `POST /api/registro`
2. `POST /api/productos` con `category` como texto
3. `POST /api/pedidos`
4. `PUT /api/pedidos/{id}/estado` con `{"status":"CONFIRMED"}`
5. `POST /api/velas-personalizadas`
6. `GET /api/productos?categoria=navidad`

Resultado esperado: los mismos valores funcionales que antes de la migración.

- [ ] Registro OK.
- [ ] Producto creado con categoría de texto.
- [ ] Pedido creado sin cupón.
- [ ] Estado actualizado a `CONFIRMED`.
- [ ] Stock descontado.
- [ ] Vela personalizada creada.
- [ ] Filtro por categoría devuelve el producto.
- [ ] Aplicación detenida y puerto `18080` libre.

## Reglas para evitar conflictos y errores de compilación

- [ ] Cada integrante edita únicamente los archivos de su rol.
- [ ] No se renombran clases ni métodos.
- [ ] No se cambia lógica de negocio.
- [ ] No se toca `pom.xml`, `application.properties` ni `application-h2.properties`.
- [ ] No se hace reemplazo global de paquetes; cada clase tiene un destino distinto.
- [ ] Se usa `git mv` para conservar historial.
- [ ] Se actualiza primero el `package` y luego los imports.
- [ ] Cada rol revisa sus imports contra el contrato de paquetes antes del PR.
- [ ] El build completo se hace en la rama de integración, no en ramas parciales.
- [ ] `main` no recibe merges hasta que la integración esté verde.
- [ ] El responsable de integración revisa los PR y ejecuta el smoke test final.

## Rollback

- Antes del merge: cerrar el PR y borrar la rama del rol.
- En integración: volver al commit base con `git reset --hard <commit-base>`.
- Después del merge a `main`: revertir el commit de integración con `git revert <hash>`.
- No usar `git reset --hard` sobre `main` compartido.

## Resultado esperado

Al finalizar:

- [ ] El proyecto compila con `mvn -q -DskipTests package`.
- [ ] No quedan paquetes por dominio (`usuario`, `producto`, `pedido`, `vela`, `common`).
- [ ] La estructura MVC está completa.
- [ ] Los endpoints y DTOs siguen funcionando igual.
- [ ] La documentación refleja la nueva estructura.
- [ ] Los 4 integrantes trabajaron sin editar los mismos archivos.
