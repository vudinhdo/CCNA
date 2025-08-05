# Hướng dẫn cài đặt GitLab Server bằng Docker trên Ubuntu

Dưới đây là hướng dẫn từng bước để cài đặt và chạy **GitLab Server** bằng **Docker** trên **Ubuntu**, dành cho trường hợp đã cài đặt **Docker** và **Docker Compose**.

## Các bước cài đặt và chạy GitLab

### 1. Tạo thư mục cho GitLab
Tạo một thư mục để lưu cấu hình và dữ liệu GitLab:

```bash
mkdir -p ~/gitlab
cd ~/gitlab
```

### 2. Tạo file Docker Compose
Tạo file `docker-compose.yml`:

```bash
nano docker-compose.yml
```

Dán nội dung sau vào file, thay `gitlab.example.com` bằng domain hoặc IP của máy chủ:

```yaml
version: '3.6'
services:
  gitlab:
    image: 'gitlab/gitlab-ee:latest' # Hoặc 'gitlab/gitlab-ce:latest' nếu dùng Community Edition
    restart: always
    hostname: 'gitlab.example.com' # Thay bằng domain hoặc IP
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.example.com' # Thay bằng domain hoặc IP
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

Lưu file: `Ctrl+O`, `Enter`, rồi thoát: `Ctrl+X`.

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

Truy main:~/gitlab$ docker-compose up -d
Starting gitlab_gitlab_1 ... done
main:~/gitlab$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                                                                 NAMES
4e6b7b8f9c2a   gitlab/gitlab-ee:latest   "/assets/wrapper"        2 minutes ago   Up 2 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp, 0.0.0.0:2222->22/tcp, :::2222->22/tcp   gitlab_gitlab_1
main:~/gitlab$ docker exec -it $(docker ps -qf "name=gitlab") cat /etc/gitlab/initial_root_password
# This file is generated during GitLab installation and contains the initial password for the root account.
# After logging in, please change this password immediately.

Password: 4e6b7b8f9c2a4e6b7b8f9c2a4e6b7b8f9c2a4e6b7b8f9c2a4e6b7b8f9c2a4e6b

# This password will be valid for 24 hours from the time GitLab was first started.
# If this password does not work, it may have been changed already or the 24 hour period may have expired.
main:~/gitlab$ 
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
- Nếu cần HTTPS hoặc SMTP, bạn có thể thêm cấu hình vào `GITLAB_OMNIBUS_CONFIG` trong `docker-compose.yml`.
- Sao lưu định kỳ thư mục `gitlab-data` để bảo vệ dữ liệu.
