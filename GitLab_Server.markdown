# Báo Cáo: Cài Đặt và Cấu Hình GitLab EE Phiên Bản 18.1.0-ee.0 Trên Ubuntu Noble (arm64)

## 1. Mục Tiêu
Cài đặt và cấu hình GitLab EE phiên bản 18.1.0-ee.0 trên hệ điều hành Ubuntu Noble (kiến trúc arm64) để thiết lập một hệ thống quản lý mã nguồn và CI/CD.

## 2. Yêu Cầu Hệ Thống
- **Hệ điều hành**: Ubuntu Noble (24.04 LTS) trên kiến trúc arm64.
- **Quyền truy cập**: Root hoặc sudo.
- **Kết nối mạng**: Internet ổn định để tải gói cài đặt.
- **Phần cứng tối thiểu (khuyến nghị bởi GitLab)**:
  - CPU: 4 nhân.
  - RAM: 8GB.
  - Dung lượng đĩa: 40GB trở lên.
- **Tên miền hoặc địa chỉ IP**: Để cấu hình truy cập GitLab.

## 3. Quy Trình Thực Hiện

### Bước 1: Tải và Cấu Hình Kho Lưu Trữ GitLab EE
- **Mục đích**: Thêm kho lưu trữ chính thức của GitLab để cài đặt gói GitLab EE.
- **Lệnh thực thi**:
  ```bash
  curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
  ```
- **Giải thích**:
  - Lệnh `curl` tải script cấu hình từ GitLab.
  - Script tự động thêm kho lưu trữ GitLab EE vào hệ thống và cập nhật danh sách gói.

### Bước 2: Cài Đặt Gói GitLab EE Phiên Bản 18.1.0-ee.0
- **Mục đích**: Cài đặt gói GitLab EE cụ thể (phiên bản 18.1.0-ee.0).
- **Lệnh thực thi**:
  ```bash
  sudo apt-get install gitlab-ee=18.1.0-ee.0
  ```
- **Giải thích**:
  - Lệnh `apt-get install` tải và cài đặt gói `gitlab-ee` với phiên bản được chỉ định.
  - Phiên bản cụ thể đảm bảo tính tương thích với yêu cầu dự án.

### Bước 3: Cấu Hình Host
- **Mục đích**: Đảm bảo máy chủ có tên miền hoặc địa chỉ IP phù hợp để truy cập GitLab.
- **Thực hiện**:
  1. Kiểm tra hoặc thiết lập tên miền (nếu có). Ví dụ: `gitlab.example.com`.
     - Nếu sử dụng địa chỉ IP cục bộ, ghi nhận IP của máy chủ (ví dụ: `192.168.1.100`).
  2. Cập nhật tệp `/etc/hosts` để ánh xạ tên miền cục bộ (nếu không có DNS):
     ```bash
     sudo nano /etc/hosts
     ```
     Thêm dòng:
     ```
     192.168.1.100 gitlab.example.com
     ```
  3. Kiểm tra kết nối:
     ```bash
     ping gitlab.example.com
     ```
- **Lưu ý**:
  - Nếu sử dụng tên miền công cộng, đảm bảo DNS đã được cấu hình trỏ đến IP máy chủ.
  - Mở các cổng cần thiết (80, 443) trên tường lửa:
    ```bash
    sudo ufw allow 80
    sudo ufw allow 443
    ```

### Bước 4: Cấu Hình Tệp `gitlab.rb`
- **Mục đích**: Tùy chỉnh các thiết lập GitLab như URL, email, và các dịch vụ khác.
- **Thực hiện**:
  1. Mở tệp cấu hình:
     ```bash
     sudo nano /etc/gitlab/gitlab.rb
     ```
  2. Cập nhật các thiết lập chính (ví dụ):
     ```ruby
     # Thiết lập URL truy cập GitLab
     external_url 'http://gitlab.example.com'

     # Cấu hình email (ví dụ: sử dụng SMTP của Gmail)
     gitlab_rails['smtp_enable'] = true
     gitlab_rails['smtp_address'] = "smtp.gmail.com"
     gitlab_rails['smtp_port'] = 587
     gitlab_rails['smtp_user_name'] = "your-email@gmail.com"
     gitlab_rails['smtp_password'] = "your-app-password"
     gitlab_rails['smtp_domain'] = "smtp.gmail.com"
     gitlab_rails['smtp_authentication'] = "login"
     gitlab_rails['smtp_enable_starttls_auto'] = true

     # (Tùy chọn) Tắt các dịch vụ không cần thiết để tối ưu hiệu suất
     nginx['enable'] = true
     prometheus['enable'] = false
     ```
  3. Lưu tệp và áp dụng cấu hình:
     ```bash
     sudo gitlab-ctl reconfigure
     ```
- **Giải thích**:
  - `external_url`: Định nghĩa URL mà người dùng sẽ sử dụng để truy cập GitLab.
  - Cấu hình SMTP: Cho phép GitLab gửi email thông báo (ví dụ: xác nhận tài khoản).
  - `gitlab-ctl reconfigure`: Tái cấu hình GitLab để áp dụng các thay đổi.

### Bước 5: Kiểm Tra và Vận Hành
- **Kiểm tra trạng thái dịch vụ**:
  ```bash
  sudo gitlab-ctl status
  ```
- **Truy cập GitLab**:
  - Mở trình duyệt và truy cập `http://gitlab.example.com` hoặc `http://<IP-máy-chủ>`.
  - Đăng nhập với tài khoản root (mật khẩu ban đầu được lưu tại `/etc/gitlab/initial_root_password`).
- **Khắc phục sự cố (nếu có)**:
  - Xem nhật ký: `sudo gitlab-ctl tail`.
  - Kiểm tra lỗi cấu hình: `/var/log/gitlab/`.

## 4. Tổng Hợp Thông Tin
- **Phiên bản GitLab**: GitLab EE 18.1.0-ee.0.
- **Hệ điều hành**: Ubuntu Noble (24.04 LTS, arm64).
- **URL truy cập**: `http://gitlab.example.com` (hoặc IP máy chủ).
- **Tài khoản mặc định**: Root, mật khẩu tại `/etc/gitlab/initial_root_password`.
- **Cấu hình chính**:
  - Tên miền: `gitlab.example.com` (hoặc IP tùy chỉnh).
  - Email: Đã cấu hình SMTP (ví dụ: Gmail).
  - Tối ưu hóa: Tắt một số dịch vụ không cần thiết (Prometheus).
- **Trạng thái**: Hệ thống đã cài đặt và sẵn sàng sử dụng.

## 5. Lưu Ý
- Sao lưu tệp cấu hình `/etc/gitlab/gitlab.rb` và dữ liệu GitLab định kỳ.
- Nếu sử dụng HTTPS, cần cài đặt chứng chỉ SSL (ví dụ: Let’s Encrypt) và cập nhật `external_url` thành `https://`.
- Đảm bảo bảo mật máy chủ bằng cách cập nhật hệ điều hành và GitLab thường xuyên:
  ```bash
  sudo apt-get update && sudo apt-get upgrade
  ```

## 6. Kết Luận
Quy trình cài đặt và cấu hình GitLab EE phiên bản 18.1.0-ee.0 đã hoàn tất. Hệ thống hiện sẵn sàng để sử dụng cho các dự án quản lý mã nguồn, CI/CD, và cộng tác nhóm. Các bước tiếp theo có thể bao gồm thiết lập người dùng, dự án, hoặc tích hợp với các công cụ DevOps khác.