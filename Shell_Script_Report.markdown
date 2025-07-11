# Báo Cáo Về Các Lệnh Shell Script

## 1. Giới Thiệu
Shell script là một tập hợp các lệnh được viết trong một tệp văn bản để thực thi tự động trên hệ điều hành dựa trên Unix/Linux. Shell script giúp tự động hóa các tác vụ, quản lý hệ thống và thực hiện các lệnh phức tạp một cách dễ dàng. Shell phổ biến nhất là **Bash** (Bourne Again Shell).

## 2. Các Thành Phần Cơ Bản

### 2.1. Shebang
Dòng đầu tiên của shell script thường là **shebang**, chỉ định shell sẽ thực thi script:
```bash
#!/bin/bash
```

### 2.2. Biến
Biến được sử dụng để lưu trữ dữ liệu:
- Khai báo: `name="Grok"`
- Sử dụng: `echo $name`

### 2.3. Tham số
- `$1`, `$2`, ...: Các tham số truyền vào script.
- `$0`: Tên của script.
- `$#`: Số lượng tham số.
- `$@`: Tất cả tham số.

### 2.4. Cấu trúc điều khiển
- **If-else**:
  ```bash
  if [ $1 -gt 10 ]; then
      echo "Greater than 10"
  else
      echo "Less than or equal to 10"
  fi
  ```
- **Vòng lặp**:
  - For:
    ```bash
    for i in {1..5}; do
        echo "Number $i"
    done
    ```
  - While:
    ```bash
    count=1
    while [ $count -le 5 ]; do
        echo "Count $count"
        ((count++))
    done
    ```

### 2.5. Hàm
Hàm giúp tái sử dụng mã:
```bash
greet() {
    echo "Hello, $1!"
}
greet "Grok"
```

### 2.6. Toán tử kiểm tra
Toán tử kiểm tra được sử dụng trong cấu trúc điều kiện (như `if` hoặc `while`) để đánh giá các điều kiện. Chúng thường được dùng với lệnh `test` hoặc trong dấu ngoặc `[ ]`.

#### 2.6.1. Toán tử kiểm tra tệp
| Toán tử       | Mô tả                              |
|---------------|------------------------------------|
| `-e file`     | Kiểm tra tệp/thư mục có tồn tại.   |
| `-f file`     | Kiểm tra tệp có phải là tệp thường.|
| `-d file`     | Kiểm tra tệp có phải là thư mục.   |
| `-r file`     | Kiểm tra tệp có quyền đọc.         |
| `-w file`     | Kiểm tra tệp có quyền ghi.         |
| `-x file`     | Kiểm tra tệp có quyền thực thi.    |
| `-s file`     | Kiểm tra tệp có kích thước > 0.    |

Ví dụ:
```bash
if [ -f "data.txt" ]; then
    echo "data.txt is a regular file"
else
    echo "data.txt does not exist or is not a regular file"
fi
```

#### 2.6.2. Toán tử kiểm tra chuỗi
| Toán tử           | Mô tả                              |
|-------------------|------------------------------------|
| `-z string`       | Kiểm tra chuỗi rỗng.               |
| `-n string`       | Kiểm tra chuỗi không rỗng.         |
| `string1 = string2` | Kiểm tra chuỗi bằng nhau.          |
| `string1 != string2` | Kiểm tra chuỗi không bằng nhau.    |

Ví dụ:
```bash
name="Grok"
if [ -n "$name" ]; then
    echo "Name is not empty: $name"
fi
```

#### 2.6.3. Toán tử kiểm tra số
| Toán tử           | Mô tả                              |
|-------------------|------------------------------------|
| `num1 -eq num2`   | Bằng nhau.                         |
| `num1 -ne num2`   | Không bằng nhau.                   |
| `num1 -gt num2`   | Lớn hơn.                           |
| `num1 -lt num2`   | Nhỏ hơn.                           |
| `num1 -ge num2`   | Lớn hơn hoặc bằng.                 |
| `num1 -le num2`   | Nhỏ hơn hoặc bằng.                 |

Ví dụ:
```bash
num=15
if [ $num -gt 10 ]; then
    echo "Number is greater than 10"
fi
```

#### 2.6.4. Toán tử logic
| Toán tử | Mô tả                              |
|---------|------------------------------------|
| `-a`    | AND (và) - kết hợp hai điều kiện.  |
| `-o`    | OR (hoặc) - một trong hai điều kiện đúng. |
| `!`     | NOT (phủ định) - đảo ngược điều kiện. |

