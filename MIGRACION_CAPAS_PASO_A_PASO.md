# Migración a Arquitectura por Capas - Paso a Paso Detallado por Rol

Este documento detalla, paso a paso y a profundidad, las actividades de cada uno de los roles definidos en `MIGRACION_CAPAS.md` para la migración del backend de Lumina hacia una arquitectura por capas (layered architecture).

## Tabla de roles

| Rol | Responsabilidad | Dificultad | Ir a la sección | Integrante |
|-----|-----------------|------------|-----------------|------------|
| [Rol A](#rol-a) | Modelo y utilidades | 2 de 5 | [Paso a paso](#rol-a) | Pedro |
| [Rol B](#rol-b) | Persistencia, excepciones y configuración | 3 de 5 | [Paso a paso](#rol-b) | Nicole |
| [Rol C](#rol-c) | Servicios y DTOs de entrada | 4 de 5 | [Paso a paso](#rol-c) | Argie |
| [Rol D](#rol-d) | Controladores y DTOs de salida | 3 de 5 | [Paso a paso](#rol-d) | Naya |
| [Rol E](#rol-e) | Seguridad y autenticación | 3 de 5 | [Paso a paso](#rol-e) | Por definir |

## Cómo usar este documento

1. Lee primero `MIGRACION_CAPAS.md`, secciones **Contrato de paquetes** y **Contrato interno de nombres y firmas**.
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

## Reglas generales (aplican a todos los roles)

- No renombrar clases, métodos, records, enums ni constructores.
- No cambiar firmas de métodos ni rutas REST.
- No cambiar lógica de negocio.
- No tocar `pom.xml`, `application.properties` ni `application-h2.properties`.
- Usar `git mv` para conservar historial.
- Actualizar primero el `package` y luego los imports.
- Cada integrante edita únicamente los archivos de su rol.
- No hacer reemplazo global de paquetes; cada clase tiene un destino distinto.
- Revisar imports contra el contrato de paquetes antes del PR.

## Flujo de dependencias entre capas

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

---

## Endpoints REST (contrato fijo)

La migración **no cambia rutas ni anotaciones Spring**. Los endpoints viven en los 4 controladores y el Rol D solo los mueve a `com.lumina.controller` conservando `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping` y `@DeleteMapping` tal cual. CORS aplica a `/api/**` (`CorsConfig`).

### Usuarios — `UserController` (`@RequestMapping("/api")`)

| Método | Ruta | Notas |
|---|---|---|
| POST | `/api/registro` | Crea cuenta con rol `CUSTOMER`. Responde `201`. Body: `RegisterRequest`. |
| POST | `/api/login` | Valida credenciales con `PasswordEncoder`. Body: `LoginRequest`. |
| GET | `/api/usuarios` | Lista `UserResponse`. |
| GET | `/api/usuarios/{id}` | Un `UserResponse` por id. |
| PUT | `/api/usuarios/{id}` | Actualiza nombre y teléfono. Body: `UpdateUserRequest`. |
| DELETE | `/api/usuarios/{id}` | Responde `204`. |

### Productos — `ProductController` (`@RequestMapping("/api/productos")`)

| Método | Ruta | Notas |
|---|---|---|
| GET | `/api/productos` | Filtros opcionales: `?categoria=navidad&disponibles=true`. |
| GET | `/api/productos/{id}` | Un producto por id. |
| GET | `/api/productos/slug/{slug}` | Un producto por slug. |
| POST | `/api/productos` | Responde `201`. Body: `ProductRequest` con `category` como texto. |
| PUT | `/api/productos/{id}` | Actualiza producto. Body: `ProductRequest`. |
| DELETE | `/api/productos/{id}` | Responde `204`. |

### Pedidos — `OrderController` (`@RequestMapping("/api/pedidos")`)

| Método | Ruta | Notas |
|---|---|---|
| POST | `/api/pedidos` | Responde `201`. Body: `OrderRequest`. Calcula totales y descuenta stock. |
| GET | `/api/pedidos` | Filtro opcional: `?usuarioId=2`. |
| GET | `/api/pedidos/{id}` | Un `OrderResponse` por id. |
| PUT | `/api/pedidos/{id}/estado` | Body: `OrderStatusRequest`, por ejemplo `{"status":"CONFIRMED"}`. |

### Velas personalizadas — `CustomCandleController` (`@RequestMapping("/api/velas-personalizadas")`)

| Método | Ruta | Notas |
|---|---|---|
| POST | `/api/velas-personalizadas` | Responde `201`. Body: `CustomCandleRequest`. |
| GET | `/api/velas-personalizadas` | Requiere `?usuarioId=`. |
| GET | `/api/velas-personalizadas/{id}` | Una vela personalizada por id. |
| DELETE | `/api/velas-personalizadas/{id}` | Responde `204`. |

**Total: 20 endpoints.** Esta lista debe coincidir con `README.md` (sección Endpoints) después de la migración; si algo difiere, es un error de integración.

---

## Orden recomendado de integración

Los PR se unen en este orden: **A → B → C → D → E**. Argie (Rol C) es responsable de unir los PR, validar la documentación, ejecutar el build, el smoke test y hacer el merge a `main`. El build completo se valida en la rama de integración, no en ramas parciales. `main` no recibe merges hasta que la integración compile y pase el smoke test.

---

<a id="rol-a"></a>

## Rol A: modelo y utilidades — Dificultad 2 de 5 — Pedro

**Objetivo:** mover las 7 entidades/enum a `com.lumina.model` y `SlugUtil` a `com.lumina.util`.

**Por qué es 2 de 5:** son 8 archivos, casi todos solo cambian de `package`. Solo algunos requieren borrar imports que quedan en el mismo paquete.

### Antes de empezar

```bash
git switch refactor/capa-integration
git pull
git switch -c refactor/capa-modelo
mkdir -p src/main/java/com/lumina/model src/main/java/com/lumina/util
git push -u origin refactor/capa-modelo
```

### Mapa de archivos (actual → nuevo)

| Archivo actual | Archivo nuevo | Paquete destino |
|----------------|---------------|-----------------|
| `com.lumina.usuario.AppUser` | `com.lumina.model.AppUser` | `com.lumina.model` |
| `com.lumina.usuario.Role` | `com.lumina.model.Role` | `com.lumina.model` |
| `com.lumina.producto.Product` | `com.lumina.model.Product` | `com.lumina.model` |
| `com.lumina.pedido.UserOrder` | `com.lumina.model.UserOrder` | `com.lumina.model` |
| `com.lumina.pedido.OrderItem` | `com.lumina.model.OrderItem` | `com.lumina.model` |
| `com.lumina.pedido.OrderStatus` | `com.lumina.model.OrderStatus` | `com.lumina.model` |
| `com.lumina.vela.CustomCandle` | `com.lumina.model.CustomCandle` | `com.lumina.model` |
| `com.lumina.*.SlugUtil` (si existe) | `com.lumina.util.SlugUtil` | `com.lumina.util` |

### Paso 1: Mover las entidades y el enum al paquete `model` ✅

Para cada una de las 7 entidades/enum:

1. Mover el archivo con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/AppUser.java \
  src/main/java/com/lumina/model/AppUser.java

git mv src/main/java/com/lumina/usuario/Role.java \
  src/main/java/com/lumina/model/Role.java

git mv src/main/java/com/lumina/producto/Product.java \
  src/main/java/com/lumina/model/Product.java

git mv src/main/java/com/lumina/pedido/UserOrder.java \
  src/main/java/com/lumina/model/UserOrder.java

git mv src/main/java/com/lumina/pedido/OrderItem.java \
  src/main/java/com/lumina/model/OrderItem.java

git mv src/main/java/com/lumina/pedido/OrderStatus.java \
  src/main/java/com/lumina/model/OrderStatus.java

git mv src/main/java/com/lumina/vela/CustomCandle.java \
  src/main/java/com/lumina/model/CustomCandle.java
```

2. Abrir cada archivo y actualizar la sentencia `package` a `com.lumina.model`.

3. Revisar los `import` de cada archivo. Quitar los imports de clases que ahora residen en el mismo paquete `com.lumina.model` (son redundantes). Por ejemplo, si `UserOrder` importaba `OrderItem` o `OrderStatus`, esos imports deben eliminarse porque ya están en el mismo paquete.

4. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido` ni `com.lumina.vela` dentro de los archivos de `model`.

### Paso 2: Crear/mover `SlugUtil` al paquete `util` ✅

1. Crear el directorio `src/main/java/com/lumina/util/`.
2. Mover `SlugUtil` con `git mv` (o crear el archivo si no existe en los paquetes viejos):

```bash
mkdir -p src/main/java/com/lumina/util
git mv <ruta-actual>/SlugUtil.java src/main/java/com/lumina/util/SlugUtil.java
```

3. Actualizar el `package` a `com.lumina.util`.
4. Revisar y corregir los imports de `SlugUtil` si hace referencia a clases de otros paquetes.

### Paso 3: Revisar imports intra-paquete ✅

En todos los archivos de `model` y `util`, eliminar imports que hagan referencia a clases del mismo paquete (ya no son necesarios en Java).

### Paso 4: Checklist del Rol A ✅

- [x] 7 entidades/enum en `com.lumina.model` con `package` actualizado. ✅
- [x] `SlugUtil` en `com.lumina.util`. ✅
- [x] Quitar imports de clases que ahora están en el mismo paquete `model`. ✅
- [x] Sin imports de `usuario`, `producto`, `pedido`, `vela` dentro de `model`/`util`. ✅

### Paso 5: Abrir el PR ✅

Hacer commit y push, luego abrir un Pull Request hacia `refactor/capa-integration`.

```bash
git add .
git commit -m "feat(rol-a): migrar entidades, enum y Slutil a capas model y util"
git push origin refactor/capa-modelo
```

### Paso 6: Hacer merge de la PR a la rama base ✅

Una vez aprobada la PR, unir la rama `refactor/capa-modelo` hacia `refactor/capa-integration`:

```bash
git switch refactor/capa-integration
git pull
git merge --no-ff refactor/capa-modelo
git push origin refactor/capa-integration
```

---

<a id="rol-b"></a>

## Rol B: persistencia, excepciones y configuración — Dificultad 3 de 5 — Nicole

**Objetivo:** mover 6 repositorios a `com.lumina.repository`, 5 excepciones + `GlobalExceptionHandler` a `com.lumina.exception`, crear `CorsConfig` en `com.lumina.cors` y ajustar `WebConfig` y `DataInitializer` en `com.lumina.config`.

**Por qué es 3 de 5:** son muchos archivos (13) con imports cruzados entre paquetes; requiere entender qué entidad importa cada repositorio y qué excepción usa cada servicio.

### Antes de empezar

```bash
git switch refactor/capa-integration
git pull
git switch -c refactor/capa-persistencia
git push -u origin refactor/capa-persistencia
```

### Mapa de archivos (actual → nuevo)

| Archivo actual | Archivo nuevo | Paquete destino |
|----------------|---------------|-----------------|
| `com.lumina.usuario.AppUserRepository` | `com.lumina.repository.AppUserRepository` | `com.lumina.repository` |
| `com.lumina.usuario.RoleRepository` | `com.lumina.repository.RoleRepository` | `com.lumina.repository` |
| `com.lumina.producto.ProductRepository` | `com.lumina.repository.ProductRepository` | `com.lumina.repository` |
| `com.lumina.pedido.UserOrderRepository` | `com.lumina.repository.UserOrderRepository` | `com.lumina.repository` |
| `com.lumina.pedido.OrderItemRepository` | `com.lumina.repository.OrderItemRepository` | `com.lumina.repository` |
| `com.lumina.vela.CustomCandleRepository` | `com.lumina.repository.CustomCandleRepository` | `com.lumina.repository` |
| `com.lumina.common.BadRequestException` | `com.lumina.exception.BadRequestException` | `com.lumina.exception` |
| `com.lumina.common.ConflictException` | `com.lumina.exception.ConflictException` | `com.lumina.exception` |
| `com.lumina.common.ResourceNotFoundException` | `com.lumina.exception.ResourceNotFoundException` | `com.lumina.exception` |
| `com.lumina.common.UnauthorizedException` | `com.lumina.exception.UnauthorizedException` | `com.lumina.exception` |
| `com.lumina.common.GlobalExceptionHandler` | `com.lumina.exception.GlobalExceptionHandler` | `com.lumina.exception` |
| `com.lumina.config.WebConfig` (CORS) | `com.lumina.cors.CorsConfig` | `com.lumina.cors` |
| `com.lumina.config.WebConfig` (PasswordEncoder) | `com.lumina.config.WebConfig` | `com.lumina.config` |
| `com.lumina.config.DataInitializer` | `com.lumina.config.DataInitializer` | `com.lumina.config` |

### Paso 1: Mover los repositorios al paquete `repository` ✅

1. Mover cada repositorio con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/AppUserRepository.java \
  src/main/java/com/lumina/repository/AppUserRepository.java

git mv src/main/java/com/lumina/usuario/RoleRepository.java \
  src/main/java/com/lumina/repository/RoleRepository.java

git mv src/main/java/com/lumina/producto/ProductRepository.java \
  src/main/java/com/lumina/repository/ProductRepository.java

git mv src/main/java/com/lumina/pedido/UserOrderRepository.java \
  src/main/java/com/lumina/repository/UserOrderRepository.java

git mv src/main/java/com/lumina/pedido/OrderItemRepository.java \
  src/main/java/com/lumina/repository/OrderItemRepository.java

git mv src/main/java/com/lumina/vela/CustomCandleRepository.java \
  src/main/java/com/lumina/repository/CustomCandleRepository.java
```

2. En cada archivo, actualizar el `package` a `com.lumina.repository`.
3. Actualizar el import de la entidad a `com.lumina.model.<Entidad>`.
4. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido` ni `com.lumina.vela`.

### Paso 2: Mover excepciones y `GlobalExceptionHandler` al paquete `exception` ✅

1. Mover cada excepción con `git mv`:

```bash
git mv src/main/java/com/lumina/common/BadRequestException.java \
  src/main/java/com/lumina/exception/BadRequestException.java

git mv src/main/java/com/lumina/common/ConflictException.java \
  src/main/java/com/lumina/exception/ConflictException.java

git mv src/main/java/com/lumina/common/ResourceNotFoundException.java \
  src/main/java/com/lumina/exception/ResourceNotFoundException.java

git mv src/main/java/com/lumina/common/UnauthorizedException.java \
  src/main/java/com/lumina/exception/UnauthorizedException.java

git mv src/main/java/com/lumina/common/GlobalExceptionHandler.java \
  src/main/java/com/lumina/exception/GlobalExceptionHandler.java
```

2. En cada archivo, actualizar el `package` a `com.lumina.exception`.
3. En `GlobalExceptionHandler.java`, agregar/actualizar el import:

```java
import com.lumina.dto.response.ApiError;
```

4. Verificar que no queden imports de `com.lumina.common`.

### Paso 3: Crear `CorsConfig` extrayendo CORS de `WebConfig` ✅

1. Crear el directorio `src/main/java/com/lumina/cors/`.
2. Crear `CorsConfig.java` en `com.lumina.cors` con la lógica CORS extraída de `WebConfig`.
3. En `WebConfig.java`, conservar solo el `@Bean PasswordEncoder` y eliminar la configuración CORS.
4. Verificar que `WebConfig` quede en `com.lumina.config` con solo el bean de `PasswordEncoder`.

### Paso 4: Actualizar `DataInitializer` ✅

1. Abrir `src/main/java/com/lumina/config/DataInitializer.java`.
2. Actualizar los imports a:

```java
import com.lumina.model.Role;
import com.lumina.repository.RoleRepository;
```

3. Eliminar cualquier import de `com.lumina.usuario` o `com.lumina.common`.

### Paso 5: Checklist del Rol B ✅

- [x] 6 repositorios en `com.lumina.repository` importando entidades de `com.lumina.model`. ✅
- [x] 5 excepciones + `GlobalExceptionHandler` en `com.lumina.exception`. ✅
- [x] `CorsConfig` creado en `com.lumina.cors` extrayendo CORS de `WebConfig`. ✅
- [x] `WebConfig` conserva solo `@Bean PasswordEncoder`. ✅
- [x] `DataInitializer` importa `com.lumina.model.Role` y `com.lumina.repository.RoleRepository`. ✅
- [x] Sin imports de `com.lumina.common` en archivos de este rol. ✅

### Paso 6: Abrir el PR ✅

```bash
git add .
git commit -m "feat(rol-b): migrar repositorios, excepciones, CORS y config a capas"
git push origin refactor/capa-persistencia
```

### Paso 7: Hacer merge de la PR a la rama base ✅

Una vez aprobada la PR, unir la rama `refactor/capa-persistencia` hacia `refactor/capa-integration`:

```bash
git switch refactor/capa-integration
git pull
git merge --no-ff refactor/capa-persistencia
git push origin refactor/capa-integration
```

---

<a id="rol-c"></a>

## Rol C: servicios y DTOs de entrada — Dificultad 4 de 5 — Argie

**Objetivo:** mover 4 servicios a `com.lumina.service` y 8 DTOs request a `com.lumina.dto.request`.

**Por qué es 4 de 5:** son 12 archivos con muchos imports cruzados hacia `model`, `repository`, `exception`, `dto.request`, `dto.response` y `util`; hay riesgo alto de dejar referencias viejas a paquetes antiguos.

### Antes de empezar

```bash
git switch refactor/capa-integration
git pull
git switch -c refactor/capa-servicios
git push -u origin refactor/capa-servicios
```

### Mapa de archivos (actual → nuevo)

| Archivo actual | Archivo nuevo | Paquete destino |
|----------------|---------------|-----------------|
| `com.lumina.usuario.UserService` | `com.lumina.service.UserService` | `com.lumina.service` |
| `com.lumina.producto.ProductService` | `com.lumina.service.ProductService` | `com.lumina.service` |
| `com.lumina.pedido.OrderService` | `com.lumina.service.OrderService` | `com.lumina.service` |
| `com.lumina.vela.CustomCandleService` | `com.lumina.service.CustomCandleService` | `com.lumina.service` |
| `com.lumina.usuario.LoginRequest` | `com.lumina.dto.request.LoginRequest` | `com.lumina.dto.request` |
| `com.lumina.usuario.RegisterRequest` | `com.lumina.dto.request.RegisterRequest` | `com.lumina.dto.request` |
| `com.lumina.usuario.UpdateUserRequest` | `com.lumina.dto.request.UpdateUserRequest` | `com.lumina.dto.request` |
| `com.lumina.producto.ProductRequest` | `com.lumina.dto.request.ProductRequest` | `com.lumina.dto.request` |
| `com.lumina.pedido.OrderRequest` | `com.lumina.dto.request.OrderRequest` | `com.lumina.dto.request` |
| `com.lumina.pedido.OrderItemRequest` | `com.lumina.dto.request.OrderItemRequest` | `com.lumina.dto.request` |
| `com.lumina.pedido.OrderStatusRequest` | `com.lumina.dto.request.OrderStatusRequest` | `com.lumina.dto.request` |
| `com.lumina.vela.CustomCandleRequest` | `com.lumina.dto.request.CustomCandleRequest` | `com.lumina.dto.request` |

### Paso 1: Mover los DTOs de entrada al paquete `dto/request` ✅

1. Crear el directorio `src/main/java/com/lumina/dto/request/`.
2. Mover cada DTO con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/LoginRequest.java \
  src/main/java/com/lumina/dto/request/LoginRequest.java

git mv src/main/java/com/lumina/usuario/RegisterRequest.java \
  src/main/java/com/lumina/dto/request/RegisterRequest.java

git mv src/main/java/com/lumina/usuario/UpdateUserRequest.java \
  src/main/java/com/lumina/dto/request/UpdateUserRequest.java

git mv src/main/java/com/lumina/producto/ProductRequest.java \
  src/main/java/com/lumina/dto/request/ProductRequest.java

git mv src/main/java/com/lumina/pedido/OrderRequest.java \
  src/main/java/com/lumina/dto/request/OrderRequest.java

git mv src/main/java/com/lumina/pedido/OrderItemRequest.java \
  src/main/java/com/lumina/dto/request/OrderItemRequest.java

git mv src/main/java/com/lumina/pedido/OrderStatusRequest.java \
  src/main/java/com/lumina/dto/request/OrderStatusRequest.java

git mv src/main/java/com/lumina/vela/CustomCandleRequest.java \
  src/main/java/com/lumina/dto/request/CustomCandleRequest.java
```

3. En cada archivo, actualizar el `package` a `com.lumina.dto.request`.
4. Revisar y corregir los imports que hagan referencia a `com.lumina.model` (entidades) si es necesario.
5. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido`, `com.lumina.vela` ni `com.lumina.common`.

### Paso 2: Mover los servicios al paquete `service` ✅

1. Mover cada servicio con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/UserService.java \
  src/main/java/com/lumina/service/UserService.java

git mv src/main/java/com/lumina/producto/ProductService.java \
  src/main/java/com/lumina/service/ProductService.java

git mv src/main/java/com/lumina/pedido/OrderService.java \
  src/main/java/com/lumina/service/OrderService.java

git mv src/main/java/com/lumina/vela/CustomCandleService.java \
  src/main/java/com/lumina/service/CustomCandleService.java
```

2. En cada archivo, actualizar el `package` a `com.lumina.service`.
3. Actualizar los imports a los nuevos paquetes:
   - `com.lumina.model.<Entidad>` para entidades.
   - `com.lumina.repository.<Repositorio>` para repositorios.
   - `com.lumina.exception.<Excepcion>` para excepciones.
   - `com.lumina.dto.request.*` para DTOs de entrada.
   - `com.lumina.dto.response.*` para DTOs de salida.
   - `com.lumina.util.SlugUtil` si se usa.
4. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido`, `com.lumina.vela` ni `com.lumina.common`.
5. Asegurar que el servicio no importe ni dependa de ningún controlador (dependencia hacia atrás prohibida).

### Paso 3: Checklist del Rol C ✅

- [x] 4 servicios en `com.lumina.service`. ✅
- [x] 8 DTOs request en `com.lumina.dto.request`. ✅
- [x] Imports corregidos a `model`, `repository`, `exception`, `dto.request`, `dto.response`, `util`. ✅
- [x] Sin imports de `usuario`, `producto`, `pedido`, `vela`, `common`. ✅

### Paso 4: Abrir el PR ✅

```bash
git add .
git commit -m "feat(rol-c): migrar servicios y DTOs de entrada a capas"
git push origin refactor/capa-servicios
```

### Paso 5: Hacer merge de la PR a la rama base ✅

Una vez aprobada la PR, unir la rama `refactor/capa-servicios` hacia `refactor/capa-integration`:

```bash
git switch refactor/capa-integration
git pull
git merge --no-ff refactor/capa-servicios
git push origin refactor/capa-integration
```

---

<a id="rol-d"></a>

## Rol D: controladores y DTOs de salida — Dificultad 3 de 5 — Naya

**Objetivo:** mover 4 controladores a `com.lumina.controller`, 3 DTOs response + `ApiError` a `com.lumina.dto.response`.

**Por qué es 3 de 5:** son 7 archivos con imports a `service`, `dto.request`, `dto.response` y `model`; es importante que el controlador no importe repositorios directamente ni haga lógica de negocio.

### Antes de empezar

```bash
git switch refactor/capa-integration
git pull
git switch -c refactor/capa-api
git push -u origin refactor/capa-api
```

### Mapa de archivos (actual → nuevo)

| Archivo actual | Archivo nuevo | Paquete destino |
|----------------|---------------|-----------------|
| `com.lumina.usuario.UserController` | `com.lumina.controller.UserController` | `com.lumina.controller` |
| `com.lumina.producto.ProductController` | `com.lumina.controller.ProductController` | `com.lumina.controller` |
| `com.lumina.pedido.OrderController` | `com.lumina.controller.OrderController` | `com.lumina.controller` |
| `com.lumina.vela.CustomCandleController` | `com.lumina.controller.CustomCandleController` | `com.lumina.controller` |
| `com.lumina.usuario.UserResponse` | `com.lumina.dto.response.UserResponse` | `com.lumina.dto.response` |
| `com.lumina.pedido.OrderResponse` | `com.lumina.dto.response.OrderResponse` | `com.lumina.dto.response` |
| `com.lumina.common.ApiError` | `com.lumina.dto.response.ApiError` | `com.lumina.dto.response` |

### Paso 1: Mover los DTOs de salida y `ApiError` al paquete `dto/response` ✅

1. Crear el directorio `src/main/java/com/lumina/dto/response/`.
2. Mover cada archivo con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/UserResponse.java \
  src/main/java/com/lumina/dto/response/UserResponse.java

git mv src/main/java/com/lumina/pedido/OrderResponse.java \
  src/main/java/com/lumina/dto/response/OrderResponse.java

git mv src/main/java/com/lumina/common/ApiError.java \
  src/main/java/com/lumina/dto/response/ApiError.java
```

3. En cada archivo, actualizar el `package` a `com.lumina.dto.response`.
4. Revisar y corregir los imports que hagan referencia a `com.lumina.model` si es necesario.
5. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido`, `com.lumina.vela` ni `com.lumina.common`.

### Paso 2: Mover los controladores al paquete `controller` ✅

1. Mover cada controlador con `git mv`:

```bash
git mv src/main/java/com/lumina/usuario/UserController.java \
  src/main/java/com/lumina/controller/UserController.java

git mv src/main/java/com/lumina/producto/ProductController.java \
  src/main/java/com/lumina/controller/ProductController.java

git mv src/main/java/com/lumina/pedido/OrderController.java \
  src/main/java/com/lumina/controller/OrderController.java

git mv src/main/java/com/lumina/vela/CustomCandleController.java \
  src/main/java/com/lumina/controller/CustomCandleController.java
```

2. En cada archivo, actualizar el `package` a `com.lumina.controller`.
3. Actualizar los imports a los nuevos paquetes:
   - `com.lumina.service.<Servicio>` para servicios.
   - `com.lumina.dto.request.*` para DTOs de entrada.
   - `com.lumina.dto.response.*` para DTOs de salida.
   - `com.lumina.model.*` para entidades si es necesario.
4. Verificar que no queden imports de `com.lumina.usuario`, `com.lumina.producto`, `com.lumina.pedido`, `com.lumina.vela` ni `com.lumina.common`.
5. Asegurar que el controlador solo dependa de `service` y `dto` (no importe repositorios directamente ni haga lógica de negocio).

### Paso 3: Checklist del Rol D ✅

- [x] 4 controladores en `com.lumina.controller`. ✅
- [x] 3 DTOs response + `ApiError` en `com.lumina.dto.response`. ✅
- [x] Imports corregidos a `service`, `dto.request`, `dto.response`, `model`. ✅

### Paso 4: Abrir el PR ✅

Hacer commit y push, luego abrir un Pull Request hacia `refactor/capa-integration`.

```bash
git add .
git commit -m "feat(rol-d): migrar controladores y DTOs de salida a capas"
git push origin refactor/capa-api
```

### Paso 5: Hacer merge de la PR a la rama base ✅

Una vez aprobada la PR, unir la rama `refactor/capa-api` hacia `refactor/capa-integration`:

```bash
git switch refactor/capa-integration
git pull
git merge --no-ff refactor/capa-api
git push origin refactor/capa-integration
```

---

<a id="rol-e"></a>

## Rol E: seguridad y autenticación — Dificultad 3 de 5 — Por definir

> **Nota (Rol E / autenticación de usuario):** se implementa autenticación con **JWT** basándose en la clase del **20/11/2026 (JWT auth)**, siguiendo el ejemplo del proyecto demo del profesor.

**Objetivo:** implementar seguridad con JWT (tokens de acceso) y proteger los endpoints REST por rol, siguiendo la arquitectura por capas.

**Por qué es 3 de 5:** agrega un nuevo paquete `security`, depende de librerías externas (jjwt, Spring Security) y requiere coordinar `WebConfig`, `UserService.login`, `UserController.login`, `DataInitializer` y los controladores.

### Antes de empezar

```bash
git switch refactor/capa-integration
git pull
git switch -c refactor/capa-seguridad
git push -u origin refactor/capa-seguridad
```

### Mapa de archivos (actual → nuevo)

| Archivo actual | Archivo nuevo | Paquete destino | Acción |
|----------------|---------------|-----------------|--------|
| `com.lumina.config.WebConfig` | `com.lumina.config.WebConfig` | `com.lumina.config` | Conservar solo `@Bean PasswordEncoder` |
| `com.lumina.usuario.UserService` | `com.lumina.service.UserService` | `com.lumina.service` | Ya movido por Rol C; `login()` devuelve `AuthResponse` |
| `com.lumina.usuario.UserController` | `com.lumina.controller.UserController` | `com.lumina.controller` | Ya movido por Rol D; `/api/login` retorna `AuthResponse` |
| `com.lumina.common.UnauthorizedException` | `com.lumina.exception.UnauthorizedException` | `com.lumina.exception` | Ya movido por Rol B |
| `com.lumina.config.DataInitializer` | `com.lumina.config.DataInitializer` | `com.lumina.config` | Ya movido por Rol B; crea admin de prueba |
| (nuevo) | `com.lumina.security.JwtUtil` | `com.lumina.security` | Crear |
| (nuevo) | `com.lumina.security.JwtFilter` | `com.lumina.security` | Crear |
| (nuevo) | `com.lumina.security.SecurityConfig` | `com.lumina.security` | Crear |
| (nuevo) | `com.lumina.security.RestAuthenticationEntryPoint` | `com.lumina.security` | Crear |
| (nuevo) | `com.lumina.security.RestAccessDeniedHandler` | `com.lumina.security` | Crear |
| (nuevo) | `com.lumina.service.UserDetailsServiceImpl` | `com.lumina.service` | Crear |
| (nuevo) | `com.lumina.dto.response.AuthResponse` | `com.lumina.dto.response` | Crear |

### Paso 1: Agregar dependencias y configuración

**Excepción a la regla "no tocar `pom.xml`/`application.properties`":** Rol E necesita librerías de seguridad.

1. `pom.xml`: agregar `spring-boot-starter-security` y jjwt `0.12.6` (`jjwt-api`, `jjwt-impl`, `jjwt-jackson`).
2. `application.properties`: agregar
   ```
   jwt.secret=${JWT_SECRET:lumina-dev-secret-key-change-me-min-32-chars}
   jwt.expiration=3600000
   ```

### Paso 2: Crear el paquete `com.lumina.security`

1. `security/JwtUtil.java`: `generateToken(UserDetails)`, `extractUsername`, `isTokenValid`.
2. `security/JwtFilter.java`: lee `Authorization: Bearer` y autentica en el `SecurityContext`.
3. `security/SecurityConfig.java`: stateless, `csrf.disable()`, `http.cors()`, `@EnableMethodSecurity`, `addFilterBefore`.
4. `security/RestAuthenticationEntryPoint.java`: 401 JSON con `ApiError`.
5. `security/RestAccessDeniedHandler.java`: 403 JSON con `ApiError`.
6. `service/UserDetailsServiceImpl.java`: implementa `UserDetailsService` por email; `.roles(role.getName())` → `ROLE_ADMIN/ROLE_CUSTOMER/ROLE_STAFF`.
7. `dto/response/AuthResponse.java`: `record AuthResponse(String token, UserResponse user)`.

### Paso 3: Configurar CORS para Spring Security

1. `cors/CorsConfig.java`: exponer un bean `CorsConfigurationSource` con los orígenes permitidos (el `WebMvcConfigurer` actual no lo usa la cadena de seguridad).
2. `SecurityConfig.java`: `.cors(Customizer.withDefaults())`.

### Paso 4: Implementar login con JWT

1. `service/UserService.java`: mantener `passwordEncoder.matches` + `UnauthorizedException`, cargar `UserDetails` y generar token; retornar `AuthResponse`.
2. `controller/UserController.java`: `POST /api/login` retorna `AuthResponse` e importa `com.lumina.service.UserService`.

### Paso 5: Proteger endpoints

| Endpoint | Acceso |
|---|---|
| `POST /api/registro`, `POST /api/login` | Público |
| `GET /api/productos/**` | Público |
| `POST/PUT/DELETE /api/productos/**` | `@PreAuthorize("hasRole('ADMIN')")` |
| `GET /api/usuarios`, `DELETE /api/usuarios/{id}` | `@PreAuthorize("hasRole('ADMIN')")` |
| `GET/PUT /api/usuarios/{id}` | Autenticado |
| `POST /api/pedidos`, `GET /api/pedidos/**` | Autenticado |
| `PUT /api/pedidos/{id}/estado` | `@PreAuthorize("hasAnyRole('ADMIN','STAFF')")` |
| `POST/GET/DELETE /api/velas-personalizadas/**` | Autenticado |

Regla de URLs en `SecurityConfig`:
```java
.requestMatchers("/api/registro", "/api/login").permitAll()
.requestMatchers(HttpMethod.GET, "/api/productos/**").permitAll()
.anyRequest().authenticated()
```

### Paso 6: Sembrar usuario admin de prueba

1. `config/DataInitializer.java`: crear `admin@lumina.com` / `Admin123` (BCrypt) con rol `ADMIN` si no existe.
2. Nota: `database/02_seed.sql` tiene hashes falsos (`demo-hash-*`) que no sirven para iniciar sesión.

### Paso 7: Checklist del Rol E

- [ ] Paquete `com.lumina.security` con `JwtUtil`, `JwtFilter`, `SecurityConfig`, `RestAuthenticationEntryPoint`, `RestAccessDeniedHandler`.
- [ ] `service/UserDetailsServiceImpl` implementa `UserDetailsService` cargando por email.
- [ ] `dto/response/AuthResponse` con `token` y `user: UserResponse`.
- [ ] `WebConfig` conserva solo `@Bean PasswordEncoder`.
- [ ] `UserService.login()` valida con `passwordEncoder.matches` y devuelve `AuthResponse`.
- [ ] `UserController.login()` retorna `AuthResponse` e importa `com.lumina.service.UserService`.
- [ ] `UnauthorizedException` en `com.lumina.exception` y mapeada a 401.
- [ ] `DataInitializer` crea roles `ADMIN`, `CUSTOMER`, `STAFF` y un admin de prueba.
- [ ] `CorsConfig` expone `CorsConfigurationSource` y `SecurityConfig` usa `http.cors()`.
- [ ] `@PreAuthorize("hasRole('ADMIN')")` en escrituras de productos y usuarios.
- [ ] `@PreAuthorize("hasAnyRole('ADMIN','STAFF')")` en cambio de estado de pedidos.
- [ ] Rutas públicas sin token: `POST /api/registro`, `POST /api/login`, `GET /api/productos/**`.
- [ ] Resto de rutas `/api/**` requieren autenticación.
- [ ] `pom.xml` y `application.properties` actualizados (excepción documentada para Rol E).
- [ ] Sin imports de `com.lumina.usuario`, `com.lumina.common` en archivos de este rol.

### Paso 8: Smoke test de seguridad

1. `POST /api/registro` → `201`.
2. `POST /api/login` → `200` con `token` y `user`.
3. `GET /api/productos` sin token → `200`.
4. `POST /api/productos` sin token → `401`.
5. `POST /api/productos` con token `ADMIN` → `201`.
6. `POST /api/pedidos` con token `CUSTOMER` → `201`.
7. `PUT /api/pedidos/{id}/estado` con token `ADMIN/STAFF` → `200`.
8. Token inválido → `401`.
9. Preflight `OPTIONS` con `Origin` → cabeceras CORS.

### Paso 9: Abrir el PR

```bash
git add .
git commit -m "feat(rol-e): implementar autenticación JWT y proteger endpoints por rol"
git push origin refactor/capa-seguridad
```

### Paso 10: Hacer merge de la PR a la rama base

```bash
git switch refactor/capa-integration
git pull
git merge --no-ff refactor/capa-seguridad
git push origin refactor/capa-integration
```

---

## Integración y validación (Argie)

**Responsable:** Argie (además del Rol C — Servicios y DTOs de entrada)  
**Cuándo:** Después de que los 5 PR (A, B, C, D, E) estén aprobados y mergeados en la rama base `refactor/capa-integration`.

> **Importante:** Cada integrante abre su PR hacia la rama base `refactor/capa-integration`, **no hacia `main`**. La integración y el merge a `main` son tareas exclusivas de esta etapa final, a cargo de Argie.

### Paso 1: Unir los PR en orden A → B → C → D → E ✅

1. Verificar que los PR de los roles A, B, C, D y E estén aprobados.
2. Mergear cada PR hacia `refactor/capa-integration` en el orden recomendado: **A, luego B, luego C, luego D, luego E**.
3. Hacer pull de la rama de integración:

```bash
git switch refactor/capa-integration
git pull
```
- [x] Paso 1 completado: PRs A→B→C→D unidos en `refactor/capa-integration`. ✅

### Paso 2: Ejecutar el build completo ✅

```bash
mvn -q -DskipTests package
```
- [x] Paso 2 completado: build completo verde. ✅

### Paso 3: Verificar que no queden paquetes viejos ✅

```bash
grep -REn "package com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
grep -REn "import com\.lumina\.(usuario|producto|pedido|vela|common)" src/main/java || true
```
- [x] Paso 3 completado: no quedan paquetes viejos. ✅

### Paso 4: Verificar la estructura de directorios ✅

```bash
find src/main/java/com/lumina -maxdepth 3 -type d | sort
```

Debe mostrar: `config`, `controller`, `dto`, `dto/request`, `dto/response`, `cors`, `exception`, `model`, `repository`, `service` (y opcionalmente `util`).
- [x] Paso 4 completado: estructura de directorios correcta. ✅

### Paso 5: Smoke test final (H2) ✅

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
- [x] Paso 5 completado: smoke test H2 aprobado. ✅

### Paso 6: Validar la documentación (`README.md`) ✅

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
- [x] Paso 6 completado: `README.md` validado contra la estructura final por capas. ✅

### Paso 7: Merge a `main`

Si el build y el smoke test pasan, fusionar `refactor/capa-integration` a `main`:

```bash
git switch main
git pull
git merge --no-ff refactor/capa-integration
git push origin main
```
- [ ] Paso 7: Mergear `refactor/capa-integration` a `main` (pendiente, acción manual).

### Paso 8: Limpieza — eliminar paquetes viejos ✅

Una vez que todos los paquetes estén vacíos, eliminar los paquetes antiguos:

- `usuario`
- `producto`
- `pedido`
- `vela`
- `common`
- [x] Paso 8 completado: paquetes viejos eliminados. ✅

### Checklist de Integración (Argie)

- [x] Unir PRs A→B→C→D en `refactor/capa-integration`. ✅
- [x] Ejecutar build completo (`mvn -q -DskipTests package`). ✅
- [x] Verificar que no queden paquetes viejos. ✅
- [x] Verificar estructura de directorios esperada. ✅
- [x] Ejecutar smoke test final (H2). ✅
- [x] Validar que `README.md` coincida con la estructura final por capas. ✅
- [ ] Mergear `refactor/capa-integration` a `main`.
- [x] Eliminar paquetes viejos una vez vacíos. ✅

---

## Rollback

- Antes del merge: cerrar PR y borrar rama.
- En integración: `git reset --hard <commit-base>`.
- Después del merge a `main`: `git revert <hash>` (no usar `reset --hard` sobre `main` compartido).
