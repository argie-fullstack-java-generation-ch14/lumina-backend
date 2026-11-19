# Migración MVC: paso a paso por rol

Este documento complementa a `MIGRACION_MVC.md`. Aquí está el detalle operativo, archivo por archivo, para que cada integrante ejecute su rol sin improvisar. El contrato de nombres, firmas y paquetes sigue siendo el de `MIGRACION_MVC.md`; si hay conflicto entre los dos documentos, manda el contrato.

## Cómo usar este documento

1. Lee primero `MIGRACION_MVC.md`, secciones **Contrato de paquetes** y **Contrato interno de nombres y firmas**.
2. Ubica tu rol (A, B, C o D) y sigue los pasos en orden.
3. No edites archivos de otro rol.
4. No ejecutes el build completo en tu rama parcial: va a fallar hasta que los 4 roles estén unidos. Eso es esperado.
5. Antes de abrir el PR, corre la verificación de tu rol.

## Escala de dificultad

| Nivel | Significado |
|---|---|
| 1 | Muy fácil: cambios mecánicos, sin dependencias cruzadas. |
| 2 | Fácil: varios archivos, pero reglas simples y repetitivas. |
| 3 | Medio: requiere entender imports entre paquetes y algún archivo con más referencias. |
| 4 | Difícil: muchos imports cruzados y riesgo alto de dejar referencias viejas. |
| 5 | Muy difícil: coordina a todo el equipo, integra, compila y prueba el sistema completo. |

---

## Rol A: modelo y utilidades — Dificultad 2 de 5

**Objetivo:** mover las 7 entidades/enum a `com.lumina.model` y `SlugUtil` a `com.lumina.util`.

**Por qué es 2 de 5:** son 8 archivos, casi todos solo cambian de `package`. Solo 3 archivos requieren borrar imports que quedan en el mismo paquete.

### Antes de empezar

```bash
git switch refactor/mvc-integration
git pull
git switch -c refactor/mvc-rol-a-modelo
mkdir -p src/main/java/com/lumina/model src/main/java/com/lumina/util
```

### Paso 1: mover los archivos

```bash
git mv src/main/java/com/lumina/usuario/AppUser.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/usuario/Role.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/producto/Product.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/UserOrder.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/OrderItem.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/pedido/OrderStatus.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/vela/CustomCandle.java src/main/java/com/lumina/model/
git mv src/main/java/com/lumina/producto/SlugUtil.java src/main/java/com/lumina/util/
```

### Paso 2: ajustar cada archivo

#### `model/AppUser.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.model;`.
- No borrar ni agregar imports de `com.lumina` (no tiene).
- Conservar `jakarta.persistence.*`, `java.time.LocalDateTime` y `com.fasterxml.jackson.annotation.JsonIgnore`.

#### `model/Role.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.model;`.
- Conservar `jakarta.persistence.*` y `java.time.LocalDateTime`.

#### `model/Product.java`

- Cambiar `package com.lumina.producto;` por `package com.lumina.model;`.
- Conservar `jakarta.persistence.*`, `java.math.BigDecimal` y `java.time.LocalDateTime`.

#### `model/UserOrder.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.model;`.
- **Borrar** `import com.lumina.usuario.AppUser;` porque `AppUser` ahora está en el mismo paquete.
- Conservar `jakarta.persistence.*`, `java.math.BigDecimal` y `java.time.LocalDateTime`.

#### `model/OrderItem.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.model;`.
- **Borrar** `import com.lumina.producto.Product;`.
- **Borrar** `import com.lumina.vela.CustomCandle;`.
- Conservar `jakarta.persistence.*` y `java.math.BigDecimal`.

#### `model/OrderStatus.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.model;`.
- No tiene imports que tocar.

#### `model/CustomCandle.java`

- Cambiar `package com.lumina.vela;` por `package com.lumina.model;`.
- **Borrar** `import com.lumina.usuario.AppUser;`.
- Conservar `jakarta.persistence.*`, `java.math.BigDecimal` y `java.time.LocalDateTime`.

#### `util/SlugUtil.java`

- Cambiar `package com.lumina.producto;` por `package com.lumina.util;`.
- Conservar `java.text.Normalizer`.

### Paso 3: verificar tu rol

