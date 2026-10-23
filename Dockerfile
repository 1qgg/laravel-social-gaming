FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev libxml2-dev \
    libonig-dev libcurl4-openssl-dev \
    && docker-php-ext-install \
       pdo_mysql curl mbstring bcmath zip intl \
       opcache dom xml \
    && a2enmod rewrite headers \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && printf '<Directory /var/www/html>\n    AllowOverride All\n    Require all granted\n</Directory>\n' \
       > /etc/apache2/conf-available/app-directory.conf \
    && a2enconf app-directory \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install \
      --working-dir=/var/www/html/casino \
      --no-dev --optimize-autoloader --no-interaction \
    && mkdir -p \
       /var/www/html/casino/storage/app/public \
       /var/www/html/casino/storage/framework/cache/data \
       /var/www/html/casino/storage/framework/sessions \
       /var/www/html/casino/storage/framework/views \
       /var/www/html/casino/storage/logs \
       /var/www/html/casino/bootstrap/cache \
    && touch /var/www/html/casino/.env \
    && chown -R www-data:www-data \
       /var/www/html/casino/.env \
       /var/www/html/casino/storage \
       /var/www/html/casino/bootstrap/cache \
    && chmod 664 /var/www/html/casino/.env \
    && chmod -R ug+rwX \
       /var/www/html/casino/storage \
       /var/www/html/casino/bootstrap/cache

EXPOSE 80
