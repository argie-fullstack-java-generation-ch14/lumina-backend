# Migración a Arquitectura por Capas - Lumina Backend

**Estado:** planificado, sin ejecutar.

## Rama de trabajo

El refactor nace de la rama base `refactor/capa-integration`, creada desde `main`. Cada integrante crea su rama hija a partir de `refactor/capa-integration`, trabaja solo en sus archivos y abre un Pull Request hacia esa misma rama base. Si no hay conflictos, se hace merge directamente a `refactor/capa-integration`; si hay conflictos, se resuelven y luego se hace el merge. Solo al final, con los 4 roles integrados y el build verde, `refactor/capa-integration` se fusiona a `main`.

## Estrategia de ramas y Git

1. El responsable de integración crea la rama base desde `main`:

   ```bash
   git switch main
   git pull
   git switch -c refactor/capa-integration
   git push -u origin refactor/capa-integration
   ```

2. Cada integrante crea su rama desde `refactor/capa-integration`:

   ```bash
   git switch refactor/capa-integration
   git pull
   git switch -c refactor/capa-modelo   # ejemplo para el Rol A
   ```

3. Nombres sugeridos de rama:

   | Rol | Rama |
   |-----|------|
   | A | `refactor/capa-modelo` |
   | B | `refactor/capa-persistencia` |
   | C | `refactor/capa-servicios` |
   | D | `refactor/capa-api` |

4. Cada integrante trabaja solo en los archivos de su rol y abre un PR hacia `refactor/capa-integration`.
5. Argie (Rol C) une los 4 PR en este orden recomendado: **A, B, C, D**. Si el PR no tiene conflictos, se hace merge directamente; si tiene conflictos, se resuelven y luego se hace el merge. No es necesaria la aprobación formal del PR por temas de tiempo.
6. El build y el smoke test se ejecutan al final, con los 4 roles integrados.
7. Si todo pasa, `refactor/capa-integration` se fusiona a `main`.

## Reglas para evitar conflictos

- [ ] No renombrar clases, métodos, records, enums ni constructores.
- [ ] No cambiar firmas de métodos ni rutas REST.
- [ ] No cambiar lógica de negocio.
- [ ] No tocar `pom.xml`, `application.properties` ni `application-h2.properties`.
- [ ] Usar `git mv` para conservar historial.
- [ ] Actualizar primero el `package` y luego los imports.
- [ ] El build completo se valida en la rama de integración, no en ramas parciales.
- [ ] `main` no recibe merges hasta que la integración compile y pase el smoke test.

---
## Objetivo

Reorganizar el backend de Lumina desde paquetes por dominio (`usuario`, `producto`, `pedido`, `vela`, `common`) hacia una arquitectura por capas (layered architecture), sin cambiar:

- Endpoints REST (rutas y anotaciones Spring)
- Nombres de clases, métodos, records y componentes
- DTOs y esquema de base de datos
- Lógica de negocio

El código, las rutas y los mensajes siguen en español.

## Capas objetivo

| Capa | Paquete | Responsabilidad |
|------|---------|-----------------|
| Configuración | `com.lumina.config` | `DataInitializer`, `WebConfig` (PasswordEncoder bean) |
| Controlador | `com.lumina.controller` | `@RestController`, endpoints REST |
| DTO | `com.lumina.dto` | `dto/request/` y `dto/response/` |
| CORS | `com.lumina.cors` | Configuración CORS (extraída de `WebConfig`) |
| Modelo | `com.lumina.model` | Entidades JPA y enums |
| Repositorio | `com.lumina.repository` | Interfaces `JpaRepository` |
| Servicio | `com.lumina.service` | Lógica de negocio, `@Service`, `@Transactional` |
| Excepción | `com.lumina.exception` | Excepciones personalizadas y `GlobalExceptionHandler` |

**No se mueven:** `LuminaApiApplication.java` (queda en `com.lumina`).

**Nota sobre `SlugUtil`:** no encaja en las 8 capas listadas. Se recomienda crear `com.lumina.util.SlugUtil` como capa de soporte, o dejarlo en `com.lumina.service` si se prefiere no añadir paquetes extra.

