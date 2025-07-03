# Build Docker cơ bản

Báo cáo này hướng dẫn cách xây dựng và triển khai một ứng dụng Spring Boot sử dụng Docker, bao gồm việc tạo ứng dụng, viết Dockerfile, cấu hình Docker Compose, và các bước để chạy và vận hành ứng dụng.

## 1. Tạo và cài đặt ứng dụng (Framework Spring Boot)

### 1.1. Yêu cầu
- **Java 21**: Phiên bản Java được sử dụng để phát triển và chạy ứng dụng.
- **Maven**: Công cụ quản lý phụ thuộc và build dự án.
- **Docker**: Để tạo và chạy container.
- **Docker Compose**: Để quản lý và chạy các dịch vụ Docker.

### 1.2. Tạo dự án Spring Boot
1. **Tạo cấu trúc dự án**:
   Sử dụng Maven để tạo một dự án Spring Boot cơ bản với cấu trúc thư mục:
   ```
   spring-boot-docker/
   ├── src/
   │   ├── main/
   │   │   ├── java/com/example/demo/
   │   │   │   ├── DemoApplication.java
   │   │   │   ├── controller/
   │   │   │   │   └── HelloController.java
   │   │   └── resources/
   │   │       └── application.properties
   ├── Dockerfile
   ├── docker-compose.yml
   ├── pom.xml
   └── README.md
   ```

2. **File `pom.xml`**:
   File cấu hình Maven, bao gồm các phụ thuộc cần thiết cho Spring Boot.
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>

       <groupId>com.example</groupId>
       <artifactId>demo</artifactId>
       <version>0.0.1-SNAPSHOT</version>
       <name>demo</name>
       <description>Demo project for Spring Boot with Docker</description>

       <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>3.3.4</version>
           <relativePath/>
       </parent>

       <properties>
           <java.version>21</java.version>
       </properties>

       <dependencies>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-test</artifactId>
               <scope>test</scope>
           </dependency>
       </dependencies>

       <build>
           <plugins>
               <plugin>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-maven-plugin</artifactId>
               </plugin>
           </plugins>
       </build>
   </project>
   ```

3. **File Main Application (`DemoApplication.java`)**:
   Lớp chính để khởi động ứng dụng Spring Boot.
   ```java
   package com.example.demo;

   import org.springframework.boot.SpringApplication;
   import org.springframework.boot.autoconfigure.SpringBootApplication;

   @SpringBootApplication
   public class DemoApplication {
       public static void main(String[] args) {
           SpringApplication.run(DemoApplication.class, args);
       }
   }
   ```

4. **File Controller (`HelloController.java`)**:
   Tạo một API REST cơ bản trả về thông điệp "Xin chào".
   ```java
   package com.example.demo.controller;

   import org.springframework.web.bind.annotation.GetMapping;
   import org.springframework.web.bind.annotation.RestController;

   @RestController
   public class HelloController {
       @GetMapping("/hello")
       public String hello() {
           return "Xin chào từ Spring Boot!";
       }
   }
   ```

5. **File cấu hình (`application.properties`)**:
   Cấu hình cổng 8081 để tránh xung đột với Jenkins (chạy trên cổng 8080).
   ```properties
   server.port=8081
   spring.application.name=demo
   ```

6. **Build dự án**:
   Chạy lệnh sau để tạo file JAR (`target/demo-0.0.1-SNAPSHOT.jar`):
   ```bash
   mvn clean package
   ```

## 2. Cách viết Dockerfile

`Dockerfile` là file cấu hình để tạo Docker image, chứa các lệnh để thiết lập môi trường và chạy ứng dụng.

### Nội dung Dockerfile
```dockerfile
# Sử dụng image cơ sở OpenJDK 21 phiên bản nhẹ
FROM openjdk:21-jdk-slim

# Thiết lập thư mục làm việc
WORKDIR /app

# Sao chép file JAR từ thư mục target vào container
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Mở cổng 8081 cho ứng dụng
EXPOSE 8081

# Lệnh chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Giải thích
- **`FROM openjdk:21-jdk-slim`**: Sử dụng image Java 21 nhẹ để giảm kích thước.
- **`WORKDIR /app`**: Đặt thư mục làm việc trong container.
- **`COPY target/demo-0.0.1-SNAPSHOT.jar app.jar`**: Sao chép file JAR từ thư mục `target` (được tạo bởi Maven) vào container.
- **`EXPOSE 8081`**: Khai báo cổng ứng dụng sử dụng (phải khớp với `server.port` trong `application.properties`).
- **`ENTRYPOINT ["java", "-jar", "app.jar"]`**: Chạy ứng dụng Spring Boot khi container khởi động.

### Lưu ý
- Đảm bảo file `demo-0.0.1-SNAPSHOT.jar` tồn tại trong thư mục `target` trước khi build image.
- Nếu `artifactId` hoặc `version` trong `pom.xml` khác, cập nhật tên file trong dòng `COPY`.

