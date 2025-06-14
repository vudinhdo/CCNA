# Cài đặt Máy chủ Ảo Ubuntu chạy n8n và SSH từ máy chính

## ✅ 1. Tạo máy ảo Ubuntu trên Hyper-V

### Bước 1: Tải ISO Ubuntu
- Truy cập: [https://ubuntu.com/download/server](https://ubuntu.com/download/server)
- Tải bản Ubuntu Server (VD: 22.04 LTS)

### Bước 2: Tạo External Switch
- Mở **Hyper-V Manager** → `Virtual Switch Manager`
- Tạo **External Switch** kết nối với card mạng thật
- Đặt tên ví dụ: `ExternalNetwork`

### Bước 3: Tạo máy ảo mới
- RAM: 2–4 GB
- CPU: 2 core
- HDD: 20–30 GB
- Mạng: dùng External Switch đã tạo

### Bước 4: Cài đặt Ubuntu Server
- Hostname: `n8n-server`
- Chọn `OpenSSH Server`
- Thiết lập user (VD: `caothedo`)

---

## ✅ 2. Cấu hình IP tĩnh

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Ví dụ cấu hình:

```yaml
network:
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
  version: 2
```

```bash
sudo netplan apply
```

---

## ✅ 3. SSH từ máy chính vào máy ảo

```bash
ssh caothedo@192.168.1.100
```

---

## ✅ 4. Cài đặt n8n bằng Docker

```bash
sudo apt update
sudo apt install -y curl gnupg2 ca-certificates apt-transport-https software-properties-common
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

### Tạo thư mục và file cấu hình

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

```bash
docker compose up -d
```

---

## ✅ 5. Trỏ domain `n8n.caothedo.com`

### Nếu dùng nội mạng:
Sửa file `hosts` trên máy chính:

```txt
192.168.1.100   n8n.caothedo.com
```

### Nếu dùng domain thật:
Tạo bản ghi `A` trỏ `n8n` → IP public máy chủ

---

## ✅ 6. Cài NGINX + SSL

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

## ✅ 7. Truy cập thử

Mở trình duyệt: https://n8n.caothedo.com

---

## ✅ Gợi ý kiểm tra lỗi

- `docker ps`: Kiểm tra container đang chạy
- `sudo systemctl status nginx`: Trạng thái NGINX
- `sudo lsof -i :5678`: Kiểm tra port n8n
- `ping n8n.caothedo.com`: Kiểm tra DNS