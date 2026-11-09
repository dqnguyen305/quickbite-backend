# quickbite-backend

Dự án backend đơn giản cho 2 bài tập:

- **Bài 1**: khởi chạy và chẩn đoán container PostgreSQL (`quickbite-db`).
- **Bài 2**: kết nối `user-service` (chạy trên máy host) vào database trong container.

## Cấu trúc

```
quickbite-backend/
├── scripts/run-db.sh           # Bài 1: lệnh docker run
├── docker-compose.yml          # (tùy chọn) cách khác để dựng DB, KHÔNG dùng chung với docker run
├── user-service/               # Bài 2: Spring Boot + Gradle + JPA + PostgreSQL
└── homework/session_02/
    ├── exercise_01/db_status.png                  # ảnh nộp Bài 1 (tự thêm)
    └── exercise_02/user_service_db_connect.png    # ảnh nộp Bài 2 (tự thêm)
```

---

## Bài 1: Khởi chạy container PostgreSQL

### Làm lại từ đầu (xóa container và dữ liệu cũ)

```bash
docker rm -f quickbite-db
docker volume prune -f
```

### Khởi chạy container

```bash
docker run -d \
  --name quickbite-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=12345678 \
  postgres:15-alpine
```

Hoặc chạy script: `bash scripts/run-db.sh`

### Kiểm tra

```bash
docker ps        # thấy quickbite-db, STATUS Up, PORTS 0.0.0.0:5432->5432/tcp
docker images    # thấy postgres, TAG 15-alpine
```

Chụp màn hình lệnh `docker ps`, lưu vào `homework/session_02/exercise_01/db_status.png`.

### Nếu có lỗi

- `port is already allocated`: có thứ khác đang dùng port 5432, tắt nó hoặc xem `docker ps -a`.
- `The container name "/quickbite-db" is already in use`: chạy `docker rm -f quickbite-db` rồi chạy lại.
- Xem log: `docker logs quickbite-db`

---

## Bài 2: Kết nối user-service vào database

Yêu cầu: JDK 17 trở lên.

### Biến môi trường

`application.yml` đọc cấu hình từ biến môi trường, nếu không đặt thì dùng giá trị mặc định trong file:

| Biến          | Giá trị mặc định                                   |
|---------------|----------------------------------------------------|
| `DB_URL`      | `jdbc:postgresql://221.121.6.27:5432/postgres`     |
| `DB_USERNAME` | `postgres`                                         |
| `DB_PASSWORD` | `12345678`                                         |

Muốn đặt biến môi trường (theo yêu cầu đề bài) thì làm như sau.

Linux / WSL:
```bash
export DB_URL=jdbc:postgresql://221.121.6.27:5432/postgres
export DB_USERNAME=postgres
export DB_PASSWORD=12345678
```

Windows PowerShell:
```powershell
$env:DB_URL="jdbc:postgresql://221.121.6.27:5432/postgres"
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="12345678"
```

### Chạy

```bash
cd user-service
./gradlew bootRun
```

Kết quả mong đợi: có dòng `HikariPool-1 - Start completed.` và `Started UserServiceApplication`, không có `Connection refused`.

Chụp màn hình console, lưu vào `homework/session_02/exercise_02/user_service_db_connect.png`.

### Kiểm thử API

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Nguyen Van A","email":"a@example.com"}'

curl http://localhost:8081/api/users
```

### Database trên máy chủ

`application.yml` mặc định đã trỏ tới database trên máy chủ `221.121.6.27`, nên chỉ cần `./gradlew bootRun`, không phải đặt biến môi trường.

Muốn trỏ chỗ khác (ví dụ DB trên laptop) thì đặt `DB_URL`, biến này luôn được ưu tiên hơn giá trị trong file:

```bash
export DB_URL=jdbc:postgresql://localhost:5432/postgres
```

Máy chủ phải mở port 5432 cho IP của bạn (ví dụ `sudo ufw allow from <IP-laptop> to any port 5432 proto tcp`).
Kiểm tra đường truyền: `Test-NetConnection 221.121.6.27 -Port 5432`.

---

## Đẩy lên GitHub

```bash
git init
git add .
git commit -m "Add quickbite-backend"
git branch -M main
git remote add origin https://github.com/<ten-ban>/quickbite-backend.git
git push -u origin main
```

## Kéo dự án về Ubuntu (WSL)

```bash
cd /mnt/d && mkdir -p Projects && cd Projects
git clone https://github.com/<ten-ban>/quickbite-backend.git
cd quickbite-backend/user-service
./gradlew bootRun
```

> Nếu `./gradlew` báo `Permission denied` thì chạy `chmod +x gradlew`. Nếu báo lỗi ký tự `\r` thì chạy `sed -i 's/\r$//' gradlew`.
