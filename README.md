# 🏋️‍♂️ AI Fitness Capstone Mobile App

Aplikasi mobile fitness cerdas berbasis **Flutter** yang dilengkapi dengan teknologi **AI Pose Detection** (Pendeteksi Pose Cerdas). Aplikasi ini dirancang untuk memandu pengguna dalam melakukan latihan fisik dengan benar melalui analisis gerakan secara *real-time*, kalibrasi cerdas, sesi latihan terstruktur, dan asisten chatbot.

---

## ✨ Fitur Utama

- **🤖 AI Pose Detection & Analysis**: Menggunakan `google_mlkit_pose_detection` dan `tflite_flutter` untuk mendeteksi, melacak, dan menganalisis postur tubuh pengguna secara *real-time* melalui kamera.
- **🎯 Smart Calibration**: Fitur kalibrasi untuk memastikan jarak dan pencahayaan optimal sebelum pengguna memulai sesi latihan (`calibration_page.dart`).
- **📅 Pelacakan Latihan & Kalender**: Melacak riwayat latihan harian dan menampilkannya secara interaktif menggunakan kalender dan grafik (`calendar_page.dart` & `laporan_page.dart`).
- **💬 AI Chatbot Assistant**: Chatbot terintegrasi yang berfungsi sebagai asisten kebugaran pintar (`chatbot_page.dart`).
- **🏃‍♂️ Sesi Workout & Warmup**: Alur terstruktur untuk pemanasan dan eksekusi latihan fisik (`workout_session_page.dart` & `warmup_page.dart`).
- **🔐 Firebase Authentication**: Login dan registrasi yang aman, mendukung otentikasi Google Sign-In (`firebase_auth` & `google_sign_in`).
- **📊 Laporan & Analitik**: Visualisasi progres latihan pengguna dengan grafik komprehensif.

---

## 🛠️ Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Machine Learning / AI**:
  - `google_mlkit_pose_detection`
  - `tflite_flutter`
- **Backend & Authentication**: Firebase Core, Firebase Auth, Secure Storage.
- **UI & Sensor Components**: 
  - `camera` & `video_player` (Untuk sesi pose-camera)
  - `fl_chart` (Untuk grafik analitik)
  - `table_calendar` (Untuk riwayat latihan)
  - `sensors_plus` (Akses sensor perangkat)
  - `body_part_selector` (UI pemilih bagian tubuh interaktif)

---

## 📂 Struktur Proyek

Proyek ini menggunakan pola arsitektur berbasis fitur / modul dengan GetX.

```text
lib/
├── auth/          # Logika autentikasi dan layanan login (Google Sign-In)
├── bindings/      # Dependency injection untuk GetX Controllers
├── controllers/   # GetX Controllers (State Management untuk kamera, sesi, dll)
├── models/        # Representasi data (Data models)
├── pages/         # Tampilan UI (Screens/Pages)
│   ├── analysis_page.dart      # Halaman analisis pose
│   ├── beranda_page.dart       # Beranda / Dashboard aplikasi
│   ├── calibration_page.dart   # Kamera kalibrasi AI
│   ├── chatbot_page.dart       # UI Chatbot
│   ├── pose_camera_page.dart   # Kamera deteksi pose inti
│   ├── workout_session_page.dart # Layar utama sesi olahraga
│   └── ...
├── routes/        # Definisi rute aplikasi (GetX Routing)
├── services/      # Komunikasi dengan API external / layanan backend
├── utils/         # Fungsi utilitas, konstanta, dan helper
├── config.dart    # Konfigurasi aplikasi (API Base URLs)
└── main.dart      # Entry point aplikasi Flutter
```

---

## 🚀 Persyaratan Sistem

- [Flutter SDK](https://docs.flutter.dev/get-started/install) terinstal di sistem Anda.
- **Android Studio** (untuk emulator dan Android toolchain) atau **Xcode** (untuk iOS).
- Perangkat fisik sangat disarankan untuk pengujian kamera dan deteksi pose secara optimal.

---

## 💻 Cara Instalasi & Menjalankan Aplikasi

1. **Clone Repositori & Masuk ke Direktori**
   Pastikan Anda berada di dalam folder `mobile-app`.

2. **Unduh Dependensi**
   Jalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   ```

3. **Pengaturan Kredensial Sensitif (Firebase)**
   Demi keamanan, *API keys* tidak dimasukkan ke dalam version control. Anda perlu meminta file berikut kepada maintainer proyek dan meletakkannya di lokasi yang tepat:
   - File `google-services.json` diletakkan di `android/app/google-services.json`
   - File `firebase_options.dart` diletakkan di `lib/firebase_options.dart`

4. **Menjalankan Aplikasi (Development)**
   Aplikasi membutuhkan koneksi ke backend lokal atau server API. Gunakan flag `--dart-define` untuk menyuntikkan base URL ke dalam aplikasi.
   
   Jika menggunakan Emulator Android (backend di localhost komputer):
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```
   
   Jika menggunakan Perangkat Fisik (sambungkan dalam satu jaringan WiFi):
   ```bash
   flutter run --dart-define=API_BASE_URL=http://<IP_WIFI_KOMPUTER_ANDA>:8000
   ```
   *Tip: Konfigurasi flag `--dart-define` ini dapat disimpan secara permanen di Run/Debug Configurations pada IDE (VS Code / Android Studio).*

---

## 📝 Catatan Tambahan Pengembangan
- **Performa Kamera AI**: Proses *Pose Detection* menggunakan ML Kit dapat memakan daya komputasi yang tinggi. Pengujian di atas perangkat keras (HP fisik) jauh lebih akurat dan stabil dibandingkan dengan emulator, dan disarankan untuk mengetes frame-rate deteksi.
- **State Management**: Karena aplikasi menggunakan **GetX**, pastikan setiap *Controller* telah di-*binding* secara tepat di dalam direktori `routes/` atau `bindings/` agar tidak terjadi *memory leak* selama pindah halaman.
