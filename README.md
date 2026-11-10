# 🎓 Ftech Learning Online - Hệ thống Quản trị & Học trực tuyến (LMS)

> 🏫 **Trường Đại học FPT - Phân hiệu Cần Thơ**  
> 📖 **Bài tập lớn / Project cuối kỳ môn học: Lập trình Web với Java (PRJ301 / PRJ Project)**

[![University](https://img.shields.io/badge/%C4%90%E1%BA%A1i%20h%E1%BB%8Dc%20FPT-Ph%C3%A2n%20hi%E1%BB%87u%20C%E1%BA%A7n%20Th%C6%A1-FF5722.svg)](https://cantho.fpt.edu.vn/)
[![Java](https://img.shields.io/badge/Java-Jakarta%20EE%2010-orange.svg)](https://jakarta.ee/)
[![Server](https://img.shields.io/badge/Apache%20Tomcat-10.1-blue.svg)](https://tomcat.apache.org/)
[![Database](https://img.shields.io/badge/MS%20SQL%20Server-2019%2B-red.svg)](https://www.microsoft.com/sql-server/)
[![Build](https://img.shields.io/badge/Maven-3.8%2B-green.svg)](https://maven.apache.org/)
[![Theme](https://img.shields.io/badge/UI-Dark%20%2F%20Light%20Mode-purple.svg)](#)

---

## 📌 Giới thiệu Tổng quan (System Overview)

**Ftech Learning Online** là nền tảng học tập và thương mại khóa học trực tuyến (Paid & Free LMS) được thiết kế và xây dựng theo chuẩn kiến trúc **Java Web MVC (Jakarta EE / Servlet / JSP)** kết nối cơ sở dữ liệu **Microsoft SQL Server**.

Hệ thống cung cấp trải nghiệm hoàn chỉnh cho mọi đối tượng người dùng: từ học viên tìm kiếm và học tập bài giảng video tương tác, giảng viên biên soạn giáo trình và theo dõi doanh thu, cho đến quản trị viên vận hành, kiểm duyệt và phân tích số liệu toàn sàn. Giao diện được tối ưu với chế độ **Dark / Light Theme** chuyển đổi tức thì cùng hiệu ứng hiện đại.

---

## 👥 Đội ngũ Thực hiện & Phân công Nhiệm vụ (Team Members)

| STT | Họ và Tên | Vai trò | Module Phụ trách chính |
| :---: | :--- | :---: | :--- |
| 1 | 👑 **Vương Hoàng Phúc** | **Trưởng nhóm / Leader** | • Quản lý Hồ sơ cá nhân (Profile)<br>• Đổi mật khẩu & Cài đặt bảo mật<br>• Thiết kế giao diện & Tối ưu hóa UI/UX<br>• Chuẩn hóa hiển thị Dark / Light Mode |
| 2 | 💻 **Nguyễn Phát Tài** | **Fullstack Developer** | • Quản trị hệ thống Quản trị viên (Admin Dashboard)<br>• Giỏ hàng & Thanh toán (Cart, Checkout & Idempotency)<br>• Lịch sử đơn hàng & Thống kê Doanh thu (Chart.js)<br>• Tích hợp hệ thống & Đồng bộ kiến trúc tổng thể |
| 3 | ⚙️ **Huỳnh Trọng Nhân** | **Backend Developer** | • Phòng học trực tuyến (Learning Player)<br>• Theo dõi & Lưu tiến độ bài học video (Auto-sync position)<br>• Hệ thống Bình luận & Thảo luận bài học (Discussions)<br>• Đánh giá khóa học & Xếp hạng sao (Course Reviews) |
| 4 | 📝 **Giang Quốc Khánh** | **Backend Developer** | • Không gian Giảng viên (Instructor Studio)<br>• Soạn thảo & Quản lý giáo trình khóa học (Curriculum)<br>• Xác thực Đăng nhập, Đăng ký & Bảo mật phiên (Auth / Session)<br>• Phân quyền tài khoản người dùng (RBAC) |
| 5 | 🎯 **Trần Minh Khoa** | **Backend & Khảo thí** | • Quy trình Kiểm duyệt khóa học (Course Approvals)<br>• Quản trị danh mục & Bảng điều khiển kiểm duyệt<br>• Ngân hàng câu hỏi & Bài thi trắc nghiệm (Quizzes)<br>• Tự động chấm điểm & Đánh giá kết quả đạt/không đạt |

---

## 🚀 Các Phân hệ & Tính năng Nổi bật (Core Features)

### 1. 🎓 Phân hệ Học viên (Student Experience)
- **Khám phá khóa học**: Tìm kiếm theo từ khóa, lọc theo danh mục, mức giá (Miễn phí / Trả phí), xem bài học thử (`Preview Lesson`).
- **Giỏ hàng & Thanh toán**: Thêm/xóa giỏ hàng, áp dụng mã giảm giá (Coupon), xử lý thanh toán mô phỏng VNPAY Sandbox, sinh mã đơn hàng Idempotent chống trùng lặp.
- **Phòng học trực tuyến**: Trình phát video bài giảng, tự động đồng bộ giây đang xem (`auto-sync Beacon/Fetch`), đánh dấu hoàn thành bài học.
- **Thảo luận bài học**: Đặt câu hỏi theo từng bài học cụ thể, nhận câu trả lời trực tiếp từ Giảng viên với huy hiệu riêng.
- **Bài kiểm tra trắc nghiệm (Quiz)**: Làm bài thi trắc nghiệm nhiều lựa chọn, tự động tính điểm theo phần trăm và xét qua môn (`Passing Score`).
- **Đánh giá khóa học**: Xếp hạng từ 1 đến 5 sao và gửi nhận xét cảm nhận sau khi tham gia khóa học.
- **Hồ sơ cá nhân**: Quản lý thông tin, đổi mật khẩu, xem tổng số khóa học đã tham gia và hoàn thành.

### 2. 👨‍🏫 Phân hệ Giảng viên (Instructor Studio)
- **Studio Dashboard**: Theo dõi tổng doanh thu, số học viên ghi danh, biểu đồ doanh thu theo các tháng bằng **Chart.js**, danh sách học viên mới nhất.
- **Quản lý khóa học**: Tạo khóa học mới, chỉnh sửa thông tin, giá bán, mục tiêu bài học (`Learning Objectives`), gửi yêu cầu duyệt khóa học lên Admin.
- **Soạn thảo giáo trình (Curriculum)**: Quản lý chương (`Chapter`) và bài học (`Lesson`), kéo thả/sắp xếp thứ tự, upload video, đính kèm tài liệu học tập.
- **Ngân hàng câu hỏi & Đề thi**: Tạo đề trắc nghiệm, thêm/sửa/xóa câu hỏi và các đáp án lựa chọn, cài đặt điểm số và thời lượng làm bài.
- **Quản lý học viên**: Xem tiến độ học tập của từng sinh viên theo khóa học, xuất danh sách học viên ra file Excel (`Apache POI`).
- **Tương tác phòng học**: Nút *"Vào xem phòng học & Thảo luận"* truy cập trực tiếp bài giảng để giải đáp thắc mắc của sinh viên.

### 3. 🛡️ Phân hệ Quản trị viên (Admin Portal)
- **Admin Dashboard**: Thống kê doanh thu nền tảng, số lượng khóa học, học viên, giảng viên và biểu đồ tài chính trực quan.
- **Phê duyệt khóa học (Approval Workflow)**: Phân loại khóa học Chờ duyệt / Bản nháp / Đã xuất bản, xem trước nội dung, phê duyệt (`PUBLISHED`) hoặc từ chối kèm lý do phản hồi cho Giảng viên.
- **Quản trị người dùng**: Danh sách toàn bộ tài khoản, lọc theo vai trò (Student, Instructor, Admin), khóa (`LOCKED`) hoặc kích hoạt lại tài khoản.
- **Quản trị danh mục**: Thêm, sửa, kích hoạt hoặc ẩn danh mục khóa học trên sàn.
- **Quản lý đơn hàng**: Theo dõi lịch sử giao dịch toàn sàn, lọc trạng thái (`PAID`, `PENDING`, `CANCELLED`), xuất danh sách đơn hàng ra file Excel.
- **Kiểm duyệt nội dung (Moderation)**: Kiểm soát toàn bộ bình luận thảo luận và đánh giá của sinh viên trên hệ thống, bật/tắt hiển thị khi có vi phạm.
- **Đặc quyền Quản trị**: Tự do vào xem toàn bộ bài giảng và phòng học trên sàn mà không cần thực hiện thao tác mua khóa học.

---

## 🛠️ Công nghệ Sử dụng (Tech Stack)

| Thành phần | Công nghệ / Thư viện |
| :--- | :--- |
| **Backend Core** | Java 17 / Java 21, Jakarta EE 10 (Servlet 6.0, JSP 3.1, JSTL) |
| **Kiến trúc** | MVC (Model - View - Controller), DAO Pattern, Service Layer, Singleton Connection Pool |
| **Cơ sở dữ liệu** | Microsoft SQL Server (29 bảng chuẩn hóa 3NF, Idempotent script, Trigger, Stored Procedures) |
| **Frontend** | HTML5, CSS Variables, Bootstrap 5.3, Bootstrap Icons, JavaScript ES6 (Fetch API, Beacon API) |
| **Đồ họa & Báo cáo** | Chart.js (Biểu đồ doanh thu tương tác), Apache POI (Xuất file Excel `.xlsx`) |
| **Bảo mật** | PBKDF2 with SHA-256 (Mã hóa mật khẩu), CSRF Token, Idempotency Key, PreparedStatement (Chống SQL Injection 100%), Role-based Access Control (RBAC) |
| **Web Server** | Apache Tomcat 10.1+ |
| **Quản lý dự án** | Apache Maven, Git / GitHub |

---

## ⚙️ Hướng dẫn Cài đặt & Khởi chạy (Setup Guide)

### 1. Yêu cầu Môi trường
- **JDK**: Java 17 trở lên (khuyến nghị JDK 21 hoặc OpenJDK 26).
- **Web Server**: Apache Tomcat 10.1.x (hỗ trợ namespace `jakarta.*`).
- **Database**: Microsoft SQL Server 2019+ (đã bật TCP/IP tại cổng `1433`).
- **Build Tool**: Apache Maven 3.8+.

### 2. Cài đặt Cơ sở Dữ liệu
1. Mở **SQL Server Management Studio (SSMS)** hoặc Azure Data Studio.
2. Mở file kịch bản tại đường dẫn: `database/FtechDemo_SQLServer.sql`.
3. Nhấn **Execute** (`F5`) để khởi tạo CSDL `FtechDemoDB` kèm 29 bảng và dữ liệu mẫu (Kịch bản idempotent an toàn, có thể chạy lại nhiều lần).

### 3. Cấu hình Kết nối CSDL
Mặc định hệ thống kết nối qua file `src/main/java/config/DBContext.java`:
```properties
Server: localhost:1433
DatabaseName: FtechDemoDB
User: sa
Password: sa12345
```
*(Bạn có thể cấu hình linh hoạt qua biến môi trường `LEARNORA_DB_URL`, `LEARNORA_DB_USER`, `LEARNORA_DB_PASSWORD` hoặc file `db.properties`)*.

### 4. Biên dịch & Triển khai (Deploy)
```bash
# 1. Di chuyển vào thư mục dự án
cd GroupASM

# 2. Biên dịch và đóng gói WAR
mvn clean package -DskipTests

# 3. Triển khai lên Tomcat:
# Copy file target/GroupASM-1.0-SNAPSHOT.war vào thư mục webapps của Tomcat
# hoặc cấu hình context docBase trỏ trực tiếp đến target/GroupASM-1.0-SNAPSHOT
```

Truy cập ứng dụng tại: `http://localhost:8080/GroupASM`

### 5. Triển khai Tự động bằng Docker (Tùy chọn Nâng cao)
Hệ thống đã được cấu hình sẵn **Multi-stage Dockerfile** và **Docker Compose**. Nếu máy đã cài Docker Desktop, bạn có thể khởi chạy toàn bộ Web Server và SQL Server chỉ với 1 câu lệnh duy nhất:
```bash
docker compose up -d --build
```
- Web App sẽ tự động chạy tại: `http://localhost:8080`
- CSDL SQL Server 2022 tự động khởi tạo và kết nối qua mạng nội bộ Docker.
- Để dừng hệ thống: `docker compose down`

---

## 🔑 Tài khoản Kiểm thử Dựng sẵn (Demo Accounts)

Tất cả các tài khoản thử nghiệm bên dưới đều sử dụng **Mật khẩu chung**: `Ftech@123`

| Vai trò | Email đăng nhập | Tên người dùng | Mục đích kiểm thử |
| :--- | :--- | :--- | :--- |
| **Quản trị viên** | `admin@learnora.test` | Nguyễn Quản Trị | Quản trị toàn hệ thống, duyệt khóa học, xuất Excel, kiểm duyệt |
| **Giảng viên 1** | `instructor@learnora.test` | TS. Trần Minh Khoa | Quản lý khóa học Java/SQL, Studio doanh thu, giải đáp bình luận |
| **Giảng viên 2** | `instructor2@learnora.test` | ThS. Đặng Lan Anh | Giảng viên khóa học Frontend & SaaS UI/UX |
| **Học viên 1** | `student@learnora.test` | Lê Hoàng Nam | Đã ghi danh các khóa học chính, kiểm tra phòng học & thảo luận |
| **Học viên 2** | `student2@learnora.test` | Phạm Thị Mai | Tài khoản học viên mới, kiểm thử giỏ hàng & mua khóa học |

---

## 🏫 Thông tin Project Môn học
- **Cơ sở đào tạo**: Trường Đại học FPT - Phân hiệu Cần Thơ
- **Môn học**: Lập trình Web với Java (PRJ301 / PRJ Project)
- **Học kỳ / Năm học**: Fall 2026

Mọi đóng góp và thắc mắc xin vui lòng liên hệ nhóm tác giả qua GitHub Repository.
