# Usar la imagen base de FrankenPHP
FROM dunglas/frankenphp

# Instalar extensiones necesarias de PHP (como pcntl)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    && docker-php-ext-install zip \
    && install-php-extensions pcntl bcmath intl

# Instalar Composer globalmente
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar el código de la aplicación Laravel al contenedor
COPY . /app

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar las dependencias de Laravel usando Composer
RUN composer install --no-dev --optimize-autoloader

# Crear el enlace simbólico para el almacenamiento
RUN php artisan storage:link

# Configurar permisos para el directorio de almacenamiento y caché
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Comando de inicio de Laravel Octane con FrankenPHP
ENTRYPOINT ["php", "artisan", "octane:frankenphp", "--workers=4"]
