# Hướng Dẫn Cài Đặt GitLab Server Trên Ubuntu 24.04

## Yêu Cầu Hệ Thống
- **Hệ điều hành**: Ubuntu 24.04 LTS
- **Phần cứng tối thiểu**:
  - RAM: 4GB (khuyến nghị 8GB)
  - CPU: 2 cores (khuyến nghị 4 cores)
  - Dung lượng ổ cứng: 50GB trống
- **Quyền truy cập**: Người dùng với quyền `sudo`
- **Kết nối mạng**: Có thể truy cập Internet để tải gói cài đặt
- **Tên miền hoặc IP tĩnh**: Để truy cập GitLab (khuyến nghị cấu hình DNS)

## Bước 1: Cập Nhật Hệ Thống
- Mở terminal và cập nhật danh sách gói:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

## Bước 2: Cài Đặt Các Gói Phụ Thuộc
- Cài đặt các gói cần thiết cho GitLab:
  ```bash
  sudo apt install -y curl openssh-server ca-certificates postfix
  ```
- Trong quá trình cài đặt `postfix`, chọn **Internet Site** và nhập tên miền hoặc hostname của máy chủ (ví dụ: `gitlab.example.com`) để cấu hình email thông báo. Nếu không muốn dùng Postfix, bạn có thể bỏ qua và cấu hình SMTP sau.

## Bước 3: Thêm Kho GitLab
- Tải và chạy script để thêm kho GitLab CE:
  ```bash
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
  ```

## Bước 4: Cài Đặt GitLab CE
- Cài đặt gói GitLab CE và chỉ định URL truy cập:
  ```bash
  sudo EXTERNAL_URL="http://gitlab.example.com" apt install gitlab-ce
  ```
  - Thay `gitlab.example.com` bằng tên miền hoặc IP tĩnh của máy chủ.
  - Nếu muốn dùng HTTPS, đảm bảo có chứng chỉ SSL và thay `http` bằng `https`.

- Quá trình cài đặt sẽ tự động cấu hình GitLab. Sau khi hoàn tất, bạn sẽ thấy thông báo:
  ```
  Thank you for installing GitLab!
  ```

## Bước 5: Kiểm Tra Trạng Thái GitLab
- Kiểm tra trạng thái các dịch vụ GitLab:
  ```bash
  sudo gitlab-ctl status
  ```
  - Đảm bảo các dịch vụ như `nginx`, `postgresql`, `redis`, `puma`, `sidekiq` đang chạy (`run`).

## Bước 6: Truy Cập GitLab
- Mở trình duyệt và truy cập URL đã cấu hình (ví dụ: `http://gitlab.example.com`).
- Lần đầu truy cập, bạn sẽ được yêu cầu đặt mật khẩu mới cho tài khoản `root`.
- Đăng nhập với:
  - Tên người dùng: `root`
  - Mật khẩu: Mật khẩu vừa đặt

- Mật khẩu mặc định ban đầu (nếu cần) được lưu trong:
  ```bash
  sudo cat /etc/gitlab/initial_root_password
  ```
  - Lưu ý: Mật khẩu này chỉ có hiệu lực trong 24 giờ.

## Bước 7: Cấu Hình Cơ Bản
- **Cập nhật thông tin admin**:
  - Đăng nhập, vào **Profile Settings** (góc trên phải) > **Account**.
  - Đổi tên người dùng từ `root` thành tên khác (ví dụ: `admin`).
  - Cập nhật email và thông tin cá nhân.

- **Tắt đăng ký công khai** (nếu cần):
  - Vào **Admin Area** (biểu tượng cờ lê) > **Settings** > **General** > **Sign-up restrictions**.
  - Bỏ chọn **Sign-up enabled** và lưu thay đổi.

- **Cấu hình SSH Key**:
  - Tạo cặp khóa SSH trên máy local (nếu chưa có):
    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```
  - Copy khóa công khai (`~/.ssh/id_rsa.pub`) và thêm vào GitLab: **Profile Settings** > **SSH Keys** > **Add SSH Key**.

## Bước 8: Cấu Hình Tường Lửa
- Nếu sử dụng UFW, mở các cổng cần thiết:
  ```bash
  sudo ufw allow OpenSSH
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw enable
  ```

## Bước 9: Cấu Hình HTTPS (Tùy Chọn)
- Chỉnh sửa file cấu hình GitLab để kích hoạt Let’s Encrypt:
  ```bash
  sudo nano /etc/gitlab/gitlab.rb
  ```
  - Cập nhật:
    ```ruby
    external_url 'https://gitlab.example.com'
    letsencrypt['enable'] = true
    letsencrypt['contact_emails'] = ['your_email@example.com']
    ```
  - Lưu và chạy:
    ```bash
    sudo gitlab-ctl reconfigure
    ```

## Bước 10: Sao Lưu GitLab
- Tạo bản sao lưu:
  ```bash
  sudo gitlab-rake gitlab:backup:create
  ```
  - Bản sao lưu được lưu tại `/var/opt/gitlab/backups`.

- Tự động hóa sao lưu bằng cron:
  ```bash
  sudo crontab -e
  ```
  - Thêm dòng (sao lưu hàng ngày lúc 2:00 AM):
    ```
    0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create
    ```

## Kiểm Tra
- Tạo một dự án mới trong GitLab và thử clone/push bằng Git:
  ```bash
  git clone git@gitlab.example.com:username/project.git
  ```
- Kiểm tra email thông báo bằng cách mời người dùng mới.

## Lưu Ý
- Sao lưu thường xuyên để tránh mất dữ liệu.
- Cập nhật GitLab định kỳ:
  ```bash
  sudo apt update && sudo apt upgrade gitlab-ce
  ```
- Nếu gặp lỗi, kiểm tra log:
  ```bash
  sudo gitlab-ctl tail
  ```

## Nguồn Tham Khảo
- [GitLab Official Documentation](https://docs.gitlab.com/ee/install/)[](https://docs.gitlab.com/install/)
- [LinuxTechi: Install GitLab on Ubuntu 24.04](https://www.linuxtechi.com)[](https://www.linuxtechi.com/how-to-install-gitlab-on-ubuntu/)