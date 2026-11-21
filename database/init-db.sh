#!/bin/bash
# Inicializa la base de datos de Lumina (schema + seed) en MySQL.
# Ejecutar una sola vez cuando el volumen de datos de MySQL esta vacio.
set -e

HOST="${DB_HOST:-localhost}"
PORT="${DB_PORT:-3306}"
ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-gencol123}"
DATABASE="${DB_DATABASE:-lumina}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Aplicando schema y seed a '${DATABASE}' en ${HOST}:${PORT}..."
mysql -h"${HOST}" -P"${PORT}" -uroot -p"${ROOT_PASSWORD}" "${DATABASE}" <<SQL
$(cat "${SCRIPT_DIR}/01_schema.sql")
$(cat "${SCRIPT_DIR}/02_seed.sql")
SQL

echo "==> Base de datos '${DATABASE}' inicializada."