Ví dụ:
```bash
if [ -f "data.txt" -a -r "data.txt" ]; then
    echo "data.txt exists and is readable"
fi
```

## 3. Các Lệnh Shell Phổ Biến
Dưới đây là một số lệnh thường dùng trong shell script:

| Lệnh         | Mô tả                                                                 |
|--------------|----------------------------------------------------------------------|
| `echo`       | In văn bản hoặc giá trị biến ra màn hình.                            |
| `read`       | Nhập dữ liệu từ người dùng.                                          |
| `grep`       | Tìm kiếm chuỗi trong tệp hoặc đầu ra.                                |
| `awk`        | Xử lý và phân tích văn bản.                                          |
| `sed`        | Chỉnh sửa luồng văn bản.                                             |
| `find`       | Tìm kiếm tệp/thư mục trong hệ thống.                                 |
| `chmod`      | Thay đổi quyền truy cập của tệp.                                     |
| `if`, `case` | Cấu trúc điều kiện để kiểm tra và phân nhánh.                         |
| `for`, `while` | Vòng lặp để lặp lại các tác vụ.                                      |

### 3.1. Các lệnh tương tự `df` (Quản lý dung lượng và tài nguyên)
Dưới đây là các lệnh liên quan đến quản lý dung lượng ổ đĩa và tài nguyên hệ thống, tương tự `df`:

| Lệnh         | Mô tả                                                                 |
|--------------|----------------------------------------------------------------------|
| `df`         | Hiển thị thông tin dung lượng ổ đĩa (tổng, đã dùng, còn trống).      |
| `du`         | Hiển thị dung lượng sử dụng của tệp hoặc thư mục cụ thể.             |
| `free`       | Hiển thị thông tin bộ nhớ RAM (tổng, đã dùng, còn trống).            |
| `lsblk`      | Liệt kê các thiết bị khối (block devices) như ổ đĩa, phân vùng.      |
| `fdisk`      | Quản lý phân vùng ổ đĩa (yêu cầu quyền root).                        |

#### Ví dụ sử dụng
- **`df -h`**: Hiển thị dung lượng ổ đĩa theo định dạng dễ đọc (MB, GB).
  ```bash
  df -h
  # Kết quả ví dụ:
  # Filesystem      Size  Used Avail Use% Mounted on
  # /dev/sda1       100G   50G   50G  50% /
  ```
- **`du -sh /path/to/dir`**: Hiển thị tổng dung lượng của thư mục.
  ```bash
  du -sh /home/user
  # Kết quả ví dụ: 1.2G /home/user
  ```
- **`free -h`**: Hiển thị thông tin bộ nhớ RAM.
  ```bash
  free -h
  # Kết quả ví dụ:
  #               total        used        free
  # Mem:           7.8G        3.2G        4.6G
  ```
- **`lsblk`**: Liệt kê các phân vùng và điểm gắn.
  ```bash
  lsblk
  # Kết quả ví dụ:
  # NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  # sda       8:0    0  100G  0 disk
  # └─sda1    8:1    0  100G  0 part /
  ```

#### Ví dụ script sử dụng các lệnh trên
```bash
#!/bin/bash
echo "Disk Usage:"
df -h /
echo -e "\nDirectory Size:"
du -sh /home
echo -e "\nMemory Usage:"
free -h
echo -e "\nBlock Devices:"
lsblk
```

## 4. Ví Dụ Shell Script
Dưới đây là một script đơn giản kiểm tra trạng thái dịch vụ, sử dụng toán tử kiểm tra:
```bash
#!/bin/bash
SERVICE="nginx"
if systemctl is-active --quiet $SERVICE; then
    echo "$SERVICE is running"
else
    echo "$SERVICE is not running"
    systemctl start $SERVICE
fi
```

## 5. Ứng Dụng
- **Tự động hóa**: Tự động sao lưu dữ liệu, giám sát hệ thống.
- **Quản trị hệ thống**: Quản lý người dùng, dịch vụ, log hệ thống.
- **Xử lý tệp**: Phân tích log, tìm kiếm và thay thế văn bản.

## 6. Kết Luận
Shell script là công cụ mạnh mẽ, linh hoạt để tự động hóa và quản lý hệ thống. Việc nắm vững các lệnh cơ bản, cấu trúc điều khiển, toán tử kiểm tra và các lệnh quản lý tài nguyên như `df`, `du`, `free`, `lsblk` giúp người dùng tối ưu hóa công việc. Để nâng cao, nên học thêm về xử lý lỗi và các công cụ như `awk`, `sed`.