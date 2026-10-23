FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev \
    libxml2-dev libonig-dev \
    && docker-php-ext-install \
    pdo_mysql mbstring bcmath zip intl opcache \
    && a2enmod rewrite headers \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN if [ -f casino/composer.json ]; then \
      cd casino && \
      composer install --no-dev --optimize-autoloader --no-interaction; \
    fi

RUN if [ -d casino/storage ]; then \
      chown -R www-data:www-data casino/storage; \
    fi && \
    if [ -d casino/bootstrap/cache ]; then \
      chown -R www-data:www-data casino/bootstrap/cache; \
    fi

EXPOSE 80