```bash
grep -Rn "^package com.lumina.model;" src/main/java/com/lumina/model | wc -l
grep -Rn "^package com.lumina.util;" src/main/java/com/lumina/util | wc -l
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java/com/lumina/model src/main/java/com/lumina/util || true
```

Esperado:

- Primer comando: `7`.
- Segundo comando: `1`.
- Tercer comando: sin resultados.

### Paso 4: commit y PR

```bash
git add src/main/java/com/lumina/model src/main/java/com/lumina/util
git commit -m "refactor(mvc): mover modelo y utilidades a sus paquetes finales"
git push -u origin refactor/mvc-rol-a-modelo
```

Abre el PR hacia `refactor/mvc-integration`.

### Criterio de terminado

- [ ] 7 archivos en `src/main/java/com/lumina/model/`.
- [ ] `SlugUtil.java` en `src/main/java/com/lumina/util/`.
- [ ] Ningún import de `usuario`, `producto`, `pedido`, `vela` o `common` dentro de `model` y `util`.
- [ ] No se cambió lógica, anotaciones JPA ni nombres de campos.
- [ ] PR abierto hacia `refactor/mvc-integration`.

---

## Rol B: persistencia, excepciones y configuración — Dificultad 3 de 5

**Objetivo:** mover 6 repositorios a `com.lumina.repository`, 5 clases de excepciones a `com.lumina.exception` y actualizar los imports de `DataInitializer` sin moverlo.

**Por qué es 3 de 5:** son 11 archivos movidos más 1 actualizado. La mayoría son cambios simples, pero `GlobalExceptionHandler` cruza a `dto.response` y los repositorios deben importar sus entidades.

### Antes de empezar

```bash
git switch refactor/mvc-integration
git pull
git switch -c refactor/mvc-rol-b-persistencia
mkdir -p src/main/java/com/lumina/repository src/main/java/com/lumina/exception
```

### Paso 1: mover repositorios y excepciones

```bash
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

### Paso 2: ajustar repositorios

Todos cambian su `package` al paquete nuevo y agregan el import de su entidad.

#### `repository/AppUserRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.AppUser;
```

Conservar `org.springframework.data.jpa.repository.JpaRepository` y `java.util.Optional`.

#### `repository/RoleRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.Role;
```

#### `repository/ProductRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.Product;
```

Conservar `java.util.List` y `java.util.Optional`.

#### `repository/UserOrderRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.UserOrder;
```

#### `repository/OrderItemRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.OrderItem;
```

#### `repository/CustomCandleRepository.java`

```java
package com.lumina.repository;