## Estructura de directorios objetivo

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
├── cors/
│   └── CorsConfig.java
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
└── service/
    ├── CustomCandleService.java
    ├── OrderService.java
    ├── ProductService.java
    └── UserService.java
```

## Contrato de paquetes (fijo)

| Elemento | Paquete destino |
|----------|-----------------|
| Entidades JPA + enum `OrderStatus` | `com.lumina.model` |
| Repositorios Spring Data | `com.lumina.repository` |
| Servicios | `com.lumina.service` |
| Controladores REST | `com.lumina.controller` |
| DTOs de entrada | `com.lumina.dto.request` |
| DTOs de salida | `com.lumina.dto.response` |
| Excepciones + `GlobalExceptionHandler` | `com.lumina.exception` |
| Configuración CORS | `com.lumina.cors` |
| Configuración general | `com.lumina.config` |
| Clase principal | `com.lumina` |

## Glosario breve

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

## Mapa FQCN actual → nuevo

### Modelo
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.AppUser` | `com.lumina.model.AppUser` |
| `com.lumina.usuario.Role` | `com.lumina.model.Role` |
| `com.lumina.producto.Product` | `com.lumina.model.Product` |
| `com.lumina.pedido.UserOrder` | `com.lumina.model.UserOrder` |
| `com.lumina.pedido.OrderItem` | `com.lumina.model.OrderItem` |
| `com.lumina.pedido.OrderStatus` | `com.lumina.model.OrderStatus` |
| `com.lumina.vela.CustomCandle` | `com.lumina.model.CustomCandle` |

### Repositorios
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.AppUserRepository` | `com.lumina.repository.AppUserRepository` |
| `com.lumina.usuario.RoleRepository` | `com.lumina.repository.RoleRepository` |
| `com.lumina.producto.ProductRepository` | `com.lumina.repository.ProductRepository` |
| `com.lumina.pedido.UserOrderRepository` | `com.lumina.repository.UserOrderRepository` |
| `com.lumina.pedido.OrderItemRepository` | `com.lumina.repository.OrderItemRepository` |
| `com.lumina.vela.CustomCandleRepository` | `com.lumina.repository.CustomCandleRepository` |

### Servicios
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.UserService` | `com.lumina.service.UserService` |
| `com.lumina.producto.ProductService` | `com.lumina.service.ProductService` |
| `com.lumina.pedido.OrderService` | `com.lumina.service.OrderService` |
| `com.lumina.vela.CustomCandleService` | `com.lumina.service.CustomCandleService` |

### Controladores
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.UserController` | `com.lumina.controller.UserController` |
| `com.lumina.producto.ProductController` | `com.lumina.controller.ProductController` |
| `com.lumina.pedido.OrderController` | `com.lumina.controller.OrderController` |
| `com.lumina.vela.CustomCandleController` | `com.lumina.controller.CustomCandleController` |

### DTOs de entrada
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.LoginRequest` | `com.lumina.dto.request.LoginRequest` |
| `com.lumina.usuario.RegisterRequest` | `com.lumina.dto.request.RegisterRequest` |
| `com.lumina.usuario.UpdateUserRequest` | `com.lumina.dto.request.UpdateUserRequest` |
| `com.lumina.producto.ProductRequest` | `com.lumina.dto.request.ProductRequest` |
| `com.lumina.pedido.OrderRequest` | `com.lumina.dto.request.OrderRequest` |
| `com.lumina.pedido.OrderItemRequest` | `com.lumina.dto.request.OrderItemRequest` |
| `com.lumina.pedido.OrderStatusRequest` | `com.lumina.dto.request.OrderStatusRequest` |
| `com.lumina.vela.CustomCandleRequest` | `com.lumina.dto.request.CustomCandleRequest` |

### DTOs de salida
| Actual | Nuevo |
|--------|-------|
| `com.lumina.usuario.UserResponse` | `com.lumina.dto.response.UserResponse` |
| `com.lumina.pedido.OrderResponse` | `com.lumina.dto.response.OrderResponse` |
| `com.lumina.common.ApiError` | `com.lumina.dto.response.ApiError` |

