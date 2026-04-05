class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Backend API
  // ---------------------------------------------------------------------------

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  static String get usersEndpoint => '$apiBaseUrl/api/users';
  static String get loginEndpoint => '$apiBaseUrl/api/users/login';
  static String get googleLoginEndpoint => '$apiBaseUrl/api/users/google-login';
  static String get chatbotSessionsEndpoint => '$apiBaseUrl/chatbot/sessions';
  static String chatbotChatEndpoint(int sessionId) => '$apiBaseUrl/chatbot/sessions/$sessionId/chat';
  static String chatbotStreamEndpoint(int sessionId) => '$apiBaseUrl/chatbot/sessions/$sessionId/stream';
  // ---------------------------------------------------------------------------
  // Google OAuth
  // ---------------------------------------------------------------------------

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '662953376779-q1038hnqlq12sinrrc6ip1e9hsmubd0j.apps.googleusercontent.com',
  );

  // ---------------------------------------------------------------------------
  // Firebase
  // ---------------------------------------------------------------------------

  static const String firebaseProjectId = 'capstone-smt6';
}