import com.lumina.model.CustomCandle;
```

No tocar los métodos derivados (`findByEmail`, `findBySlug`, `findByUserId`, etc.).

### Paso 3: ajustar excepciones

#### `exception/BadRequestException.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.exception;`.
- No tiene imports de `com.lumina` que tocar.

#### `exception/ConflictException.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.exception;`.

#### `exception/ResourceNotFoundException.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.exception;`.

#### `exception/UnauthorizedException.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.exception;`.

#### `exception/GlobalExceptionHandler.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.exception;`.
- **Agregar** `import com.lumina.dto.response.ApiError;`.
- Las 4 excepciones hermanas quedan en el mismo paquete, así que no necesitan import.
- Conservar todos los imports de Spring (`ResponseEntity`, `HttpStatus`, `DataIntegrityViolationException`, `HttpMessageNotReadableException`, `MethodArgumentNotValidException`, `MethodArgumentTypeMismatchException`, anotaciones).
- Conservar `java.util.List`.

### Paso 4: actualizar `config/DataInitializer.java` sin moverlo

- Mantener `package com.lumina.config;`.
- **Reemplazar** `import com.lumina.usuario.Role;` por `import com.lumina.model.Role;`.
- **Reemplazar** `import com.lumina.usuario.RoleRepository;` por `import com.lumina.repository.RoleRepository;`.
- No tocar la lógica de creación de roles.

### Paso 5: verificar tu rol

```bash
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java/com/lumina/repository src/main/java/com/lumina/exception src/main/java/com/lumina/config/DataInitializer.java || true
grep -Rn "com.lumina.dto.response.ApiError" src/main/java/com/lumina/exception/GlobalExceptionHandler.java
grep -Rn "com.lumina.model.Role\|com.lumina.repository.RoleRepository" src/main/java/com/lumina/config/DataInitializer.java
```

Esperado:

- Primer comando: sin resultados.
- Segundo comando: 1 línea.
- Tercer comando: 2 líneas.

### Paso 6: commit y PR

```bash
git add src/main/java/com/lumina/repository src/main/java/com/lumina/exception src/main/java/com/lumina/config/DataInitializer.java
git commit -m "refactor(mvc): mover persistencia y excepciones a sus paquetes finales"
git push -u origin refactor/mvc-rol-b-persistencia
```

Abre el PR hacia `refactor/mvc-integration`.

### Criterio de terminado

- [ ] 6 repositorios en `com.lumina.repository`, cada uno importa su entidad de `com.lumina.model`.
- [ ] 5 clases en `com.lumina.exception`.
- [ ] `GlobalExceptionHandler` importa `com.lumina.dto.response.ApiError`.
- [ ] `DataInitializer` sigue en `com.lumina.config` e importa `Role` y `RoleRepository` desde sus paquetes nuevos.
- [ ] No quedan imports de `com.lumina.common` en los archivos de este rol.
- [ ] PR abierto hacia `refactor/mvc-integration`.

---

## Rol C: servicios y DTOs de entrada — Dificultad 4 de 5

**Objetivo:** mover 4 servicios a `com.lumina.service` y 8 DTOs de entrada a `com.lumina.dto.request`.

**Por qué es 4 de 5:** son 12 archivos y aquí está la mayor cantidad de imports cruzados. `OrderService` es el archivo más delicado porque usa modelos, repositorios, excepciones, DTOs de entrada, DTO de salida y otro servicio.

### Antes de empezar

```bash
git switch refactor/mvc-integration
git pull
git switch -c refactor/mvc-rol-c-servicios
mkdir -p src/main/java/com/lumina/service src/main/java/com/lumina/dto/request
```

### Paso 1: mover servicios y DTOs

```bash
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

### Paso 2: ajustar los servicios

#### `service/UserService.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.service;`.
- **Borrar** los imports viejos de `com.lumina.common.*`.
- Reemplazar los imports por este bloque final:

```java
import com.lumina.dto.request.LoginRequest;
import com.lumina.dto.request.RegisterRequest;
import com.lumina.dto.request.UpdateUserRequest;
import com.lumina.dto.response.UserResponse;
import com.lumina.exception.ConflictException;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.exception.UnauthorizedException;
import com.lumina.model.AppUser;
import com.lumina.model.Role;
import com.lumina.repository.AppUserRepository;
import com.lumina.repository.RoleRepository;
import java.util.List;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
```

No cambiar la lógica de registro, login, actualización, borrado ni `getUser`.

#### `service/ProductService.java`

- Cambiar `package com.lumina.producto;` por `package com.lumina.service;`.
- **Borrar** los imports viejos de `com.lumina.common.*`.
- Reemplazar los imports por este bloque final:

```java
import com.lumina.dto.request.ProductRequest;
import com.lumina.exception.ConflictException;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.model.Product;
import com.lumina.repository.ProductRepository;
import com.lumina.util.SlugUtil;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
```

No cambiar la lógica de slug, creación, actualización ni borrado.

#### `service/OrderService.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.service;`.
- **Borrar** los imports viejos:
  - `com.lumina.common.BadRequestException`
  - `com.lumina.common.ResourceNotFoundException`
  - `com.lumina.producto.Product`
  - `com.lumina.producto.ProductRepository`
  - `com.lumina.usuario.UserService`
- **Importante:** `UserService` ahora está en el mismo paquete `com.lumina.service`, así que **no se importa**. Solo se usa como tipo.
- Reemplazar los imports por este bloque final:

```java
import com.lumina.dto.request.OrderItemRequest;
import com.lumina.dto.request.OrderRequest;
import com.lumina.dto.request.OrderStatusRequest;
import com.lumina.dto.response.OrderResponse;
import com.lumina.exception.BadRequestException;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.model.OrderItem;
import com.lumina.model.OrderStatus;
import com.lumina.model.UserOrder;
import com.lumina.repository.OrderItemRepository;
import com.lumina.repository.ProductRepository;
import com.lumina.repository.UserOrderRepository;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
```

