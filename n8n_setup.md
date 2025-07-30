# Cài đặt Máy chủ Ảo Ubuntu chạy n8n

## 1. Cài đặt n8n bằng Docker

### Cài đặt Docker
Cập nhật hệ thống và cài các gói hỗ trợ:
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
```

Thêm khóa GPG chính thức của Docker:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Thêm repository Docker:
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Cập nhật lại danh sách gói và cài đặt Docker:
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

Kiểm tra phiên bản Docker:
```bash
sudo docker --version
```

Cho phép người dùng hiện tại chạy Docker mà không cần `sudo`:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Cài đặt Docker Compose
Tải phiên bản cụ thể của Docker Compose (ví dụ: 2.24.5):
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Kiểm tra file vừa tải:
```bash
ls -l /usr/local/bin/docker-compose
```

Cấp quyền thực thi:
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

Kiểm tra phiên bản Docker Compose:
```bash
docker-compose --version
```

### Tạo thư mục và file Cấu hình
```bash
mkdir n8n && cd n8n
nano .env
```

**File `.env`:**

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_password
WEBHOOK_URL=https://n8n.caothedo.com
TZ=Asia/Ho_Chi_Minh
```
### Cấu hình file yml  
```bash
nano docker-compose.yml
```
**File `docker-compose.yml`:**

```yaml
version: "3.7"

services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE
      - N8N_BASIC_AUTH_USER
      - N8N_BASIC_AUTH_PASSWORD
      - WEBHOOK_URL
      - TZ
    env_file:
      - .env
    volumes:
      - ./n8n_data:/home/node/.n8n
```

Chạy n8n:
```bash
docker compose up -d
```

---

## 2. Trỏ domain `n8n.caothedo.com`

### Nếu dùng nội mạng:
Sửa file `hosts` trên máy chính:

```txt
C:\Windows\System32\drivers\etc  
192.168.1.100   n8n.caothedo.com
```

### Nếu dùng domain thật:
Tạo bản ghi `A` trỏ `n8n` → IP public máy chủ

---

## 3. Cài NGINX + SSL

```bash
sudo apt install nginx
```

**File cấu hình nginx: `/etc/nginx/sites-available/n8n`**

```nginx
server {
    listen 80;
    server_name n8n.caothedo.com;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Cài SSL Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d n8n.caothedo.com
```

---

## 4. Truy cập thử

Mở trình duyệt: https://n8n.caothedo.com

---

## 5. Gợi ý kiểm tra lỗi

- `docker ps`: Kiểm tra container đang chạy
- `sudo systemctl status nginx`: Trạng thái NGINX
- `sudo lsof -i :5678`: Kiểm tra port n8n
- `ping n8n.caothedo.com`: Kiểm tra DNS
