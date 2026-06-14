class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Backend API
  // ---------------------------------------------------------------------------

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://justparadis-smafit-fastapi.hf.space',
    defaultValue: 'https://sonless-vallie-unmercifully.ngrok-free.dev',
  );

  static String get usersEndpoint => '$apiBaseUrl/api/users/';
  static String get loginEndpoint => '$apiBaseUrl/api/users/login';
  static String get googleLoginEndpoint => '$apiBaseUrl/api/users/google-login';
  static String get refreshEndpoint => '$apiBaseUrl/api/users/refresh';
  static String get meEndpoint => '$apiBaseUrl/api/users/me';
  static String get meStatsEndpoint => '$apiBaseUrl/api/users/me/stats';
  static String get meFitnessProfileEndpoint =>
      '$apiBaseUrl/api/users/me/fitness-profile';
  static String get meExercisePlanEndpoint =>
      '$apiBaseUrl/api/users/me/exercise-plan';
  static String get chatbotSessionsEndpoint => '$apiBaseUrl/chatbot/sessions';
  static String chatbotChatEndpoint(String sessionId) =>
      '$apiBaseUrl/chatbot/sessions/$sessionId/chat';
  static String chatbotStreamEndpoint(String sessionId) =>
      '$apiBaseUrl/chatbot/sessions/$sessionId/stream';
  static String get trendingEndpoint => '$apiBaseUrl/api/trends';
  static String get generatePlanEndpoint =>
      '$apiBaseUrl/api/users/me/generate-plan';
  static String get activePlanEndpoint =>
      '$apiBaseUrl/api/users/me/active-plan';
  static String get analyticsSummaryEndpoint =>
      '$apiBaseUrl/api/users/me/analytics/summary';
  static String get analyticsWeeklyEndpoint =>
      '$apiBaseUrl/api/users/me/analytics/weekly';
  static String get analyticsCalendarEndpoint =>
      '$apiBaseUrl/api/users/me/analytics/calendar';
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