No cambiar el cálculo de totales, el descuento de stock ni la reactivación de stock al cancelar.

#### `service/CustomCandleService.java`

- Cambiar `package com.lumina.vela;` por `package com.lumina.service;`.
- **Borrar** `import com.lumina.common.ResourceNotFoundException;`.
- **Borrar** `import com.lumina.usuario.UserService;` porque queda en el mismo paquete.
- Reemplazar los imports por este bloque final:

```java
import com.lumina.dto.request.CustomCandleRequest;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.model.CustomCandle;
import com.lumina.repository.CustomCandleRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
```

No cambiar la lógica de creación, listado, búsqueda ni borrado.

### Paso 3: ajustar los DTOs de entrada

Todos cambian solo de `package`. Ninguno necesita imports nuevos de `com.lumina`, porque sus referencias internas quedan en el mismo paquete.

#### `dto/request/LoginRequest.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.dto.request;`.

#### `dto/request/RegisterRequest.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.dto.request;`.

#### `dto/request/UpdateUserRequest.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.dto.request;`.

#### `dto/request/ProductRequest.java`

- Cambiar `package com.lumina.producto;` por `package com.lumina.dto.request;`.

#### `dto/request/OrderRequest.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.dto.request;`.
- **No agregar** import de `OrderItemRequest`: queda en el mismo paquete.

#### `dto/request/OrderItemRequest.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.dto.request;`.

#### `dto/request/OrderStatusRequest.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.dto.request;`.

#### `dto/request/CustomCandleRequest.java`

- Cambiar `package com.lumina.vela;` por `package com.lumina.dto.request;`.

No cambiar validaciones (`@NotBlank`, `@NotNull`, `@Size`, etc.) ni nombres de componentes.

### Paso 4: verificar tu rol

```bash
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java/com/lumina/service src/main/java/com/lumina/dto/request || true
grep -Rn "import com.lumina.usuario.UserService" src/main/java/com/lumina/service || true
grep -Rn "^package com.lumina.service;" src/main/java/com/lumina/service | wc -l
grep -Rn "^package com.lumina.dto.request;" src/main/java/com/lumina/dto/request | wc -l
```

Esperado:

- Primer y segundo comando: sin resultados.
- Tercer comando: `4`.
- Cuarto comando: `8`.

### Paso 5: commit y PR

```bash
git add src/main/java/com/lumina/service src/main/java/com/lumina/dto/request
git commit -m "refactor(mvc): mover servicios y DTOs de entrada a sus paquetes finales"
git push -u origin refactor/mvc-rol-c-servicios
```

Abre el PR hacia `refactor/mvc-integration`.

### Criterio de terminado

- [ ] 4 servicios en `com.lumina.service`.
- [ ] 8 DTOs de entrada en `com.lumina.dto.request`.
- [ ] `OrderService` no importa `UserService` (mismo paquete).
- [ ] `CustomCandleService` no importa `UserService` (mismo paquete).
- [ ] No quedan imports de `usuario`, `producto`, `pedido`, `vela` ni `common` en los archivos de este rol.
- [ ] No se cambió lógica de negocio, validaciones ni nombres de métodos.
- [ ] PR abierto hacia `refactor/mvc-integration`.

---

## Rol D: controladores, DTOs de salida, documentación e integración — Dificultad 3 de 5

**Objetivo:** mover 4 controladores a `com.lumina.controller`, 3 DTOs de salida a `com.lumina.dto.response`, actualizar la documentación y actuar como responsable de integración.

**Por qué es 3 de 5:** las tareas de código son mecánicas y de pocos archivos. La integración suma responsabilidad operativa (unir PR, compilar y probar), pero no aumenta la complejidad técnica de los cambios.

### Antes de empezar

```bash
git switch refactor/mvc-integration
git pull
git switch -c refactor/mvc-rol-d-api
mkdir -p src/main/java/com/lumina/controller src/main/java/com/lumina/dto/response
```

### Paso 1: mover controladores y DTOs de salida

