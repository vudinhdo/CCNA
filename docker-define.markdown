# Hướng dẫn cơ bản về Docker và các thành phần

## 1. Docker là gì?
Docker là một nền tảng mã nguồn mở dùng để container hóa ứng dụng, cho phép đóng gói ứng dụng cùng các phụ thuộc vào một container. Container giúp ứng dụng chạy đồng nhất trên các môi trường khác nhau (máy tính cá nhân, server, cloud).

## 2. Các thành phần chính của Docker

### 2.1. Image
- **Định nghĩa**: Một bản mẫu chỉ đọc (read-only) chứa ứng dụng, thư viện, phụ thuộc, và cấu hình cần thiết để chạy ứng dụng. Image là "bản thiết kế" cho container.
- **Ví dụ**: Image `nginx:latest` chứa web server Nginx.
- **Cách sử dụng**: Tạo từ `Dockerfile` bằng lệnh `docker build`.

### 2.2. Container
- **Định nghĩa**: Một phiên bản chạy được của một image, là môi trường độc lập, nhẹ, chứa mọi thứ cần thiết để chạy ứng dụng.
- **Ví dụ**: `docker run nginx:latest` tạo một container từ image `nginx:latest`.
- **Đặc điểm**: Có thể chạy, dừng, xóa, không ảnh hưởng đến image gốc.

### 2.3. Volume
- **Định nghĩa**: Cơ chế lưu trữ dữ liệu bền vững, cho phép dữ liệu tồn tại độc lập với container. Dùng để chia sẻ hoặc lưu trữ dữ liệu lâu dài.
- **Ví dụ**: Lưu trữ dữ liệu database để không bị mất khi container bị xóa.
- **Loại**:
  - **Bind Mount**: Gắn thư mục từ máy chủ vào container.
  - **Docker Managed Volume**: Volume do Docker quản lý.

### 2.4. Dockerfile
- **Định nghĩa**: File văn bản chứa các lệnh để xây dựng image Docker, mô tả cách cài đặt và cấu hình ứng dụng.
- **Ví dụ**: 
  ```dockerfile
  FROM ubuntu:20.04
  RUN apt-get update
  COPY . /app
  ```

### 2.5. Docker Registry
- **Định nghĩa**: Nơi lưu trữ và phân phối image Docker, có thể là công khai (Docker Hub) hoặc riêng tư.
- **Ví dụ**: Docker Hub lưu trữ image như `mysql`, `python`.

### 2.6. Docker Compose
- **Định nghĩa**: Công cụ để định nghĩa và chạy nhiều container thông qua file YAML (`docker-compose.yml`).
- **Ví dụ**: File `docker-compose.yml` định nghĩa ứng dụng web và database.

### 2.7. Network
- **Định nghĩa**: Cho phép các container giao tiếp với nhau hoặc với bên ngoài. Có các loại như bridge, host, overlay.
- **Ví dụ**: Container web server giao tiếp với container database.

### 2.8. Docker Daemon
- **Định nghĩa**: Tiến trình nền quản lý container, image, volume, và network.
- **Cách tương tác**: Dùng lệnh `docker` để gửi yêu cầu.

### 2.9. Docker Client
- **Định nghĩa**: Công cụ dòng lệnh (`docker`) hoặc giao diện đồ họa để tương tác với Docker Daemon.
- **Ví dụ lệnh**: `docker pull`, `docker run`, `docker ps`.

## 3. Tài liệu tham khảo
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose Overview](https://docs.docker.com/compose/)