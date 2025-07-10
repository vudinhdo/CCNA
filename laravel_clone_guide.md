# 📥 Hướng dẫn chạy project Laravel khi clone từ Git (đã tích hợp Docker)

## 🔹 Bước 1: Clone source code từ Git

```bash
git clone https://github.com/ten-tai-khoan/project-laravel-docker.git
cd project-laravel-docker
```

## 🔹 Bước 2: Tạo file .env nếu chưa có

```bash
cp .env.example .env
```

## 🔹 Bước 3: Cấu hình file .env

Cập nhật các biến môi trường như:
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`

Sao cho **khớp với thông tin trong file `docker-compose.yml`**.

## 🔹 Bước 4: Khởi động Docker container

```bash
docker compose up -d --build
```

## 🔹 Bước 5: Cài đặt Composer trong container app

```bash
docker exec -it laravel-app composer install
```

## 🔹 Bước 6: Tạo key cho ứng dụng

```bash
docker exec -it laravel-app php artisan key:generate
```

## 🔹 Bước 7: Migrate database

```bash
docker exec -it laravel-app php artisan migrate
```

## 🔹 Bước 8: Gán quyền thư mục (nếu cần)

```bash
docker exec -it laravel-app chmod -R 775 storage bootstrap/cache
```

## 🔹 Bước 9: Truy cập ứng dụng

Mở trình duyệt và truy cập: [http://localhost:8000](http://localhost:8000)