```bash
git mv src/main/java/com/lumina/usuario/UserController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/producto/ProductController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/pedido/OrderController.java src/main/java/com/lumina/controller/
git mv src/main/java/com/lumina/vela/CustomCandleController.java src/main/java/com/lumina/controller/

git mv src/main/java/com/lumina/usuario/UserResponse.java src/main/java/com/lumina/dto/response/
git mv src/main/java/com/lumina/pedido/OrderResponse.java src/main/java/com/lumina/dto/response/
git mv src/main/java/com/lumina/common/ApiError.java src/main/java/com/lumina/dto/response/
```

### Paso 2: ajustar los controladores

Los controladores hoy no tienen imports de `com.lumina` porque sus dependencias estaban en el mismo paquete. Al moverlos, hay que agregarlos.

#### `controller/UserController.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.controller;`.
- **Agregar**:

```java
import com.lumina.dto.request.LoginRequest;
import com.lumina.dto.request.RegisterRequest;
import com.lumina.dto.request.UpdateUserRequest;
import com.lumina.dto.response.UserResponse;
import com.lumina.service.UserService;
```

- Conservar todos los imports de Spring, `jakarta.validation.Valid` y `java.util.List`.
- No cambiar rutas ni códigos HTTP.

#### `controller/ProductController.java`

- Cambiar `package com.lumina.producto;` por `package com.lumina.controller;`.
- **Agregar**:

```java
import com.lumina.dto.request.ProductRequest;
import com.lumina.model.Product;
import com.lumina.service.ProductService;
```

- No cambiar `@RequestMapping("/api/productos")` ni sus métodos.

#### `controller/OrderController.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.controller;`.
- **Agregar**:

```java
import com.lumina.dto.request.OrderRequest;
import com.lumina.dto.request.OrderStatusRequest;
import com.lumina.dto.response.OrderResponse;
import com.lumina.service.OrderService;
```

- No cambiar `@RequestMapping("/api/pedidos")` ni la ruta `/estado`.

#### `controller/CustomCandleController.java`

- Cambiar `package com.lumina.vela;` por `package com.lumina.controller;`.
- **Agregar**:

```java
import com.lumina.dto.request.CustomCandleRequest;
import com.lumina.model.CustomCandle;
import com.lumina.service.CustomCandleService;
```

- No cambiar `@RequestMapping("/api/velas-personalizadas")` ni sus métodos.

### Paso 3: ajustar los DTOs de salida

#### `dto/response/UserResponse.java`

- Cambiar `package com.lumina.usuario;` por `package com.lumina.dto.response;`.
- **Agregar** `import com.lumina.model.AppUser;`.
- Conservar `java.time.LocalDateTime` y el método `static from(AppUser)`.

#### `dto/response/OrderResponse.java`

- Cambiar `package com.lumina.pedido;` por `package com.lumina.dto.response;`.
- **Agregar**:

```java
import com.lumina.model.OrderItem;
import com.lumina.model.UserOrder;
```

- Conservar `java.math.BigDecimal`, `java.time.LocalDateTime`, `java.util.List`, el record anidado `Item` y `static from(UserOrder, List<OrderItem>)`.

#### `dto/response/ApiError.java`

- Cambiar `package com.lumina.common;` por `package com.lumina.dto.response;`.
- No tiene imports de `com.lumina` que tocar.
- Conservar `java.time.LocalDateTime`, `java.util.List` y `static of(...)`.

### Paso 4: actualizar la documentación

#### `README.md`

- Reemplazar la sección **Estructura** (la que hoy muestra `usuario/`, `producto/`, `vela/`, `pedido/`, `config/`, `common/`) por la estructura MVC:

```text
com.lumina
├── controller/   endpoints REST
├── dto/
│   ├── request/  datos que entran
│   └── response/ datos que salen
├── exception/    excepciones y manejo global de errores
├── model/        entidades JPA y enum OrderStatus
├── repository/   repositorios Spring Data
├── service/      lógica de negocio
├── util/         SlugUtil
└── config/       CORS, BCrypt y roles básicos
```

- Reemplazar la frase "Los paquetes van por dominio, como se definió en `docs/DESARROLLO.md`" por una que indique arquitectura MVC por capas.
- Reemplazar la frase "Cada dominio tiene sus entidades, su repositorio..., su servicio... y su controlador..." por una explicación por capas.
- No cambiar la tabla de endpoints ni los ejemplos de uso.

