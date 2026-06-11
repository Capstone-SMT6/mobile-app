import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for scheduling local workout reminder notifications.
class NotificationService {
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionGranted = false;

  /// Initialize the notification plugin. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // Set default timezone to local
    final local = tz.local;
    tz.setLocalLocation(local);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      _permissionGranted = await androidPlugin?.requestNotificationsPermission() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      _permissionGranted = await iosPlugin?.requestPermissions(
        alert: true, badge: true, sound: true,
      ) ?? false;
    }

    _initialized = true;
    debugPrint('NotificationService initialized. Permission: $_permissionGranted');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Could navigate to specific page based on payload
  }

  bool get isPermissionGranted => _permissionGranted;

  // ── Notification Channels ────────────────────────────────────

  static const _workoutChannel = AndroidNotificationDetails(
    'workout_reminder',
    'Workout Reminders',
    description: 'Daily workout reminder notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFF7C6AF7),
  );

  static const _streakChannel = AndroidNotificationDetails(
    'streak_milestone',
    'Streak Milestones',
    description: 'Streak achievement notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFF6CC551),
  );

  static const _motivationChannel = AndroidNotificationDetails(
    'motivation',
    'Motivational',
    description: 'Rest day motivational notifications',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFFFA726),
  );

  // ── Workout Reminder ─────────────────────────────────────────

  /// Schedule a daily workout reminder at [hour]:[minute].
  /// Only schedules on training days (based on dayOfWeek: 1=Mon..7=Sun).
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    required List<int> trainingDays, // 1=Monday..7=Sunday
    String title = 'Waktunya Latihan! 💪',
    String body = 'Jangan lewatkan sesi latihan hari ini. Yuk mulai!',
  }) async {
    if (!_initialized || !_permissionGranted) return;

    // Cancel existing reminders first
    await cancelWorkoutReminders();

    for (final day in trainingDays) {
      await _plugin.zonedSchedule(
        100 + day, // unique ID per day
        title,
        body,
        _nextInstanceOfDay(day, hour, minute),
        const NotificationDetails(
          android: _workoutChannel,
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents(dayOfWeek: day, time: Time(hour, minute)),
        payload: 'workout_reminder',
      );
    }

    debugPrint('Scheduled workout reminders for days: $trainingDays at $hour:$minute');
  }

  /// Schedule a rest day motivational notification.
  Future<void> scheduleRestDayMotivation({
    required int hour,
    required int minute,
    required List<int> restDays,
  }) async {
    if (!_initialized || !_permissionGranted) return;

    const messages = [
      'Istirahat itu penting! Ototmu butuh recovery 🌟',
      'Rest day = Growth day! Nikmati waktu istirahatmu 💤',
      'Tubuhmu sedang membangun otot. Tetap semangat! 🔥',
      'Recovery yang baik = performa yang lebih baik besok! 💪',
    ];

    for (int i = 0; i < restDays.length; i++) {
      final day = restDays[i];
      await _plugin.zonedSchedule(
        200 + day,
        'Hari Istirahat 😴',
        messages[i % messages.length],
        _nextInstanceOfDay(day, hour, minute),
        const NotificationDetails(
          android: _motivationChannel,
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents(dayOfWeek: day, time: Time(hour, minute)),
        payload: 'rest_day',
      );
    }
  }

  // ── Streak Milestone Notifications ───────────────────────────

  /// Show immediate notification for streak milestones.
  Future<void> showStreakMilestone(int streakDays) async {
    if (!_initialized || !_permissionGranted) return;

    String title;
    String body;
    if (streakDays >= 30) {
      title = '🏆 30 Hari Berturut-turut!';
      body = 'LUAR BIASA! Kamu sudah latihan 30 hari non-stop. Kamu adalah legenda!';
    } else if (streakDays >= 14) {
      title = '🥈 14 Hari Streak!';
      body = 'Dua minggu penuh konsistensi! Kebiasaan baik sudah terbentuk.';
    } else if (streakDays >= 7) {
      title = '🥉 7 Hari Streak!';
      body = 'Seminggu penuh! Terus pertahankan momentum ini.';
    } else {
      return; // Not a milestone
    }

    await _plugin.show(
      300 + streakDays,
      title,
      body,
      const NotificationDetails(
        android: _streakChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'streak_$streakDays',
    );
  }

  // ── Show a simple immediate notification ─────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || !_permissionGranted) return;

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: _workoutChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // ── Cancel / Clear ───────────────────────────────────────────

  /// Cancel all workout reminder schedules (IDs 100-199).
  Future<void> cancelWorkoutReminders() async {
    if (!_initialized) return;
    for (int i = 100; i < 200; i++) {
      await _plugin.cancel(i);
    }
    for (int i = 200; i < 210; i++) {
      await _plugin.cancel(i);
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  // ── Helpers ──────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfDay(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Calculate next occurrence of dayOfWeek (1=Mon..7=Sun)
    final currentDay = now.weekday; // 1=Mon..7=Sun
    var daysAhead = dayOfWeek - currentDay;
    if (daysAhead < 0 || (daysAhead == 0 && scheduled.isBefore(now))) {
      daysAhead += 7;
    }
    scheduled = scheduled.add(Duration(days: daysAhead));
    return scheduled;
  }
}
