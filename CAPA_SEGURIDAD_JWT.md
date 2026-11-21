# Capa de Seguridad y Autenticación (JWT) — Lumina Backend

Este documento describe **exclusivamente** la implementación de la nueva capa de seguridad con autenticación JWT. Es **independiente** de la migración a arquitectura por capas (ya completada y fusionada en `main`).

---

## 1. Objetivo

Implementar autenticación con JWT (tokens de acceso) y proteger los endpoints REST por rol, basándose en el proyecto demo del profesor (`proyecto-demo-JWT`, clase del 20/11/2026), adaptado a la arquitectura de Lumina.

---

## 2. Archivos creados

| Archivo | Responsabilidad |
|---|---|
| `security/JwtUtil.java` | Genera, valida y extrae datos del JWT (`jwt.secret`, `jwt.expiration`). |
| `security/JwtFilter.java` | Lee `Authorization: Bearer`, valida el token y autentica al usuario en el `SecurityContext`. |
| `security/SecurityConfig.java` | Cadena de filtros stateless, CSRF desactivado, CORS, reglas de acceso por URL y `@EnableMethodSecurity`. |
| `security/RestAuthenticationEntryPoint.java` | Devuelve 401 con cuerpo `ApiError` cuando falta/es inválido el token. |
| `security/RestAccessDeniedHandler.java` | Devuelve 403 con cuerpo `ApiError` cuando el rol no autoriza. |
| `service/UserDetailsServiceImpl.java` | Implementa `UserDetailsService` cargando el usuario por email y exponiendo autoridades (`ROLE_ADMIN`, `ROLE_CUSTOMER`, `ROLE_STAFF`). |
| `dto/response/AuthResponse.java` | Respuesta del login: `record AuthResponse(String token, UserResponse user)`. |

---

## 3. Archivos editados

| Archivo | Cambio |
|---|---|
| `pom.xml` | Agrega `spring-boot-starter-security` y jjwt `0.12.6` (`jjwt-api`, `jjwt-impl`, `jjwt-jackson`). |
| `application.properties` | Agrega `jwt.secret=${JWT_SECRET:lumina-dev-secret-key-change-me-min-32-chars}` y `jwt.expiration=3600000`. |
| `config/WebConfig.java` | Conserva solo `@Bean PasswordEncoder` (no declara otro en `SecurityConfig`). |
| `service/UserService.java` | `login()` valida credenciales con `passwordEncoder.matches`, genera el token y devuelve `AuthResponse`. |
| `controller/UserController.java` | `POST /api/login` retorna `AuthResponse`; importa `com.lumina.service.UserService`. |
| `controller/ProductController.java` | `@PreAuthorize("hasRole('ADMIN')")` en POST/PUT/DELETE. |
| `controller/OrderController.java` | `@PreAuthorize("hasAnyRole('ADMIN','STAFF')")` en cambio de estado. |
| `cors/CorsConfig.java` | Expone `CorsConfigurationSource` para que Spring Security respete los orígenes. |
| `config/DataInitializer.java` | Crea roles `ADMIN`, `CUSTOMER`, `STAFF` y un usuario `admin` de prueba si no existe. |

> ⚠️ `pom.xml` y `application.properties` estaban bajo la regla "no tocar" de la migración de capas; Rol E es la excepción documentada.

---

## 4. Reglas de autorización

| Endpoint | Acceso |
|---|---|
| `POST /api/registro`, `POST /api/login` | Público |
| `GET /api/productos/**` | Público |
| `POST /api/productos`, `PUT /api/productos/{id}`, `DELETE /api/productos/{id}` | `@PreAuthorize("hasRole('ADMIN')")` |
| `GET /api/usuarios`, `DELETE /api/usuarios/{id}` | `@PreAuthorize("hasRole('ADMIN')")` |
| `GET /api/usuarios/{id}`, `PUT /api/usuarios/{id}` | Autenticado |
| `POST /api/pedidos`, `GET /api/pedidos`, `GET /api/pedidos/{id}` | Autenticado |
| `PUT /api/pedidos/{id}/estado` | `@PreAuthorize("hasAnyRole('ADMIN','STAFF')")` |
| `POST /api/velas-personalizadas`, `GET /api/velas-personalizadas/**`, `DELETE /api/velas-personalizadas/{id}` | Autenticado |

