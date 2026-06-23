import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'workout_reminders';
  static const String channelName = 'Workout Reminders';
  static const String channelDesc = 'Daily notifications to remind you to workout';

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    // Assuming local timezone is detected, but setting to default simple setup
    // In a real app, you might use flutter_timezone to get local timezone
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Defaulting to Jakarta as it's common for Indonesia

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );
  }

  Future<bool> requestPermissions() async {
    bool? granted;
    if (Platform.isAndroid) {
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    return granted ?? false;
  }

  Future<void> scheduleDailyReminder() async {
    // We schedule it for 08:00 AM every day
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 8, 0); // 08:00 AM
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF6CC551), // Accent Green
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Waktunya Bergerak! \uD83C\uDFC3\u200D\u2642\uFE0F',
      'Jangan sampai Streak kamu putus! Selesaikan latihan harianmu sekarang.',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
    );
    
    debugPrint('Daily reminder scheduled for $scheduledDate');
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    debugPrint('Daily reminder cancelled');
  }

  // A quick test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Test Notifikasi',
      'Jika kamu melihat ini, fitur notifikasi bekerja dengan baik!',
      platformChannelSpecifics,
    );
  }
}