### Excepciones y CORS
| Actual | Nuevo |
|--------|-------|
| `com.lumina.common.BadRequestException` | `com.lumina.exception.BadRequestException` |
| `com.lumina.common.ConflictException` | `com.lumina.exception.ConflictException` |
| `com.lumina.common.ResourceNotFoundException` | `com.lumina.exception.ResourceNotFoundException` |
| `com.lumina.common.UnauthorizedException` | `com.lumina.exception.UnauthorizedException` |
| `com.lumina.common.GlobalExceptionHandler` | `com.lumina.exception.GlobalExceptionHandler` |
| `com.lumina.config.WebConfig` (CORS) | `com.lumina.cors.CorsConfig` |

### No se mueven
- `com.lumina.LuminaApiApplication`
- `com.lumina.config.WebConfig` (queda con `PasswordEncoder`; CORS se extrae a `cors`)
- `com.lumina.config.DataInitializer` (solo actualiza imports)

## Flujo de dependencias entre capas (regla de diseño)

```
controller  →  service  →  repository  →  model
   ↑           ↑           ↑
   │           │           └── exception
   │           └── dto.request / dto.response / model / util
   └── dto.request / dto.response / service
```

- **Controller** solo depende de `service` y `dto`.
- **Service** depende de `repository`, `model`, `dto.request`, `dto.response`, `exception`, `util`.
- **Repository** depende solo de `model`.
- **Exception** depende de `dto.response` (`ApiError` en `GlobalExceptionHandler`).
- **Cors** es independiente (configuración de Spring MVC).
- **Config** es independiente (`DataInitializer` usa `model` + `repository`).

**Prohibido:** dependencias hacia atrás (ej. service no llama a controller; repository no llama a service).

## Guía rápida para llamadas entre roles

Esta tabla evita preguntar "¿cómo se va a llamar?" o "¿en qué paquete queda?".

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

## Pasos de migración (orden recomendado)

La migración es **atómica para el compilador**: el build fallará hasta que todas las capas estén integradas. Se recomienda hacer la migración en una rama de integración y unir los cambios en este orden:

1. **Capa modelo** (`model` + `util` opcional): mover 7 entidades/enum y `SlugUtil`; ajustar `package` y quitar imports intra-paquete que ya sobran.
2. **Capa repositorio** (`repository`): mover 6 repositorios; cada uno importa su entidad de `com.lumina.model`.
3. **Capa excepción** (`exception`): mover 5 excepciones + `GlobalExceptionHandler`; este último importa `com.lumina.dto.response.ApiError`.
4. **Capa CORS** (`cors`): crear `CorsConfig` extrayendo la lógica CORS de `WebConfig`; `WebConfig` conserva solo `PasswordEncoder`.
5. **Capa DTO** (`dto/request`, `dto/response`): mover 8 DTOs de entrada y 3 DTOs de salida + `ApiError`; ajustar imports a `model` cuando sea necesario.
6. **Capa servicio** (`service`): mover 4 servicios; actualizar imports a `model`, `repository`, `exception`, `dto.request`, `dto.response`, `util`.
7. **Capa controlador** (`controller`): mover 4 controladores; actualizar imports a `service`, `dto.request`, `dto.response`, `model`.
8. **Config** (`config`): actualizar `DataInitializer` para importar `com.lumina.model.Role` y `com.lumina.repository.RoleRepository`.
9. **Limpieza:** eliminar paquetes viejos (`usuario`, `producto`, `pedido`, `vela`, `common`) una vez vacíos.
10. **Verificación:** build, búsqueda de paquetes viejos, smoke test.

## Ajustes clave por archivo

- `WebConfig.java`: separar CORS a `com.lumina.cors.CorsConfig`; `WebConfig` conserva `@Bean PasswordEncoder`.
- `DataInitializer.java`: cambiar imports a `com.lumina.model.Role` y `com.lumina.repository.RoleRepository`.
- `GlobalExceptionHandler.java`: cambiar `package` a `com.lumina.exception`; importar `com.lumina.dto.response.ApiError`.
- Entidades en `model`: quitar imports de clases que quedan en el mismo paquete (`model`).
- Repositorios en `repository`: importar entidades desde `com.lumina.model`.

