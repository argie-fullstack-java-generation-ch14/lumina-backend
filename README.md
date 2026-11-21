# Lumina API

API REST de Lumina hecha con Spring Boot, Spring Data JPA y MySQL.

## Qué necesitas

- JDK 21
- MySQL 8 (corriendo en tu entorno local o en Docker/Podman)
- Maven (IntelliJ y VS Code con el Extension Pack for Java ya lo traen)

## Cómo ejecutarla

1. Define las variables de entorno en tu terminal antes de ejecutar el script de inicialización:
   ```
   export MYSQL_ROOT_PASSWORD=tu_password_root
   export DB_DATABASE=lumina
   ```
   Luego inicializa la base de datos MySQL con los scripts de la carpeta `database/`:
   ```
   ./database/init-db.sh
   ```
   Esto ejecuta `01_schema.sql` (crea las tablas) y `02_seed.sql` (datos de ejemplo).
   Asegúrate de que MySQL esté corriendo en `localhost:3306`.

2. Copia `.env.example` a `.env` y ajusta los valores (usuario, contraseña, base de datos).
   El archivo `.env` no se sube al repositorio (`gitignorado`).
   Ejemplo mínimo:
   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=tu_password
   DB_DATABASE=lumina
   MYSQL_ROOT_PASSWORD=tu_password_root
   ```

3. Desde esta carpeta (`lumina-backend/`):
   ```
   mvn spring-boot:run
   ```

   La API queda en `http://localhost:8080`.

## Estructura

El backend usa una arquitectura por capas:

```
com.lumina
├── LuminaApiApplication.java
├── config/        BCrypt y roles iniciales (DataInitializer, WebConfig)
├── controller/    Controladores REST
├── dto/
│   ├── request/   DTOs de entrada
│   └── response/  DTOs de salida (incluye ApiError)
├── cors/          Configuración CORS (CorsConfig)
├── exception/     Excepciones y GlobalExceptionHandler
├── model/         Entidades JPA y enum OrderStatus
├── repository/    Interfaces JpaRepository
├── service/       Lógica de negocio
└── util/          SlugUtil
```

Entidades del MVP: `role`, `app_user`, `product`, `user_order`, `order_item` y `custom_candle`.
No hay tablas para categorías, cupones, carrito, favoritos, contactos ni estados de pedido.

Flujo de dependencias: `controller → service → repository → model`. Los DTOs viven en `dto.request` y `dto.response`, y `exception` usa `dto.response.ApiError`.

## Endpoints

| Método | Ruta | Qué hace |
|---|---|---|
| POST | `/api/registro` | Crea una cuenta (rol CUSTOMER) |
| POST | `/api/login` | Revisa correo y contraseña |
| GET | `/api/usuarios` · `/api/usuarios/{id}` | Lista o consulta usuarios |
| PUT · DELETE | `/api/usuarios/{id}` | Edita nombre y teléfono, o elimina |
| GET | `/api/productos` | Lista. Filtros: `?categoria=navidad&disponibles=true` |
| GET | `/api/productos/{id}` · `/api/productos/slug/{slug}` | Un producto |
| POST · PUT · DELETE | `/api/productos` · `/api/productos/{id}` | Crea, edita, elimina |
| POST · GET · DELETE | `/api/velas-personalizadas` · `?usuarioId=` · `/{id}` | Velas de "Crea tu Lumina" |
| POST | `/api/pedidos` | Crea un pedido (calcula precios y baja el stock; sin cupones) |
| GET | `/api/pedidos` · `?usuarioId=2` · `/api/pedidos/{id}` | Lista o consulta pedidos |
| PUT | `/api/pedidos/{id}/estado` | Cambia el estado. Si pasa a `CANCELLED`, el stock vuelve |

Estados válidos de un pedido: `PENDING`, `CONFIRMED`, `PREPARING`, `COMPLETED` y `CANCELLED`.
Todo pedido nuevo empieza en `PENDING`.

## Ejemplos

Registro:

```json
POST /api/registro
{
  "fullName": "Laura Gómez",
  "phone": "300 123 4567",
  "email": "laura@correo.com",
  "password": "lumina2026"
}
```

Pedido:

```json
POST /api/pedidos
{
  "userId": 2,
  "items": [
    { "productId": 1, "quantity": 2 },
    { "productId": 4, "quantity": 1 }
  ]
}
```

Login:

```json
POST /api/login
{
  "email": "admin@lumina.com",
  "password": "Admin123"
}
```

Respuesta de login (ejemplo):

```json
{
  "token": "eyJhbG...",
  "user": {
    "id": 1,
    "fullName": "Administrador",
    "phone": "3000000000",
    "email": "admin@lumina.com",
    "role": "ADMIN",
    "createdAt": "2026-...-T..:..:.."
  }
}
```

Los errores siempre tienen esta forma:

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Revisa los datos enviados.",
  "details": ["email: Escribe un correo válido, por ejemplo nombre@correo.com."],
  "timestamp": "2026-11-14T16:30:00"
}
```

Códigos: `400` datos inválidos, `401` login incorrecto o token faltante/inválido, `403` rol no autorizado, `404` no existe, `409` ya existe o hay datos que dependen de él.

## Cosas a tener en cuenta

- Las contraseñas se guardan con BCrypt. Los usuarios de `02_seed.sql` tienen contraseñas de mentira
  (`demo-hash-...`), por eso no se puede iniciar sesión con ellos: crea una cuenta nueva con `/api/registro`.
- La autenticación se hace con JWT:
  - `POST /api/login` devuelve `{ token, user }`. Guarda el `token` y envíalo en las peticiones protegidas
    como cabecera `Authorization: Bearer <token>`.
  - Rutas públicas (sin token): `POST /api/registro`, `POST /api/login`, `GET /api/productos/**`.
  - Rutas protegidas (requieren token): el resto de `/api/**`.
  - Rutas de administración (`POST/PUT/DELETE /api/productos`, `GET/DELETE /api/usuarios`,
    `PUT /api/pedidos/{id}/estado`) requieren rol `ADMIN` o `ADMIN/STAFF` según corresponda.
- El usuario admin de prueba se crea al iniciar la app (`admin@lumina.com` / `Admin123`, BCrypt)
  si no existe en la base de datos.
- CORS permite `localhost:3000`, `localhost:5500` y `127.0.0.1:5500` (dev) y la página de GitHub Pages del equipo.
  Si el frontend corre en otro puerto, se agrega en `cors/CorsConfig.java`.

**En Postman:** después de hacer `POST /api/login`, copia el valor del `token` y úsalo en la pestaña
`Authorization` → `Type: Bearer Token` → `Token: <tu_token>` para las peticiones protegidas.
