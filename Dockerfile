# 多階段構建 - Stage 1: Composer 依賴安裝
FROM composer:2.7 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Stage 2: 最終運行階段
FROM php:8.4-fpm-alpine

# 安裝系統依賴
RUN apk add --no-cache \
    nginx \
    supervisor \
    postgresql-dev \
    mysql-client \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    zip \
    libzip-dev \
    oniguruma-dev \
    curl

# 安裝 PHP 擴展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    pdo_pgsql \
    gd \
    zip \
    mbstring \
    opcache

# 安裝 Redis 擴展
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# 設置工作目錄
WORKDIR /var/www/html

# 複製 Composer 依賴
COPY --from=composer /app/vendor ./vendor

# 複製應用程序代碼
COPY . .

# 複製 Composer 的 autoload 文件
COPY --from=composer /usr/bin/composer /usr/bin/composer

# 生成優化的 autoload
RUN composer dump-autoload --optimize --no-dev

# 設置權限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# 配置 PHP-FPM
RUN echo "pm.max_children = 50" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.start_servers = 10" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.min_spare_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_spare_servers = 20" >> /usr/local/etc/php-fpm.d/www.conf

# 配置 Nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf

# 配置 Supervisor
COPY docker/supervisord.conf /etc/supervisord.conf

# PHP 優化配置
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini

# 健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80

# 使用 Supervisor 啟動 Nginx + PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
