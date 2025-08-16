# Hướng Dẫn Cài Đặt n8n với Docker trên Ubuntu

Hướng dẫn chi tiết từng bước để cài đặt và chạy n8n trên máy chủ ảo Ubuntu sử dụng Docker, với IP tĩnh là `192.168.1.11` và tên miền `n8n.ctd.com`. Giả định bạn đã cài đặt Hyper-V và máy ảo Ubuntu (phiên bản 20.04 hoặc 22.04) với quyền root hoặc sudo.

## Yêu cầu
- Máy ảo Ubuntu với IP tĩnh `192.168.1.11`.
- Quyền truy cập root hoặc sudo.
- Tên miền `n8n.ctd.com` đã được trỏ về IP `192.168.1.11` (thông qua DNS hoặc file `/etc/hosts` nếu thử nghiệm cục bộ).
- Kết nối Internet để tải Docker và image n8n.

## Các bước thực hiện

### Bước 1: Cập nhật hệ thống và cài đặt Docker
1. **Đăng nhập vào máy ảo Ubuntu**:
```bash
ssh username@192.168.1.11
```
Thay username bằng tài khoản của bạn.

2. **Cập nhật hệ thống**:
```bash
sudo apt update && sudo apt upgrade -y
```
3. **Cài đặt Docker**:
```bash
sudo apt install -y docker.io
```
4. **Khởi động và kích hoạt Docker**:
```bash
sudo systemctl start docker
sudo systemctl enable docker
```
5. **Cài đặt Docker Compose (n8n yêu cầu Docker Compose để quản lý container)**:
```bash
sudo apt install -y docker-compose
```
6. **Kiểm tra phiên bản Docker và Docker Compose**:
```bash
docker --version
docker-compose --version
```

### Bước 2: Cấu hình DNS hoặc file hosts
Để truy cập n8n qua tên miền `n8n.ctd.com`, bạn cần đảm bảo tên miền trỏ đúng về IP `192.168.1.11`.

Nếu bạn có quyền quản lý DNS:

Vào giao diện quản lý DNS của nhà cung cấp tên miền (ví dụ: GoDaddy, Namecheap).
```Thêm bản ghi A:
textTên: n8n
Loại: A
Giá trị: 192.168.1.11
TTL: 3600 (hoặc mặc định)
```
Chờ DNS cập nhật (thường mất vài phút đến vài giờ).


Nếu thử nghiệm cục bộ (trên máy tính hoặc máy chủ):

**Chỉnh sửa file /etc/hosts trên máy tính hoặc máy chủ**:
```bash
sudo nano /etc/hosts
```
Thêm dòng:
```bash
192.168.1.11 n8n.ctd.com
```

Lưu và thoát (Ctrl+O, Enter, Ctrl+X).

**Kiểm tra DNS**:
```bash
ping n8n.ctd.com
```
Nếu phản hồi từ 192.168.1.11, DNS đã được cấu hình đúng.

### Bước 3: Tạo cấu hình Docker Compose cho n8n


**Tạo thư mục cho n8n**:
```bash
mkdir ~/n8n && cd ~/n8n
```

**Tạo file docker-compose.yml**:
```bash
nano docker-compose.yml
```

**Dán nội dung sau vào file**:
```yamlversion: "3.8"
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=n8n.ctd.com
      - N8N_PROTOCOL=http
      - N8N_PORT=5678
      - WEBHOOK_URL=http://n8n.ctd.com/
      - N8N_SECURE_COOKIE=false
    volumes:
      - n8n_data:/home/node/.n8n
volumes:
  n8n_data:
```
**Giải thích**:
`
image: Sử dụng image n8n chính thức.
ports: Ánh xạ cổng 5678 (mặc định của n8n) từ container ra host.
environment: Cấu hình tên miền và giao thức HTTP (vì bỏ SSL).
volumes: Lưu trữ dữ liệu n8n để không bị mất khi container khởi động lại.
`


Lưu và thoát (Ctrl+O, Enter, Ctrl+X).


### Bước 4: Cài đặt Nginx làm Reverse Proxy
Để sử dụng tên miền n8n.ctd.com, bạn cần cài đặt Nginx làm reverse proxy.

**Cài đặt Nginx**:
```bash
cd ..
sudo apt install -y nginx
```

**Khởi động và kích hoạt Nginx**:
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```
**Tạo file cấu hình Nginx cho n8n**:
```bash
sudo nano /etc/nginx/sites-available/n8n
```
**Dán nội dung sau**:
```
server {
    listen 80;
    server_name n8n.ctd.com;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
**Kích hoạt cấu hình**:
```bash
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
```
**Kiểm tra cấu hình Nginx**:
```bash
sudo nginx -t
```
**Khởi động lại Nginx**:
```bash
sudo systemctl reload nginx
```

### Bước 5: Khởi chạy n8n

**Chạy Docker Compose**:
```bash
cd ~/n8n
sudo docker-compose up -d
```
**Kiểm tra trạng thái container**:
```bash
docker ps
```
Bạn sẽ thấy container n8n đang chạy.
**Kiểm tra log**:
```bash
docker logs n8n
```

### Bước 6: Truy cập n8n

**Mở trình duyệt và truy cập**:
```text
http://n8n.ctd.com
```
Đăng ký tài khoản n8n (lần đầu truy cập sẽ yêu cầu tạo tài khoản admin).

### Bước 7: Cấu hình tường lửa (nếu cần)
Nếu bạn bật UFW (Uncomplicated Firewall):

**Cho phép các cổng cần thiết**:
```bash
sudo ufw allow 80
sudo ufw allow ssh
```
**Kích hoạt UFW**:
```bash
sudo ufw enable
```

### Bước 8: Bảo trì và quản lý

**Dừng n8n**:
```bash
cd ~/n8n
sudo docker-compose down
```
**Cập nhật n8n**:
```bash
cd ~/n8n
sudo docker-compose pull
sudo docker-compose up -d
```
**Sao lưu dữ liệu**:
Dữ liệu n8n được lưu trong volume n8n_data. Sao lưu thư mục:
```bash
sudo tar -czvf n8n_backup.tar.gz ~/.n8n
```

### Khắc phục sự cố

Không truy cập được `n8n.ctd.com`:

Kiểm tra DNS bằng `ping n8n.ctd.com`.
Kiểm tra trạng thái Nginx: `sudo systemctl status nginx`.
Kiểm tra log Docker: `docker logs n8n`.


Cổng 5678 không hoạt động:

Kiểm tra container: docker ps.
Đảm bảo cổng 5678 không bị chặn: sudo netstat -tuln | grep 5678.
