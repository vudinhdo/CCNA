# Hướng dẫn cài đặt GitLab Server bằng Docker trên Ubuntu

Hướng dẫn này cài đặt **GitLab Server** trên **Ubuntu** sử dụng **Docker** với IP là `192.168.10.102` và domain là `gitlab.step.com`. Giả định bạn đã cài đặt **Docker** và **Docker Compose**.

## Chuẩn bị: Cài đặt Docker và Docker Compose

### 1. Cập nhật hệ thống
Cập nhật các gói phần mềm:

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Cài đặt Docker
Cài đặt Docker:

```bash
sudo apt install -y docker.io
```

### 3. Khởi động và kích hoạt Docker
Khởi động và bật Docker tự động khởi động cùng hệ thống:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### 4. Cài đặt Docker Compose (nhằm điều khiển Docker Compose để quản lý container)
Cài đặt Docker Compose:

```bash
sudo apt install -y docker-compose
```

### 5. Kiểm tra phiên bản Docker và Docker Compose
Kiểm tra phiên bản để xác nhận cài đặt thành công:

```bash
docker --version
docker-compose --version
```

## Các bước cài đặt và chạy GitLab

### 1. Tạo thư mục cho GitLab
Tạo thư mục để lưu cấu hình và dữ liệu GitLab:

```bash
mkdir -p ~/gitlab
cd ~/gitlab
```

### 2. Tạo file Docker Compose
Tạo file `docker-compose.yml`:

```bash
nano docker-compose.yml
```

Dán nội dung sau vào file:

```yaml
version: '3.6'
services:
  gitlab:
    image: 'gitlab/gitlab-ee:latest' # Hoặc 'gitlab/gitlab-ce:latest' nếu dùng Community Edition
    restart: always
    hostname: 'gitlab.step.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://192.168.10.102'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
    ports:
      - '80:80'   # HTTP
      - '443:443' # HTTPS
      - '2222:22' # SSH
    volumes:
      - './gitlab-config:/etc/gitlab'
      - './gitlab-logs:/var/log/gitlab'
      - './gitlab-data:/var/opt/gitlab'
    shm_size: '2gb'
```

**Lưu ý**: Lưu file: `Ctrl+O`, `Enter`, rồi thoát: `Ctrl+X`.

### 3. Khởi chạy GitLab
Trong thư mục chứa `docker-compose.yml`, chạy:

```bash
docker-compose up -d
```

Docker sẽ tải image GitLab và khởi động container. Quá trình này có thể mất vài phút.

### 4. Kiểm tra trạng thái
Đảm bảo container đang chạy:

```bash
docker ps
```

Truy cập GitLab qua trình duyệt tại `http://192.168.10.102`.

### 5. Lấy mật khẩu ban đầu
Lấy mật khẩu mặc định cho tài khoản `root`:

```bash
docker exec -it $(docker ps -qf "name=gitlab") cat /etc/gitlab/initial_root_password
```

Đăng nhập vào GitLab với:
- Tên người dùng: `root`
- Mật khẩu: Mật khẩu từ lệnh trên

### 6. Quản lý GitLab
- Dừng container:
  ```bash
  docker-compose down
  ```
- Cập nhật GitLab:
  ```bash
  docker-compose pull
  docker-compose up -d
  ```
- Xem log nếu có lỗi:
  ```bash
  docker logs $(docker ps -qf "name=gitlab")
  ```

## Lưu ý
- Đảm bảo máy chủ có ít nhất 4GB RAM (khuyến nghị 8GB) để GitLab chạy ổn định.
- Nếu muốn dùng domain `gitlab.step.com`, cần cấu hình DNS để trỏ tới `192.168.10.102`.
- Để kích hoạt HTTPS, thêm chứng chỉ SSL vào `docker-compose.yml` trong phần `GITLAB_OMNIBUS_CONFIG`.
- Sao lưu định kỳ thư mục `gitlab-data` để bảo vệ dữ liệu.
