# Laravel Project Setup with Docker

## 1. 🌐 Các câu lệnh cần thiết khi chạy một project Laravel

### A. Khởi tạo project Laravel (nếu cần)
```bash
composer create-project laravel/laravel my-app
```

### B. Cài đặt các package cần thiết
```bash
composer install
npm install
```

### C. Tạo file `.env` và key cho ứng dụng
```bash
cp .env.example .env
php artisan key:generate
```

### D. Cấu hình quyền thư mục
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

### E. Migrate và seed database
```bash
php artisan migrate
php artisan db:seed
```

### F. Chạy server Laravel
```bash
php artisan serve
```

## 2. 📦 Dockerfile cho Laravel

```Dockerfile
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    nano

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . /var/www

RUN chown -R www-data:www-data /var/www

CMD ["php-fpm"]
```

## 3. 📄 docker-compose.yml cho Laravel

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laravel-app
    restart: unless-stopped
    volumes:
      - .:/var/www
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: laravel-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_ROOT_PASSWORD: secret
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

  nginx:
    image: nginx:alpine
    container_name: laravel-nginx
    ports:
      - "8000:80"
    volumes:
      - .:/var/www
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app

volumes:
  db_data:
```

## 4. ⚙️ nginx.conf

```nginx
server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    root /var/www/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

## 5. 🖥️ Script shell khởi chạy Laravel (.sh)

```bash
#!/bin/bash

if [ ! -f .env ]; then
    cp .env.example .env
fi

composer install
npm install
npm run build

chmod -R 775 storage bootstrap/cache

php artisan key:generate
php artisan migrate

php artisan serve --host=0.0.0.0 --port=8000
```