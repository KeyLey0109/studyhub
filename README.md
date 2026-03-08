# StudyHub – Social Learning App 📚

Ứng dụng mạng xã hội học tập giống Facebook, xây dựng bằng Flutter + Clean Architecture.

---

## 🚀 Cách cài đặt và chạy

### 1. Tạo project Flutter
```bash
flutter create studyhub
cd studyhub
```

### 2. Thay thế toàn bộ nội dung thư mục `lib/` bằng code này

### 3. Thay file `pubspec.yaml` bằng file đính kèm

### 4. Tạo thư mục assets
```bash
mkdir -p assets/images assets/icons
```

### 5. Cài dependencies
```bash
flutter pub get
```

### 6. Chạy app
```bash
flutter run
```

---

## 📁 Cấu trúc project (Clean Architecture)

```
lib/
├── core/
│   ├── router/          # GoRouter navigation
│   ├── theme/           # AppTheme (màu Facebook)
│   └── utils/           # Locale, helpers
│
├── domain/
│   ├── entities/        # UserEntity, PostEntity, NotificationEntity
│   ├── repositories/    # Abstract interfaces
│   └── usecases/        # Auth, Post, Friend use cases
│
├── data/
│   ├── datasources/
│   │   ├── local/       # Hive offline storage
│   │   └── remote/      # FakeRemoteDatasource (giả lập API)
│   └── repositories/    # Repository implementations
│
├── presentation/
│   ├── blocs/           # AuthBloc, PostBloc, FriendBloc, NotificationBloc
│   ├── pages/           # Tất cả màn hình
│   └── widgets/         # Reusable widgets
│
├── injection_container.dart   # GetIt DI
└── main.dart
```

---

## ✨ Chức năng

### 🔐 Authentication
- Đăng nhập bằng Email hoặc SĐT
- Đăng ký tài khoản mới
- Quên mật khẩu
- Tự động đăng nhập (persistent session)

### 📰 Bảng tin (Home)
- Xem feed bài viết
- Pull to refresh
- Infinite scroll pagination
- Tạo bài viết (text + ảnh/video placeholder)

### 👥 Bạn bè (Friends)
- **Tab Lời mời**: nhận và chấp nhận/từ chối lời mời
- **Tab Gợi ý**: xem và gửi lời mời kết bạn
- **Tab Bạn bè**: danh sách bạn bè

### 🔔 Thông báo
- Thông báo lời mời kết bạn
- Thông báo chấp nhận kết bạn
- Thông báo like bài viết
- Thông báo bình luận
- Badge số chưa đọc trên bottom nav

### 👤 Profile
- Xem trang cá nhân
- Thêm bạn / Chấp nhận lời mời từ trang profile
- Xem bài viết của người dùng

### 💬 Post & Comment
- Tạo bài viết
- Like / Unlike bài viết
- Bình luận bài viết

---

## 🛠 Kỹ thuật

| Kỹ thuật | Thư viện |
|----------|----------|
| State Management | flutter_bloc ^8.1.3 |
| Navigation | go_router ^12.1.1 |
| DI | get_it ^7.6.7 |
| Local Cache | hive + hive_flutter |
| Architecture | Clean Architecture |

---

## 📝 Ghi chú

- **Dữ liệu được lưu offline** bằng Hive – không cần server
- **FakeRemoteDatasource** giả lập API call (có delay 400ms thực tế)
- Mật khẩu được lưu local (demo – không dùng trong production)
- Thêm tài khoản test bằng cách đăng ký nhiều account khác nhau
- Sau đó đăng nhập tài khoản này và gửi lời mời, đăng nhập tài khoản kia để nhận

---

## 🧪 Để test kết bạn

1. Đăng ký tài khoản **A** (vd: `a@test.com` / `123456`)
2. Đăng xuất
3. Đăng ký tài khoản **B** (vd: `b@test.com` / `123456`)
4. Vào **Bạn bè → Gợi ý** → Thêm bạn A
5. Đăng xuất
6. Đăng nhập lại tài khoản **A**
7. Vào **Thông báo** → thấy lời mời kết bạn từ B
8. Vào **Bạn bè → Lời mời** → Chấp nhận kết bạn
