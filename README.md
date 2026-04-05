# Capstone Mobile App (Flutter)

This is the front-end application built with Flutter.

## 🛠️ Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- Android Studio or Xcode (for emulator/build tools)

## 🚀 Getting Started

1. **Install Dependencies**
   Run the following command to download all necessary Flutter packages:
   ```bash
   flutter pub get
   ```

2. **Setup Sensitive Credentials**
   For security reasons, Firebase/Google API keys are **not** committed to version control. Request these files from a project maintainer and place them exactly here:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart`

3. **Run the Application**
   For local development, the app connects to `127.0.0.1:8000` by default.

   If you are running on a physical device or Android Emulator, `127.0.0.1` will point to the device itself. You need to pass your machine's IP address (or `10.0.2.2` for Android Emulator) via `--dart-define`:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://YOUR_WIFI_IP_ADDRESS:8000
   ```
   *Tip: You can set this up permanently in your IDE's run configuration.*

## 📁 Project Structure
- `/lib/auth` - Authentication UI (Login / Register), secure token management, and Google Sign-in logic
- `/lib/chat` - RAG Chatbot UI utilizing the Gemini/ChromaDB backend integration
- `/lib/pages` - Generic, reusable template pages (Beranda, Laporan, Profil)
- `/lib/config.dart` - Central app configuration (URLs, API keys)
