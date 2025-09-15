FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies, PHP extensions, Node.js, npm, and Git in a single layer
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    gnupg \
    && docker-php-ext-install pdo pdo_mysql \
    && a2enmod rewrite \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v \
    && rm -rf /var/lib/apt/lists/*

# Copy only composer files first for caching
COPY composer.json composer.lock ./

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the rest of the application code
COPY . .

# Install PHP dependencies (artisan now exists)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Configure Git safe directory
RUN git config --global --add safe.directory /var/www/html

# Point Apache to public/
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Install Node dependencies and build assets
RUN npm install && npm run build

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage