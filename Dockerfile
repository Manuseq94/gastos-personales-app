
FROM php:8.3-cli

RUN docker-php-ext-install pdo_mysql

ENV PORT=8080
ENV TZ=America/Argentina/Buenos_Aires

WORKDIR /var/www/html

COPY backend/ ./backend/
COPY frontend/ ./frontend/
COPY docker/ ./docker/

RUN echo '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=frontend/"><a href="frontend/">Ir a la aplicación</a>' > index.html \
    && sed -i 's/\r$//' docker/entrypoint.sh \
    && chmod +x docker/entrypoint.sh

EXPOSE 8080

CMD ["/var/www/html/docker/entrypoint.sh"]
