# AI Fitness Capstone Mobile App

Aplikasi mobile fitness cerdas berbasis Flutter yang dilengkapi dengan teknologi AI Pose Detection (Pendeteksi Pose Cerdas). Aplikasi ini dirancang untuk memandu pengguna dalam melakukan latihan fisik dengan benar melalui analisis gerakan secara *real-time*, kalibrasi presisi, sesi latihan terstruktur, dan asisten virtual (chatbot).

---

## Fitur Utama

- **AI Pose Detection & Analysis**: Menggunakan `google_mlkit_pose_detection` dan `tflite_flutter` untuk mendeteksi, melacak, dan menganalisis postur tubuh pengguna secara *real-time* melalui umpan kamera.
- **Smart Calibration**: Fungsionalitas kalibrasi untuk memastikan jarak dan kondisi pencahayaan optimal sebelum pengguna memulai sesi latihan (`calibration_page.dart`).
- **Pelacakan Latihan & Kalender**: Melacak riwayat latihan harian dan menampilkannya secara interaktif menggunakan komponen kalender dan grafik (`calendar_page.dart` & `laporan_page.dart`).
- **AI Chatbot Assistant**: Sistem chatbot terintegrasi yang berfungsi sebagai asisten kebugaran untuk memberikan informasi dan panduan (`chatbot_page.dart`).
- **Sesi Workout & Warmup**: Alur aplikasi yang terstruktur untuk pemanasan dan eksekusi latihan fisik (`workout_session_page.dart` & `warmup_page.dart`).
- **Firebase Authentication**: Sistem login dan registrasi yang aman, serta mendukung otentikasi Single Sign-On (SSO) melalui Google Sign-In (`firebase_auth` & `google_sign_in`).
- **Laporan & Analitik**: Visualisasi progres latihan pengguna dengan grafik data yang komprehensif.

---

## Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Machine Learning / AI**:
  - `google_mlkit_pose_detection`
  - `tflite_flutter`
- **Backend & Authentication**: Firebase Core, Firebase Auth, Secure Storage.
- **UI & Sensor Components**: 
  - `camera` & `video_player` (Untuk pengelolaan sesi kamera pose)
  - `fl_chart` (Untuk visualisasi analitik)
  - `table_calendar` (Untuk manajemen riwayat kalender)
  - `sensors_plus` (Untuk akses pembacaan sensor perangkat keras)
  - `body_part_selector` (Komponen antarmuka pemilih bagian tubuh)

---

## Struktur Proyek

Proyek ini menggunakan pola arsitektur berbasis fitur (feature-based architecture) dengan integrasi GetX.

```text
lib/
├── auth/          # Logika autentikasi dan layanan login
├── bindings/      # Dependency injection untuk GetX Controllers
├── controllers/   # GetX Controllers (State Management)
├── models/        # Representasi entitas data (Data models)
├── pages/         # Tampilan Antarmuka (UI/Screens)
│   ├── analysis_page.dart      # Modul analisis pose
│   ├── beranda_page.dart       # Dasbor utama aplikasi
│   ├── calibration_page.dart   # Modul kalibrasi AI
│   ├── chatbot_page.dart       # Antarmuka Chatbot
│   ├── pose_camera_page.dart   # Modul deteksi pose inti
│   ├── workout_session_page.dart # Modul utama sesi olahraga
│   └── ...
├── routes/        # Definisi rute navigasi aplikasi
├── services/      # Integrasi API eksternal dan layanan backend
├── utils/         # Fungsi utilitas dan pembantu (helpers)
├── config.dart    # Konfigurasi aplikasi (API Base URLs, dll)
└── main.dart      # Entry point aplikasi Flutter
```

---

## Persyaratan Sistem

- [Flutter SDK](https://docs.flutter.dev/get-started/install) terinstal dan terkonfigurasi.
- **Android Studio** (untuk manajemen Android toolchain/emulator) atau **Xcode** (untuk lingkungan iOS).
- Perangkat fisik sangat direkomendasikan untuk pengujian optimalisasi kamera dan pemrosesan deteksi pose.

---

## Panduan Instalasi dan Penggunaan

1. **Kloning Repositori**
   Pastikan terminal Anda berada di dalam direktori `mobile-app`.

2. **Instalasi Dependensi**
   Jalankan perintah berikut pada terminal:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Kredensial Sensitif**
   Untuk menjaga keamanan, kredensial API tidak disertakan dalam *version control*. Anda perlu menambahkan file konfigurasi berikut yang didapatkan dari maintainer proyek:
   - Tempatkan `google-services.json` di dalam `android/app/google-services.json`
   - Tempatkan `firebase_options.dart` di dalam `lib/firebase_options.dart`

4. **Menjalankan Aplikasi (Lingkungan Development)**
   Aplikasi membutuhkan koneksi ke server backend. Gunakan argumen `--dart-define` untuk menetapkan parameter *Base URL* secara dinamis.
   
   Untuk pengujian menggunakan Emulator Android:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```
   
   Untuk pengujian menggunakan Perangkat Fisik (pastikan berada di jaringan lokal yang sama):
   ```bash
   flutter run --dart-define=API_BASE_URL=http://<IP_ADDRESS_KOMPUTER>:8000
   ```
   *Catatan: Konfigurasi argumen `--dart-define` dapat diatur secara permanen melalui pengaturan Run/Debug Configurations pada IDE Anda.*

---

## Catatan Pengembangan
- **Performa Pemrosesan AI**: Proses *Pose Detection* melalui ML Kit membutuhkan daya komputasi yang signifikan. Pengujian pada perangkat keras fisik (smartphone) memberikan hasil akurasi dan stabilitas yang lebih representatif dibandingkan dengan emulator, khususnya untuk evaluasi *frame-rate*.
- **Manajemen Memori (State Management)**: Mengingat penggunaan **GetX**, pastikan setiap siklus hidup *Controller* dikelola (di-*binding*) dengan benar pada direktori `routes/` atau `bindings/` untuk mencegah terjadinya kebocoran memori (*memory leak*) selama navigasi antar halaman.
