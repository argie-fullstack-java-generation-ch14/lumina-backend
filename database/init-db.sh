#!/bin/bash
# Runs once, when the MySQL data volume is empty.
# Creates the database and loads seed data for Lumina Backend.
set -e

DATABASE="${DB_DATABASE:-lumina}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Aplicando schema y seed a '${DATABASE}'..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${DATABASE}" <<SQL
$(cat "${SCRIPT_DIR}/01_schema.sql")
$(cat "${SCRIPT_DIR}/02_seed.sql")
SQL

echo "==> Base de datos '${DATABASE}' inicializada."
