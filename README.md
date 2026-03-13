# WordMaster Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-ISC-green.svg)](LICENSE)

##  Tổng quan

WordMaster là ứng dụng di động học tiếng Anh toàn diện được phát triển bằng Flutter, cung cấp trải nghiệm học tập cá nhân hóa với các tính năng tiên tiến như học từ vựng, luyện nghe, shadowing, dictation và quiz tương tác.
## Screenshots
Register screen
<img width="383" height="838" alt="image" src="https://github.com/user-attachments/assets/c82d6a19-31ce-45d8-a73a-077d3eb04426" />
Login screen
<img width="406" height="877" alt="image" src="https://github.com/user-attachments/assets/b97795e6-6016-476c-8cd5-5d1205feee92" />
Index screen
<img width="398" height="866" alt="image" src="https://github.com/user-attachments/assets/5f6bfde3-c1e0-456e-92d2-9a52949393e9" />
Profile screen
<img width="404" height="869" alt="image" src="https://github.com/user-attachments/assets/50727e17-3551-42a9-9825-b8c749fef9d3" />
Flashcard screen
<img width="268" height="600" alt="image" src="https://github.com/user-attachments/assets/169f5b78-f711-4f0a-b902-82b2c9303ffc" />
Shadowing screen
<img width="376" height="857" alt="image" src="https://github.com/user-attachments/assets/73c15a01-3f3d-4664-93c0-1505fa916f0a" />
Dictation screen
<img width="266" height="600" alt="image" src="https://github.com/user-attachments/assets/6c051498-2e9f-4e48-bb1c-fce45f2a6787" />





##  Tính năng chính

###  Xác thực và Quản lý Tài khoản
- Đăng nhập/đăng ký với email và mật khẩu
- Đăng nhập bằng Google
- Quản lý hồ sơ cá nhân
- Đồng bộ dữ liệu trên nhiều thiết bị

###  Học Từ vựng
- Flashcards tương tác với hình ảnh và phát âm
- Học theo chủ đề và cấp độ
- Theo dõi tiến độ học tập
- Ôn tập thông minh với spaced repetition

###  Luyện Nghe và Phát âm
- Bài học nghe với transcript chi tiết
- Text-to-Speech (TTS) cho phát âm chuẩn
- Ghi âm và so sánh phát âm của người dùng
- Phân tích độ chính xác phát âm

###  Shadowing Exercises
- Lặp lại sau audio mẫu
- Hỗ trợ nhiều tốc độ phát lại
- Ghi âm và tự đánh giá
- Theo dõi cải thiện theo thời gian

###  Dictation Practice
- Viết chính tả theo audio
- Kiểm tra tự động với gợi ý
- Thống kê độ chính xác
- Bài tập theo cấp độ

###  Quiz và Kiểm tra
- Câu hỏi trắc nghiệm đa dạng
- Bài tập điền khuyết và viết
- Chế độ thi thử
- Báo cáo chi tiết kết quả

###  Thông báo và Nhắc nhở
- Nhắc nhở học tập hàng ngày
- Thông báo thành tích
- Cập nhật bài học mới



## Công nghệ sử dụng

### Framework & Language
- **Flutter**: Framework đa nền tảng cho mobile
- **Dart**: Ngôn ngữ lập trình chính

### State Management
- **Provider**: Quản lý trạng thái ứng dụng
- **GetX**: State management và routing

### Authentication & Backend
- **Firebase Core**: Nền tảng Firebase
- **Firebase Auth**: Xác thực người dùng
- **Google Sign In**: Đăng nhập Google

### Database & Storage
- **SQLite (sqflite)**: Cơ sở dữ liệu cục bộ
- **MySQL**: Cơ sở dữ liệu từ xa
- **Shared Preferences**: Lưu trữ dữ liệu đơn giản

### Audio & Media
- **Flutter TTS**: Text-to-Speech
- **Audioplayers**: Phát audio
- **Just Audio**: Audio player nâng cao
- **Record**: Ghi âm

### Networking
- **Dio**: HTTP client mạnh mẽ
- **HTTP**: HTTP requests cơ bản

### Utilities
- **Intl**: Định dạng ngày tháng và số
- **Path Provider**: Quản lý đường dẫn file
- **Flutter DotEnv**: Biến môi trường
- **Awesome Notifications**: Thông báo push

##  Cài đặt và Chạy

### Yêu cầu hệ thống
- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio hoặc VS Code
- Thiết bị Android/iOS hoặc emulator

### Các bước cài đặt

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd wordmaster_dacn
   ```

2. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

3. **Cấu hình Firebase**
   - Tạo project trên Firebase Console
   - Thêm file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
   - Cấu hình Authentication providers

4. **Cấu hình biến môi trường**
   - Tạo file `.env` trong thư mục root
   - Thêm các biến cần thiết (API keys, database config)

5. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

### Build cho production
```bash
# Android APK
flutter build apk --release

# iOS (trên macOS)
flutter build ios --release
```

##  Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── bindings/                 # Dependency injection
├── config/                   # App configuration
├── controllers/              # Business logic controllers
├── core/                     # Core utilities
├── data/                     # Data models and repositories
├── modules/                  # Feature modules
├── providers/                # State providers
├── screens/                  # UI screens
├── services/                 # API services
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
```

## 🔧 Cấu hình

### Firebase Setup
1. Tạo Firebase project
2. Enable Authentication với Email/Password và Google
3. Thêm app Android/iOS vào project
4. Download config files và đặt vào `android/app/` và `ios/Runner/`

### Environment Variables
Tạo file `.env`:
```
API_BASE_URL=https://your-backend-url.com
FIREBASE_API_KEY=your_firebase_key
GOOGLE_CLIENT_ID=your_google_client_id
```

##  Testing

```bash
# Chạy unit tests
flutter test

# Chạy integration tests
flutter test integration_test/
```

##  Build & Deploy

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

##  Đóng góp

1. Fork project
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

##  License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

##  Tác giả

- **Phạm Thị Ái Ngân** - 
- **Đặng Thanh Toàn**

##  Lời cảm ơn

- Flutter team for the amazing framework
- Firebase for backend services
- Open source community for various packages