## 3. Cách viết docker-compose.yml

`docker-compose.yml` định nghĩa và quản lý các dịch vụ Docker, giúp chạy ứng dụng dễ dàng hơn.

### Nội dung docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
```

### Giải thích
- **`version: '3.8'`**: Phiên bản cú pháp Docker Compose, tương thích với Docker hiện tại.
- **`services`**: Định nghĩa các dịch vụ (ở đây là `app` cho ứng dụng Spring Boot).
- **`build`**: Chỉ định cách build image:
  - `context: .`: Thư mục hiện tại chứa `Dockerfile`.
  - `dockerfile: Dockerfile`: Tên file Dockerfile.
- **`ports`**: Ánh xạ cổng 8081 trên máy host sang cổng 8081 trong container.
- **`environment`**: Thiết lập biến môi trường, ở đây kích hoạt profile `prod` cho Spring Boot.

### Lưu ý
- Cổng host (8081) phải không bị chiếm dụng. Kiểm tra bằng:
  ```bash
  lsof -i :8081
  ```
- Nếu cần thêm dịch vụ (như database), bạn có thể mở rộng file này (xem ví dụ ở phần mở rộng).

## 4. Cách chạy và vận hành

### 4.1. Chuẩn bị
1. **Kiểm tra yêu cầu**:
   - Đảm bảo Java 21, Maven, Docker, và Docker Compose đã được cài đặt:
     ```bash
     java -version
     mvn -version
     docker --version
     docker-compose --version
     ```
2. **Build ứng dụng**:
   ```bash
   mvn clean package
   ```
   Kiểm tra file JAR:
   ```bash
   ls target/
   ```
   Kết quả mong đợi: thấy `demo-0.0.1-SNAPSHOT.jar`.

### 4.2. Build Docker image
Từ thư mục gốc (chứa `Dockerfile`), chạy:
```bash
docker build -t spring-boot-demo .
```
- `-t spring-boot-demo`: Đặt tên image.
- `.`: Chỉ định thư mục hiện tại làm build context.

### 4.3. Chạy ứng dụng với Docker
Chạy bằng Docker Compose:
```bash
docker-compose up
```
- Lệnh này build image (nếu chưa có) và khởi động container.
- Log ứng dụng sẽ hiển thị trong terminal.

### 4.4. Kiểm tra API
Truy cập API:
```bash
curl http://localhost:8081/hello
```
Kết quả mong đợi: `Xin chào từ Spring Boot!`

### 4.5. Dừng ứng dụng
Dừng và xóa container:
```bash
docker-compose down
```

### 4.6. Vận hành và giám sát
- **Xem log**: Khi chạy `docker-compose up`, log được hiển thị trực tiếp. Để xem log của container đang chạy:
  ```bash
  docker logs <container_name>
  ```
  (Tìm `container_name` bằng `docker ps`).
- **Kiểm tra trạng thái container**:
  ```bash
  docker ps
  ```
- **Khởi động lại**:
  ```bash
  docker-compose restart
  ```
- **Xóa image nếu cần**:
  ```bash
  docker rmi spring-boot-demo
  ```

## 5. Mở rộng (Tùy chọn)
### Thêm database (MySQL)
Cập nhật `docker-compose.yml` để thêm dịch vụ MySQL:
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/mydb
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=secret
    depends_on:
      - db
  db:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=secret
      - MYSQL_DATABASE=mydb
```
Cập nhật `application.properties`:
```properties
server.port=8081
spring.application.name=demo
spring.datasource.url=jdbc:mysql://db:3306/mydb
spring.datasource.username=root
spring.datasource.password=secret
spring.jpa.hibernate.ddl-auto=update
```

### Tối ưu Dockerfile với multi-stage build
```dockerfile
# Stage 1: Build ứng dụng
FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Tạo image chạy
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=builder /build/target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 6. Khắc phục sự cố
- **Lỗi file JAR không tìm thấy**:
  - Đảm bảo chạy `mvn clean package`.
  - Kiểm tra tên file JAR trong `target` và cập nhật dòng `COPY` trong `Dockerfile`.
- **Lỗi cổng 8081 bị chiếm dụng**:
  - Kiểm tra:
    ```bash
    lsof -i :8081
    ```
  - Đổi cổng trong `application.properties`, `Dockerfile`, và `docker-compose.yml` nếu cần.
- **Lỗi build image**:
  - Xóa cache và thử lại:
    ```bash
    docker build --no-cache -t spring-boot-demo .
    ```

## 7. Kết luận
Báo cáo này đã cung cấp hướng dẫn chi tiết để xây dựng và triển khai ứng dụng Spring Boot với Docker, từ việc tạo dự án, viết `Dockerfile` và `docker-compose.yml`, đến các bước chạy và vận hành. Các file được cấu hình để sử dụng cổng 8081, tránh xung đột với Jenkins trên cổng 8080.