## Reparto de trabajo entre 4 personas

| Rol | Capas encargadas | Archivos a mover/editar | Paquetes destino | Integrante |
|-----|------------------|-------------------------|------------------|------------|
| **A** | Modelo + Utilidades | 7 entidades/enum + `SlugUtil` | `com.lumina.model`, `com.lumina.util` | Pedro |
| **B** | Persistencia + Excepciones + CORS + Config | 6 repositorios + 5 excepciones + `GlobalExceptionHandler` + `CorsConfig` + ajustes en `WebConfig` y `DataInitializer` | `com.lumina.repository`, `com.lumina.exception`, `com.lumina.cors`, `com.lumina.config` | Nicole |
| **C** | Servicios + DTOs de entrada | 4 servicios + 8 DTOs request | `com.lumina.service`, `com.lumina.dto.request` | Argie |
| **D** | Controladores + DTOs de salida | 4 controladores + 3 DTOs response + `ApiError` | `com.lumina.controller`, `com.lumina.dto.response` | Naya |
| **Integración** | Build, smoke test, merge a `main`, revisión de `README.md` vs estructura final | Unir PRs A→B→C→D, ejecutar build, ejecutar smoke test, validar documentación, merge a `main`, limpiar paquetes viejos | `com.lumina` (raíz) + documentación | Argie |

### Reglas para evitar conflictos y errores de compilación

- Cada integrante edita únicamente los archivos de su rol.
- No se renombran clases ni métodos.
- No se cambia lógica de negocio.
- No se hace reemplazo global de paquetes; cada clase tiene un destino distinto.
- Se usa `git mv` para conservar historial.
- Se actualiza primero el `package` y luego los imports.
- Cada rol revisa sus imports contra el contrato de paquetes antes del PR.
- El build completo se hace en la rama de integración, no en ramas parciales.
- `main` no recibe merges hasta que la integración esté verde.

### Checklist rápido por rol

## Rol A: modelo y utilidades · [Paso a paso detallado](MIGRACION_CAPAS_PASO_A_PASO.md#rol-a)
- [ ] 7 entidades en `com.lumina.model` con `package` actualizado.
- [ ] `SlugUtil` en `com.lumina.util`.
- [ ] Quitar imports de clases que ahora están en el mismo paquete `model`.
- [ ] Sin imports de `usuario`, `producto`, `pedido`, `vela` dentro de `model`/`util`.

## Rol B: persistencia, excepciones y configuración · [Paso a paso detallado](MIGRACION_CAPAS_PASO_A_PASO.md#rol-b)
- [ ] 6 repositorios en `com.lumina.repository` importando entidades de `com.lumina.model`.
- [ ] 5 excepciones + `GlobalExceptionHandler` en `com.lumina.exception`.
- [ ] `CorsConfig` creado en `com.lumina.cors` extrayendo CORS de `WebConfig`.
- [ ] `WebConfig` conserva solo `@Bean PasswordEncoder`.
- [ ] `DataInitializer` importa `com.lumina.model.Role` y `com.lumina.repository.RoleRepository`.
- [ ] Sin imports de `com.lumina.common` en archivos de este rol.

## Rol C: servicios y DTOs de entrada · [Paso a paso detallado](MIGRACION_CAPAS_PASO_A_PASO.md#rol-c)
- [ ] 4 servicios en `com.lumina.service`.
- [ ] 8 DTOs request en `com.lumina.dto.request`.
- [ ] Imports corregidos a `model`, `repository`, `exception`, `dto.request`, `dto.response`, `util`.
- [ ] Sin imports de `usuario`, `producto`, `pedido`, `vela`, `common`.