#### `MVP_IMPLEMENTACION.md`

- Agregar una nota al inicio, debajo del título, indicando que ese documento describe la entrega anterior (estructura por dominio) y que la estructura vigente es la de `MIGRACION_MVC.md`.
- No reescribir todo el documento: su valor es histórico.

#### `MIGRACION_MVC.md`

- Marcar los checks que se hayan cumplido.
- Anotar el resultado del build y del smoke test cuando se ejecuten.

### Paso 5: verificar tu rol

```bash
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java/com/lumina/controller src/main/java/com/lumina/dto/response || true
grep -Rn "^package com.lumina.controller;" src/main/java/com/lumina/controller | wc -l
grep -Rn "^package com.lumina.dto.response;" src/main/java/com/lumina/dto/response | wc -l
```

Esperado:

- Primer comando: sin resultados.
- Segundo comando: `4`.
- Tercer comando: `3`.

### Paso 6: commit y PR

```bash
git add src/main/java/com/lumina/controller src/main/java/com/lumina/dto/response README.md MVP_IMPLEMENTACION.md MIGRACION_MVC.md
git commit -m "refactor(mvc): mover controladores y DTOs de salida y actualizar documentacion"
git push -u origin refactor/mvc-rol-d-api
```

Abre el PR hacia `refactor/mvc-integration`.

### Paso 7: integración (responsabilidad del Rol D)

Este paso se hace cuando los 4 PR estén listos.

1. Verificar que `refactor/mvc-integration` exista y esté actualizada.

```bash
git switch refactor/mvc-integration
git pull
```

2. Revisar cada PR contra el contrato de `MIGRACION_MVC.md`.
3. Unir en orden **A, B, C, D**.
4. Ejecutar el build:

```bash
mvn -q -DskipTests package
```

5. Verificar que no queden paquetes viejos:

```bash
grep -REn "package com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
```

Ambos deben quedar sin resultados.

6. Verificar la estructura:

```bash
find src/main/java/com/lumina -maxdepth 3 -type d | sort
```

Debe mostrar `controller`, `dto/request`, `dto/response`, `exception`, `model`, `repository`, `service`, `util` y `config`.

7. Ejecutar el smoke test con H2:

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=h2 -Dspring-boot.run.arguments=--server.port=18080
```

8. Probar en orden:

- `POST /api/registro`
- `POST /api/productos` con `category` como texto
- `POST /api/pedidos`
- `PUT /api/pedidos/{id}/estado` con `{"status":"CONFIRMED"}`
- `POST /api/velas-personalizadas`
- `GET /api/productos?categoria=navidad`

9. Detener la aplicación y confirmar que el puerto `18080` quede libre.

10. Si todo pasa, fusionar `refactor/mvc-integration` a `main`.

### Criterio de terminado

- [ ] 4 controladores en `com.lumina.controller`.
- [ ] 3 DTOs de salida en `com.lumina.dto.response`.
- [ ] `README.md` muestra la estructura MVC.
- [ ] `MVP_IMPLEMENTACION.md` tiene la nota de estructura histórica.
- [ ] `MIGRACION_MVC.md` está actualizado con resultados.
- [ ] Los 4 roles están integrados.
- [ ] Build y smoke test pasan.
- [ ] `main` se actualiza solo al final.

---

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `cannot find symbol` con una clase que ya moviste | Falta el import nuevo en otro archivo | Agregar el import desde el paquete final. |
| `package X does not exist` | Se movió un archivo pero otro rol aún no | Es esperado en ramas parciales; se resuelve en integración. |
| `duplicate class` | Quedó una copia en el paquete viejo | Verificar con `git status` y borrar la copia sobrante. |
| El build falla solo en tu rama | La migración es atómica para el compilador | No compiles completo hasta integrar los 4 roles. |
| `OrderService` no encuentra `UserService` | Se dejó el import viejo o se agregó uno nuevo innecesario | Debe quedar sin import porque ambos están en `com.lumina.service`. |

## Regla final

Si un archivo no aparece en tu rol, no lo toques. Si crees que falta un cambio en otro rol, avisa al responsable de integración; no lo edites por tu cuenta.
