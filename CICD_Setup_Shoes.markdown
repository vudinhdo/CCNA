# Báo cáo: Thiết lập CI/CD cho dự án "shoes" trên GitLab Server

## 1. Giới thiệu
Báo cáo này trình bày quy trình thiết lập hệ thống CI/CD (Continuous Integration/Continuous Deployment) cho dự án `shoes` trên GitLab Server tại địa chỉ `http://caothedo.gitlab.com`. Dự án `shoes` là một ứng dụng Node.js đơn giản sử dụng Express framework, với mục tiêu tự động hóa quá trình build và test mã nguồn thông qua pipeline CI/CD. Quy trình bao gồm thiết lập dự án, cấu hình GitLab Runner, và tạo pipeline CI/CD để đảm bảo chất lượng mã nguồn.

## 2. Mục tiêu
- Thiết lập một pipeline CI/CD tự động để build và test dự án `shoes`.
- Tích hợp GitLab Server với GitLab Runner để thực thi các job CI/CD.
- Đảm bảo mã nguồn được kiểm tra liên tục mỗi khi có thay đổi.

## 3. Công cụ và công nghệ sử dụng
- **GitLab Server**: Nền tảng quản lý mã nguồn và CI/CD tại `http://caothedo.gitlab.com`.
- **GitLab Runner**: Công cụ thực thi pipeline, sử dụng Docker executor.
- **Node.js**: Môi trường runtime cho dự án.
- **Express**: Framework web cho ứng dụng mẫu.
- **Mocha và Chai**: Thư viện kiểm thử để chạy unit test.
- **Docker**: Hỗ trợ chạy các job CI/CD trong môi trường containerized.

## 4. Quy trình thực hiện

### 4.1. Thiết lập dự án
- **Tạo dự án trên GitLab Server**:
  - Tạo dự án `shoes` trên GitLab Server tại `http://caothedo.gitlab.com` với mức độ truy cập Private.
  - URL repository: `http://caothedo.gitlab.com/your-group/shoes.git`.
- **Tạo ứng dụng Node.js mẫu**:
  - Khởi tạo dự án Node.js cục bộ:
    ```bash
    mkdir shoes
    cd shoes
    npm init -y
    npm install express mocha chai --save-dev
    ```
  - Tạo file `index.js` (ứng dụng Express cơ bản):
    ```javascript
    const express = require('express');
    const app = express();

    app.get('/', (req, res) => {
      res.send('Hello, GitLab CI/CD!');
    });

    app.listen(3000, () => {
      console.log('Server is running on port 3000');
    });
    ```
  - Tạo file `test.js` (test case với Mocha/Chai):
    ```javascript
    const chai = require('chai');
    const expect = chai.expect;

    describe('Sample Test', () => {
      it('should return true', () => {
        expect(true).to.equal(true);
      });
    });
    ```
  - Cập nhật `package.json` với script:
    ```json
    "scripts": {
      "start": "node index.js",
      "test": "mocha test.js"
    }
    ```
  - Đẩy mã nguồn lên GitLab:
    ```bash
    git init
    git add .
    git commit -m "Initial commit for shoes project"
    git remote add origin http://caothedo.gitlab.com/your-group/shoes.git
    git push -u origin master
    ```

###ස

### 4.2. Cài đặt và cấu hình GitLab Runner
- **Cài đặt GitLab Runner**:
  - Cài đặt trên máy chủ Ubuntu:
    ```bash
    sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
    sudo chmod +x /usr/local/bin/gitlab-runner
    sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    sudo gitlab-runner start
    ```
- **Đăng ký Runner**:
  - Lấy Registration Token từ **Settings > CI/CD > Runners** của dự án `shoes` trên `http://caothedo.gitlab.com`.
  - Đăng ký Runner với Docker executor:
    ```bash
    sudo gitlab-runner register
    ```
    - URL: `http://caothedo.gitlab.com`.
    - Token: [Registration Token].
    - Executor: `docker`.
    - Default image: `node:16`.
- **Cài đặt Docker** (nếu chưa có):
  ```bash
  sudo apt-get update
  sudo apt-get install docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
  ```

### 4.3. Cấu hình pipeline CI/CD
- Tạo file `.gitlab-ci.yml` trong thư mục dự án `shoes`:
  ```yaml
  image: node:16

  stages:
    - build
    - test

  cache:
    paths:
      - node_modules/

  build_job:
    stage: build
    script:
      - npm install
    artifacts:
      paths:
        - node_modules/

  test_job:
    stage: test
    script:
      - npm test
  ```
- Đẩy file cấu hình lên GitLab:
  ```bash
  git add .gitlab-ci.yml
  git commit -m "Add CI/CD pipeline for shoes project"
  git push origin master
  ```

### 4.4. Kiểm tra và chạy pipeline
- Pipeline được kích hoạt tự động khi đẩy mã nguồn lên branch `master`.
- Truy cập **CI/CD > Pipelines** trên giao diện GitLab tại `http://caothedo.gitlab.com` để kiểm tra trạng thái.
- Pipeline bao gồm hai job:
  - `build_job`: Cài đặt dependencies (`npm install`).
  - `test_job`: Chạy unit test (`npm test`).
- Kết quả pipeline được hiển thị là **Passed** nếu không có lỗi.

## 5. Kết quả
- Pipeline CI/CD cho dự án `shoes` đã được thiết lập thành công trên GitLab Server tại `http://caothedo.gitlab.com`.
- Mỗi khi mã nguồn được đẩy lên branch `master`, pipeline tự động:
  - Cài đặt các dependencies cần thiết.
  - Chạy unit test để kiểm tra tính đúng đắn của mã nguồn.
- GitLab Runner hoạt động ổn định với Docker executor, đảm bảo môi trường thực thi nhất quán.

## 6. Đề xuất cải tiến
- **Thêm stage deploy**: Tích hợp bước triển khai ứng dụng lên server (ví dụ: Heroku, AWS) để hoàn thiện quy trình CI/CD.
- **Tích hợp thêm kiểm tra bảo mật**: Sử dụng các công cụ như Dependency Scanning hoặc SAST của GitLab để phát hiện lỗ hổng.
- **Mở rộng test**: Thêm các test phức tạp hơn (integration test, end-to-end test) để nâng cao chất lượng mã nguồn.
- **Tối ưu hóa pipeline**: Sử dụng cache và parallel jobs để giảm thời gian chạy pipeline.

## 7. Kết luận
Quy trình CI/CD cho dự án `shoes` đã được triển khai thành công, cung cấp một nền tảng tự động hóa để đảm bảo mã nguồn được build và kiểm tra liên tục. GitLab Server tại `http://caothedo.gitlab.com`, với sự hỗ trợ của GitLab Runner, là một giải pháp mạnh mẽ và linh hoạt cho việc quản lý và triển khai CI/CD. Dự án này có thể được mở rộng thêm để hỗ trợ các yêu cầu phức tạp hơn trong tương lai.