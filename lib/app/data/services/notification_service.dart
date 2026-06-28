import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/routes/app_routes.dart';
import 'package:smacofit/app/data/services/user_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('========================================================');
  debugPrint('[BACKGROUND FCM MESSAGE RECEIVED]');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('========================================================');
}

/// Singleton notification service for workout reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionGranted = false;

  // Channel configs
  static const _workoutChannelId = 'workout_reminders';
  static const _workoutChannelName = 'Pengingat Latihan';
  static const _streakChannelId = 'streak_milestones';
  static const _streakChannelName = 'Pencapaian Streak';

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      _permissionGranted = true;
      debugPrint('NotificationService: Initialized in web fallback mode.');
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initialized = await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
        _instance._navigateToHome();
      },
    );

    _initialized = initialized ?? false;

    // Request permission on Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _permissionGranted = granted ?? false;
    } else {
      _permissionGranted = true; // iOS handles via settings
    }

    // Create notification channels
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _workoutChannelId,
        _workoutChannelName,
        description: 'Pengingat jadwal latihan harian',
        importance: Importance.high,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _streakChannelId,
        _streakChannelName,
        description: 'Notifikasi pencapaian streak latihan',
        importance: Importance.defaultImportance,
      ),
    );
  }

  /// Schedule daily workout reminders on specified training days.
  Future<void> scheduleWorkoutReminders({
    required int hour,
    required int minute,
    required List<int> trainingDays,
    String title = 'Waktunya Latihan! 💪',
    String body = 'Jangan lewatkan sesi latihan hari ini. Yuk mulai!',
  }) async {
    if (kIsWeb || !_initialized || !_permissionGranted) return;

    await cancelWorkoutReminders();

    for (final day in trainingDays) {
      await _plugin.zonedSchedule(
        100 + day,
        title,
        body,
        _nextInstanceOfDay(day, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _workoutChannelId,
            _workoutChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'workout_reminder',
      );
    }
  }

  /// Schedule rest day motivation notifications.
  Future<void> scheduleRestDayMotivation({
    required List<int> trainingDays,
    int hour = 9,
    int minute = 0,
  }) async {
    if (kIsWeb || !_initialized || !_permissionGranted) return;

    // Find rest days (1=Mon ... 7=Sun that are NOT training days)
    final allDays = {1, 2, 3, 4, 5, 6, 7};
    final restDays = allDays.difference(trainingDays.toSet());

    for (final day in restDays) {
      await _plugin.zonedSchedule(
        200 + day,
        'Hari Istirahat 🌿',
        'Nikmati hari pemulihanmu. Tubuhmu sedang membangun otot!',
        _nextInstanceOfDay(day, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _workoutChannelId,
            _workoutChannelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'rest_day',
      );
    }
  }

  /// Show a streak milestone notification.
  Future<void> showStreakMilestone(int streakDays) async {
    if (kIsWeb || !_initialized || !_permissionGranted) return;

    String title;
    String body;

    if (streakDays == 7) {
      title = '🔥 Streak 7 Hari!';
      body = 'Satu minggu berturut-turut! Konsistensi adalah kuncinya.';
    } else if (streakDays == 14) {
      title = '💎 Streak 14 Hari!';
      body = 'Dua minggu non-stop! Kamu luar biasa!';
    } else if (streakDays == 30) {
      title = '👑 Streak 30 Hari!';
      body = 'Sebulan penuh! Dedikasimu menginspirasi!';
    } else if (streakDays == 100) {
      title = '🏆 Streak 100 Hari!';
      body = '100 hari berturut-turut! Kamu seorang legenda!';
    } else {
      return; // Only show milestones
    }

    await _plugin.show(
      streakDays,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _streakChannelId,
          _streakChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'streak_$streakDays',
    );
  }

  /// Cancel all scheduled workout reminders.
  Future<void> cancelWorkoutReminders() async {
    if (kIsWeb || !_initialized) return;
    for (int i = 1; i <= 7; i++) {
      await _plugin.cancel(100 + i);
    }
  }

  /// Cancel all notifications (workout + rest day).
  Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }

  /// Calculate the next occurrence of a given day of week.
  tz.TZDateTime _nextInstanceOfDay(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to the target day of week (1=Mon, 7=Sun)
    while (scheduled.weekday != dayOfWeek || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Initialize Firebase Cloud Messaging (FCM)
  Future<void> initFcm() async {
    if (!_initialized) {
      await init();
    }

    try {
      final messaging = FirebaseMessaging.instance;

      // Request FCM permissions
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('User granted FCM permission: ${settings.authorizationStatus}');

      // Get initial FCM token and upload to backend
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _uploadFcmToken(token);
      }

      // Listen for token refresh and upload
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token Refreshed: $newToken');
        await _uploadFcmToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('========================================================');
        debugPrint('[FOREGROUND FCM MESSAGE RECEIVED]');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
        debugPrint('========================================================');
        _showForegroundNotification(message);
      });

      // Handle notification tapped/clicked (when app is in background/foreground)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM message tapped (app in background/foreground): ${message.messageId}');
        _navigateToHome();
      });

      // Handle notification tapped/clicked (when app is opened from terminated state)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated FCM message: ${initialMessage.messageId}');
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToHome();
        });
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  Future<void> _uploadFcmToken(String token) async {
    try {
      await UserService.updateFcmToken(token);
      debugPrint('FCM Token successfully uploaded to backend.');
    } catch (e) {
      debugPrint('Error uploading FCM Token: $e');
    }
  }

  void _navigateToHome() {
    try {
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('Error navigating to home: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (kIsWeb) {
      debugPrint('========================================================');
      debugPrint('[WEB NOTIFICATION FALLBACK LOG]');
      debugPrint('Title: ${notification?.title}');
      debugPrint('Body: ${notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('========================================================');
      return;
    }
    
    if (notification != null) {
      await _plugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _workoutChannelId,
            _workoutChannelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'fcm_notification',
      );
    }
  }
}

