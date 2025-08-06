# Báo cáo: Tích hợp GitLab CI/CD với n8n để gửi thông báo Telegram

## Mục tiêu
Thiết lập một pipeline CI/CD trên GitLab-server (IP: 192.168.10.101) tích hợp với n8n-server (IP: 192.168.10.102) để gửi thông báo qua Telegram khi có dự án được đẩy lên GitLab.

## Yêu cầu
- **GitLab-server**: Đã cài đặt GitLab và GitLab Runner tại 192.168.10.101.
- **n8n-server**: Đã cài đặt n8n tại 192.168.10.102, truy cập qua `http://192.168.10.102:5678`.
- **Telegram Bot**: Có API Token và Chat ID của nhóm/người nhận.
- **Quyền truy cập**: Quyền admin trên GitLab và n8n.

## Các bước thực hiện

### 1. Tạo Telegram Bot và lấy thông tin
- **Tạo Bot**:
  - Sử dụng `@BotFather` trên Telegram, gửi lệnh `/newbot` để tạo bot (ví dụ: `@MyCICDBot`).
  - Lấy **API Token** (ví dụ: `123456:ABC-DEF1234ghIkl-xyz`).
- **Lấy Chat ID**:
  - Thêm bot vào group Telegram, gửi một tin nhắn.
  - Truy cập `https://api.telegram.org/bot<API-Token>/getUpdates` để lấy `chat.id` (ví dụ: `-766239967`).

### 2. Cấu hình Workflow trên n8n
- **Truy cập n8n**: Mở `http://192.168.10.102:5678`, đăng nhập, tạo workflow mới.
- **Tạo Workflow**:
  - **Webhook Node**:
    - **HTTP Method**: POST
    - **Path**: `gitlab-webhook`
    - **Webhook URL**: `http://192.168.10.102:5678/webhook/gitlab-webhook`
  - **Telegram Node**:
    - **Credentials**: Nhập API Token.
    - **Chat ID**: Nhập Chat ID.
    - **Message**:
      ```
      *New Push to GitLab Project*
      Project: {{ $node["Webhook"].json.project.name }}
      Branch: {{ $node["Webhook"].json.ref }}
      Commit: {{ $node["Webhook"].json.commits[0].message }}
      Author: {{ $node["Webhook"].json.user_name }}
      ```
  - Kết nối Webhook với Telegram Node, lưu và kích hoạt workflow.

### 3. Cấu hình GitLab CI/CD
- **Cài đặt GitLab Runner** (nếu chưa có):
  - Truy cập **Settings > CI/CD > Runners** trên GitLab, lấy **Registration Token**.
  - Cài đặt Runner trên 192.168.10.101:
    ```bash
    sudo curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
    sudo apt-get install gitlab-runner
    sudo gitlab-runner register \
      --url http://192.168.10.101 \
      --registration-token <your-token> \
      --executor docker \
      --docker-image docker:stable \
      --description "docker-runner"
    ```
- **Tạo file `.gitlab-ci.yml`**:
  ```yaml
  stages:
    - notify

  notify_telegram:
    stage: notify
    script:
      - |
        curl -X POST http://192.168.10.102:5678/webhook/gitlab-webhook \
        -H "Content-Type: application/json" \
        -d '{
          "project": {
            "name": "'"$CI_PROJECT_NAME"'",
            "url": "'"$CI_PROJECT_URL"'"
          },
          "ref": "'"$CI_COMMIT_REF_NAME"'",
          "user_name": "'"$CI_COMMIT_AUTHOR"'",
          "commits": [{
            "message": "'"$CI_COMMIT_MESSAGE"'",
            "id": "'"$CI_COMMIT_SHA"'"
          }]
        }'
    when: always
  ```
- **Webhook GitLab** (tùy chọn):
  - Vào **Settings > Webhooks**, thêm URL: `http://192.168.10.102:5678/webhook/gitlab-webhook`.
  - Chọn **Push events**, lưu.

### 4. Kiểm tra
- **Đẩy code**: Commit và push thay đổi lên repository GitLab.
- **Kiểm tra thông báo**: Mở Telegram, kiểm tra thông báo trong group/chat với bot.
- **Kết quả mong đợi**: Thông báo hiển thị tên dự án, branch, commit message, và tác giả.

## Lưu ý
- **Bảo mật**: Sử dụng HTTPS cho n8n và GitLab trong môi trường production. Lưu API Token và Chat ID trong biến môi trường (`N8N_ENCRYPTION_KEY` cho n8n, `CI/CD Variables` cho GitLab).
- **Mạng**: Đảm bảo GitLab-server (192.168.10.101) kết nối được với n8n-server (192.168.10.102) qua cổng 5678.
- **Debug**: Kiểm tra **Execution Log** trong n8n và log pipeline trong GitLab nếu không nhận được thông báo.

## Kết luận
Hệ thống tích hợp này cho phép tự động gửi thông báo Telegram khi có commit mới trên GitLab, sử dụng n8n làm cầu nối. Workflow có thể được tùy chỉnh thêm để mở rộng chức năng.

**Ngày lập báo cáo**: 06/08/2025