## Rol D: controladores y DTOs de salida · [Paso a paso detallado](MIGRACION_CAPAS_PASO_A_PASO.md#rol-d)
- [ ] 4 controladores en `com.lumina.controller`.
- [ ] 3 DTOs response + `ApiError` en `com.lumina.dto.response`.
- [ ] Imports corregidos a `service`, `dto.request`, `dto.response`, `model`.

**Argie (Integración y validación de documentación — además del Rol C)**
- [ ] Unir PRs A→B→C→D en `refactor/capa-integration`.
- [ ] Ejecutar build completo (`mvn -q -DskipTests package`).
- [ ] Verificar que no queden paquetes viejos (`grep` de `usuario`, `producto`, `pedido`, `vela`, `common`).
- [ ] Verificar estructura de directorios esperada.
- [ ] Ejecutar smoke test final (H2).
- [ ] Validar que `README.md` coincida con la estructura final por capas.
- [ ] Mergear `refactor/capa-integration` a `main`.
- [ ] Eliminar paquetes viejos una vez vacíos.

## Integración y validación (Argie)

**Responsable:** Argie (además del Rol C — Servicios y DTOs de entrada)  
**Cuándo:** Después de que los 4 PR (A, B, C, D) estén aprobados y mergeados en la rama base `refactor/capa-integration`.

> **Importante:** Cada integrante abre su PR hacia la rama base `refactor/capa-integration`, **no hacia `main`**. La integración y el merge a `main` son tareas exclusivas de esta etapa final, a cargo de Argie.

### Paso 1: Unir los PR en orden A → B → C → D

1. Verificar que los PR de los roles A, B, C y D estén aprobados.
2. Mergear cada PR hacia `refactor/capa-integration` en el orden recomendado: **A, luego B, luego C, luego D**.
3. Hacer pull de la rama de integración:

```bash
git switch refactor/capa-integration
git pull
```

### Paso 2: Ejecutar el build completo

```bash
mvn -q -DskipTests package
```

### Paso 3: Verificar que no queden paquetes viejos

```bash
grep -REn "package com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
```

### Paso 4: Verificar la estructura de directorios

```bash
find src/main/java/com/lumina -maxdepth 3 -type d | sort
```

Debe mostrar: `config`, `controller`, `dto`, `dto/request`, `dto/response`, `cors`, `exception`, `model`, `repository`, `service` (y opcionalmente `util`).

### Paso 5: Smoke test final (H2)

1. Ejecutar la aplicación con perfil H2:

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2 -Dspring-boot.run.arguments=--server.port=18080
```

2. Probar en orden:
   - `POST /api/registro`
   - `POST /api/productos` con `category` como texto
   - `POST /api/pedidos`
   - `PUT /api/pedidos/{id}/estado` con `{"status":"CONFIRMED"}`
   - `POST /api/velas-personalizadas`
   - `GET /api/productos?categoria=navidad`

3. Resultado esperado: mismos valores funcionales que antes de la migración.

### Paso 6: Validar la documentación (`README.md`)

1. Abrir `README.md` en la raíz del backend.
2. Verificar que la sección de estructura del proyecto refleje los nuevos paquetes por capas:

```
src/main/java/com/lumina
├── LuminaApiApplication.java
├── config/
├── controller/
├── dto/
│   ├── request/
│   └── response/
├── cors/
├── exception/
├── model/
├── repository/
└── service/
```

3. Verificar que el flujo de dependencias entre capas esté documentado correctamente.
4. Guardar los cambios si es necesario.

### Paso 7: Merge a `main`

Si el build y el smoke test pasan, fusionar `refactor/capa-integration` a `main`:

```bash
git switch main
git pull
git merge --no-ff refactor/capa-integration
git push origin main
```

### Paso 8: Limpieza — eliminar paquetes viejos

Una vez que todos los paquetes estén vacíos, eliminar los paquetes antiguos:

- `usuario`
- `producto`
- `pedido`
- `vela`
- `common`

## Rollback

- Antes del merge: cerrar PR y borrar rama.
- En integración: `git reset --hard <commit-base>`.
- Después del merge a `main`: `git revert <hash>` (no usar `reset --hard` sobre `main` compartido).
