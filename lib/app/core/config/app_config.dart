class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Backend API
  // ---------------------------------------------------------------------------

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://justparadis-smafit-fastapi.hf.space',
    defaultValue: 'http://localhost:8000',
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
      '$apiBaseUrl/api/workouts/analytics/summary';
  static String get analyticsWeeklyEndpoint =>
      '$apiBaseUrl/api/workouts/analytics/weekly';
  static String get analyticsCalendarEndpoint =>
      '$apiBaseUrl/api/workouts/analytics/calendar';

  static String get nutritionFoodsEndpoint => '$apiBaseUrl/api/nutrition/foods';
  static String get nutritionLogEndpoint => '$apiBaseUrl/api/nutrition/log';
  static String get nutritionLogTodayEndpoint => '$apiBaseUrl/api/nutrition/log/today';
  static String nutritionLogDateEndpoint(String date) => '$apiBaseUrl/api/nutrition/log/$date';
  static String nutritionSummaryDayEndpoint(String date) => '$apiBaseUrl/api/nutrition/summary/day/$date';
  static String get nutritionSummaryWeekEndpoint => '$apiBaseUrl/api/nutrition/summary/week';
  static String get nutritionSummaryMonthEndpoint => '$apiBaseUrl/api/nutrition/summary/month';
  static String nutritionFeedbackDayEndpoint(String date) => '$apiBaseUrl/api/nutrition/feedback/day/$date';

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
