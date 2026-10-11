
FROM php:8.3-apache

# Extensión necesaria para conectar PHP con MySQL.
RUN set -eux; \
    docker-php-ext-install pdo_mysql; \
    for module in mpm_event mpm_worker mpm_prefork; do \
        a2dismod "$module" || true; \
    done; \
    rm -f /etc/apache2/mods-enabled/mpm_*.load \
          /etc/apache2/mods-enabled/mpm_*.conf; \
    a2enmod mpm_prefork rewrite headers setenvif

# Configuración del puerto de Railway.
RUN rm -f /etc/apache2/sites-enabled/000-default.conf \
    && sed -i 's/^Listen 80$//' /etc/apache2/ports.conf \
    && echo 'ServerName localhost' > /etc/apache2/conf-enabled/servername.conf

COPY docker/apache.conf /etc/apache2/sites-enabled/app.conf

# Verificar que Apache tenga una configuración válida durante el build.
RUN PORT=8080 apache2ctl -t \
    && apache2ctl -M 2>&1 | grep -E 'mpm_(event|worker|prefork)_module'

# Configuración de PHP para producción.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && { \
        echo 'date.timezone=America/Argentina/Buenos_Aires'; \
        echo 'expose_php=Off'; \
    } > "$PHP_INI_DIR/conf.d/app.ini"

ENV PORT=8080 \
    TZ=America/Argentina/Buenos_Aires

WORKDIR /var/www/html

COPY backend/ ./backend/
COPY frontend/ ./frontend/
COPY docker/ ./docker/

RUN echo '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=frontend/"><a href="frontend/">Ir a la aplicación</a>' > index.html \
    && sed -i 's/\r$//' docker/entrypoint.sh \
    && chmod +x docker/entrypoint.sh \
    && chown -R www-data:www-data /var/www/html

EXPOSE 8080

CMD ["/var/www/html/docker/entrypoint.sh"]
