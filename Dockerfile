# Usar la imagen base de FrankenPHP
FROM dunglas/frankenphp

# Actualizar e instalar herramientas necesarias, además de Node.js 22
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    curl \
    gnupg \
    && docker-php-ext-install zip \
    && install-php-extensions pcntl bcmath intl \
    # Agregar el repositorio de NodeSource para Node.js 22
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Instalar Composer globalmente
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar el código de la aplicación Laravel al contenedor
COPY . /app

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar las dependencias de PHP usando Composer
RUN composer install --no-dev --optimize-autoloader

# Instalar las dependencias de JavaScript usando npm y construir los assets
RUN npm install && npm run build

# Crear el enlace simbólico para el almacenamiento
RUN php artisan storage:link

# Configurar permisos para el directorio de almacenamiento y caché
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Comando de inicio de Laravel Octane con FrankenPHP
ENTRYPOINT ["php", "artisan", "octane:frankenphp", "--workers=4"]
