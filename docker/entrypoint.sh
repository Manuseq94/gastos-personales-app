#!/bin/sh
set -eu

echo "[inicio] Preparacion de la base de datos..."

php /var/www/html/docker/init-db.php

echo "[inicio] Base de datos lista. Iniciando Apache..."

exec apache2-foreground