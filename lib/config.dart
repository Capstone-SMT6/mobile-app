class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Backend API
  // ---------------------------------------------------------------------------

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  static String get usersEndpoint => '$apiBaseUrl/api/users/';
  static String get loginEndpoint => '$apiBaseUrl/api/users/login';
  static String get googleLoginEndpoint => '$apiBaseUrl/api/users/google-login';
  static String get refreshEndpoint => '$apiBaseUrl/api/users/refresh';
  static String get meEndpoint => '$apiBaseUrl/api/users/me';
  static String get meStatsEndpoint => '$apiBaseUrl/api/users/me/stats';
  static String get meFitnessProfileEndpoint => '$apiBaseUrl/api/users/me/fitness-profile';
  static String get chatbotSessionsEndpoint => '$apiBaseUrl/chatbot/sessions';
  static String chatbotChatEndpoint(String sessionId) => '$apiBaseUrl/chatbot/sessions/$sessionId/chat';
  static String chatbotStreamEndpoint(String sessionId) => '$apiBaseUrl/chatbot/sessions/$sessionId/stream';

  // ---------------------------------------------------------------------------
  // Workout Plans & Analytics
  // ---------------------------------------------------------------------------

  static String get generatePlanEndpoint => '$apiBaseUrl/api/workouts/generate-plan';
  static String get activePlanEndpoint => '$apiBaseUrl/api/workouts/active-plan';
  static String get analyticsSummaryEndpoint => '$apiBaseUrl/api/workouts/analytics/summary';
  static String get analyticsWeeklyEndpoint => '$apiBaseUrl/api/workouts/analytics/weekly';
  static String analyticsCalendarEndpoint(int year, int month) =>
      '$apiBaseUrl/api/workouts/analytics/calendar?year=$year&month=$month';
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
