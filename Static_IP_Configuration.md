# Hướng Dẫn Cấu Hình IP Tĩnh Trên Windows và Ubuntu

## 1. Cấu Hình IP Tĩnh Trên Windows

### Bước 1: Mở Network Connections
- Nhấn tổ hợp phím **Windows + R**, gõ `ncpa.cpl` và nhấn **Enter** để mở cửa sổ **Network Connections**.

### Bước 2: Chọn Kết Nối Mạng
- Nhấp chuột phải vào kết nối mạng bạn muốn cấu hình (Ethernet hoặc Wi-Fi), chọn **Properties**.

### Bước 3: Cấu Hình Giao Thức IPv4
- Trong cửa sổ Properties, chọn **Internet Protocol Version 4 (TCP/IPv4)** và nhấp vào **Properties**.
- Chọn **Use the following IP address** và nhập các thông tin sau:
  - **IP Address**: Ví dụ `192.168.1.100`
  - **Subnet Mask**: Ví dụ `255.255.255.0`
  - **Default Gateway**: Ví dụ `192.168.1.1`
- Chọn **Use the following DNS server addresses** và nhập:
  - **Preferred DNS Server**: Ví dụ `8.8.8.8` (Google DNS)
  - **Alternate DNS Server**: Ví dụ `8.8.4.4` (Google DNS)
- Nhấn **OK** để lưu.

### Bước 4: Kiểm Tra
- Mở Command Prompt (nhấn **Windows + R**, gõ `cmd`, nhấn **Enter**).
- Gõ `ipconfig` để kiểm tra địa chỉ IP đã được cấu hình đúng.

---

## 2. Cấu Hình IP Tĩnh Trên Ubuntu

### Bước 1: Xác Định Tên Giao Diện Mạng
- Mở terminal và gõ:
  ```bash
  ip link
  ```
- Ghi lại tên giao diện mạng (ví dụ: `eth0` cho Ethernet hoặc `wlan0` cho Wi-Fi).

### Bước 2: Chỉnh Sửa File Cấu Hình Netplan
- Mở file cấu hình Netplan (thường nằm trong `/etc/netplan/`):
  ```bash
  sudo nano /etc/netplan/01-netcfg.yaml
  ```
- Cập nhật nội dung file với thông tin IP tĩnh, ví dụ:
  ```yaml
  network:
    version: 2
    ethernets:
      eth0:
        addresses:
          - 192.168.1.100/24
        gateway4: 192.168.1.1
        nameservers:
          addresses:
            - 8.8.8.8
            - 8.8.4.4
  ```
  - **eth0**: Thay bằng tên giao diện mạng của bạn.
  - **192.168.1.100/24**: Địa chỉ IP và subnet mask.
  - **gateway4**: Địa chỉ gateway.
  - **nameservers**: Địa chỉ DNS.

- Lưu file bằng **Ctrl + O**, nhấn **Enter**, thoát bằng **Ctrl + X**.

### Bước 3: Áp Dụng Cấu Hình
- Chạy lệnh:
  ```bash
  sudo netplan apply
  ```

### Bước 4: Kiểm Tra
- Gõ lệnh:
  ```bash
  ip addr show eth0
  ```
  để kiểm tra địa chỉ IP đã được cấu hình đúng.
- Kiểm tra kết nối:
  ```bash
  ping 8.8.8.8
  ```

---

## Lưu Ý
- Thay đổi các địa chỉ IP, subnet mask, gateway, và DNS theo cấu hình mạng của bạn.
- Sao lưu file cấu hình trước khi chỉnh sửa để tránh lỗi.
- Nếu gặp sự cố, kiểm tra trạng thái dịch vụ mạng:
  - Windows: `netsh interface show interface`
  - Ubuntu: `systemctl status networking` hoặc `sudo netplan --debug apply`