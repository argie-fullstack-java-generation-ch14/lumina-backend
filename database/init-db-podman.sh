#!/bin/bash
# init-db-podman.sh — Inicializar base de datos MySQL de Lumina en Podman
# Archivo específico de Argie

set -e

CONTAINER_NAME="${MYSQL_CONTAINER:-bc-generation-col}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?define MYSQL_ROOT_PASSWORD}"
SQL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Lumina DB Init (Podman) ==="
echo "Contenedor: $CONTAINER_NAME"
echo "Scripts SQL: $SQL_DIR"

# 1. Verificar que el contenedor exista y esté corriendo
if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: El contenedor '$CONTAINER_NAME' no está corriendo."
  echo "Contenedores disponibles:"
  podman ps --format '{{.Names}}'
  exit 1
fi

# 2. Copiar scripts SQL al contenedor
echo "Copiando scripts SQL al contenedor..."
podman cp "$SQL_DIR/01_schema.sql" "$CONTAINER_NAME:/tmp/01_schema.sql"
podman cp "$SQL_DIR/02_seed.sql" "$CONTAINER_NAME:/tmp/02_seed.sql"

# 3. Ejecutar schema
echo "Ejecutando 01_schema.sql..."
podman exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" < "$SQL_DIR/01_schema.sql"

# 4. Ejecutar seed (22 productos del JSON front)
echo "Ejecutando 02_seed.sql..."
podman exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" < "$SQL_DIR/02_seed.sql"

# 5. Verificar
echo "Verificando datos cargados..."
podman exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "
  USE lumina;
  SELECT 'roles' AS tabla, COUNT(*) AS total FROM role
  UNION ALL SELECT 'usuarios', COUNT(*) FROM app_user
  UNION ALL SELECT 'productos', COUNT(*) FROM product;
"

echo "=== Base de datos lista ==="
echo "El usuario admin se crea automáticamente al arrancar el backend:"
echo "  email: admin@lumina.com"
echo "  password: Admin123 (hash BCrypt generado por DataInitializer)"