### Reglas de URLs en `SecurityConfig`

```java
.requestMatchers("/api/registro", "/api/login").permitAll()
.requestMatchers(HttpMethod.GET, "/api/productos/**").permitAll()
.anyRequest().authenticated()
```

---

## 5. Flujo de autenticación

1. Cliente envía `POST /api/login` con `{ email, password }`.
2. `UserService.login` valida con `passwordEncoder.matches`; si falla lanza `UnauthorizedException` (401).
3. Si es válido, carga `UserDetails` vía `UserDetailsServiceImpl` y genera el JWT con `JwtUtil`.
4. Responde `200` con `AuthResponse { token, user: UserResponse }`.
5. En peticiones siguientes, el cliente envía `Authorization: Bearer <token>`.
6. `JwtFilter` extrae el username del token, carga el usuario y lo autentica en el `SecurityContext`.
7. `@PreAuthorize` valida el rol sobre cada endpoint protegido.

---

## 6. Checklist de implementación

- [ ] `com.lumina.security` con `JwtUtil`, `JwtFilter`, `SecurityConfig`, `RestAuthenticationEntryPoint`, `RestAccessDeniedHandler`.
- [ ] `service/UserDetailsServiceImpl` implementa `UserDetailsService` cargando por email.
- [ ] `dto/response/AuthResponse` con `token` y `user: UserResponse`.
- [ ] `WebConfig` conserva solo `@Bean PasswordEncoder`.
- [ ] `UserService.login()` valida con `passwordEncoder.matches` y devuelve `AuthResponse`.
- [ ] `UserController.login()` retorna `AuthResponse` e importa `com.lumina.service.UserService`.
- [ ] `UnauthorizedException` en `com.lumina.exception` mapeada a 401 en `GlobalExceptionHandler`.
- [ ] `DataInitializer` crea roles `ADMIN`, `CUSTOMER`, `STAFF` y un admin de prueba.
- [ ] `CorsConfig` expone `CorsConfigurationSource`; `SecurityConfig` usa `http.cors()`.
- [ ] `@PreAuthorize("hasRole('ADMIN')")` en escrituras de productos y usuarios.
- [ ] `@PreAuthorize("hasAnyRole('ADMIN','STAFF')")` en cambio de estado de pedidos.
- [ ] Rutas públicas sin token: `POST /api/registro`, `POST /api/login`, `GET /api/productos/**`.
- [ ] Resto de rutas `/api/**` requieren autenticación.
- [ ] `pom.xml` y `application.properties` actualizados (excepción documentada para Rol E).
- [ ] Sin imports de `com.lumina.usuario`, `com.lumina.common` en archivos de este rol.

---

## 7. Smoke test de aceptación (H2, puerto 18080)

1. `POST /api/registro` → `201`.
2. `POST /api/login` → `200` con `token` y `user`.
3. `GET /api/productos` sin token → `200`.
4. `POST /api/productos` sin token → `401`.
5. `POST /api/productos` con token `ADMIN` → `201`.
6. `POST /api/pedidos` con token `CUSTOMER` → `201`.
7. `PUT /api/pedidos/{id}/estado` con token `ADMIN/STAFF` → `200`.
8. Token inválido → `401`.
9. Preflight `OPTIONS` con `Origin` → cabeceras CORS presentes.

---

## 8. Datos de prueba

`DataInitializer` crea un usuario admin de prueba (`admin@lumina.com` / `Admin123`, BCrypt) si no existe.

Nota: `database/02_seed.sql` tiene hashes falsos (`demo-hash-*`) que no sirven para iniciar sesión.

---

## 9. Git y PR

Rama: `refactor/capa-seguridad` (desde `main`).

```bash
git switch main
git pull
git switch -c refactor/capa-seguridad
git push -u origin refactor/capa-seguridad
```

Al finalizar:

```bash
git add .
git commit -m "feat(rol-e): implementar autenticación JWT y proteger endpoints por rol"
git push origin refactor/capa-seguridad
```

Luego abrir PR hacia `main`.
