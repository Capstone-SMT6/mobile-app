import 'package:flutter/material.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final bool notificationEnabled;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.notificationEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
        notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: User parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }
}

class UserStats {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalPushUps;
  final int totalSitUps;
  final DateTime? lastActiveDate;

  UserStats({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPushUps,
    required this.totalSitUps,
    this.lastActiveDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    try {
      return UserStats(
        id: json['id'] as String,
        userId: (json['user_id'] ?? json['userId']) as String,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        totalPushUps: json['totalPushUps'] as int? ?? 0,
        totalSitUps: json['totalSitUps'] as int? ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.tryParse(json['lastActiveDate'])
            : null,
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: UserStats parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }
}

class UserFitnessProfile {
  final String id;
  final String userId;
  final String goal;
  final String durationTarget;
  final int age;
  final double height;
  final double weight;
  final String skillLevel;
  final String intensity;
  final double? bmr;
  final double? tdee;
  final double? targetDailyKcal;
  final Map<String, dynamic>? macrosJson;

  UserFitnessProfile({
    required this.id,
    required this.userId,
    required this.goal,
    required this.durationTarget,
    required this.age,
    required this.height,
    required this.weight,
    required this.skillLevel,
    required this.intensity,
    this.bmr,
    this.tdee,
    this.targetDailyKcal,
    this.macrosJson,
  });

  factory UserFitnessProfile.fromJson(Map<String, dynamic> json) {
    try {
      final finalUserId = (json['user_id'] ?? json['userId']) as String;
      final finalDurationTarget = (json['durationTarget'] ?? json['duration_target'] ?? '') as String;
      final finalSkillLevel = (json['skillLevel'] ?? json['skill_level'] ?? '') as String;
      final finalIntensity = (json['intensity'] ?? '') as String;
      
      final rawBmr = json['bmr'];
      final rawTdee = json['tdee'];
      final rawTargetKcal = json['target_daily_kcal'] ?? json['targetDailyKcal'];
      final rawMacros = json['macros_json'] ?? json['macrosJson'];

      return UserFitnessProfile(
        id: json['id'] as String,
        userId: finalUserId,
        goal: json['goal'] as String,
        durationTarget: finalDurationTarget,
        age: json['age'] as int,
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
        skillLevel: finalSkillLevel,
        intensity: finalIntensity,
        bmr: rawBmr != null ? (rawBmr as num).toDouble() : null,
        tdee: rawTdee != null ? (rawTdee as num).toDouble() : null,
        targetDailyKcal: rawTargetKcal != null ? (rawTargetKcal as num).toDouble() : null,
        macrosJson: rawMacros as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: UserFitnessProfile parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }

  double get bmi {
    if (height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiStatus {
    final val = bmi;
    if (val < 18.5) return 'Kurus';
    if (val < 25.0) return 'Normal';
    if (val < 30.0) return 'Kelebihan';
    return 'Obesitas';
  }
  int get carbGrams => ((macrosJson?['carbs_g'] ?? macrosJson?['carbs_grams'] ?? macrosJson?['carbsG'] ?? 0) as num).toInt();
  int get proteinGrams => ((macrosJson?['protein_g'] ?? macrosJson?['protein_grams'] ?? macrosJson?['proteinG'] ?? 0) as num).toInt();
  int get fatGrams => ((macrosJson?['fat_g'] ?? macrosJson?['fat_grams'] ?? macrosJson?['fatG'] ?? 0) as num).toInt();
  String get goalFormatted {
    switch (goal) {
      case 'weight_loss': return 'Weight Loss';
      case 'muscle_gain': return 'Muscle Gain';
      case 'maintain': return 'Maintain Weight';
      case 'menurunkan_berat_badan': return 'Menurunkan Berat Badan';
      case 'menaikkan_berat_badan': return 'Menaikkan Berat Badan';
      case 'menjaga_kebugaran': return 'Menjaga Kebugaran';
      case 'membentuk_otot': return 'Membentuk Otot';
      default: return goal;
    }
  }
}

class InsightsModel {
  final String wawasanAi;
  final List<String> fokusHariIni;

  InsightsModel({required this.wawasanAi, required this.fokusHariIni});

  factory InsightsModel.fromJson(Map<String, dynamic> json) {
    return InsightsModel(
      wawasanAi: json['wawasan_ai'] as String? ?? 'Terus pertahankan konsistensi latihan Anda!',
      fokusHariIni: (json['fokus_hari_ini'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class DashboardReport {
  final InsightsModel insights;
  final List<double> weeklyActivity;
  final Map<String, double> goalsProgress;

  DashboardReport({
    required this.insights,
    required this.weeklyActivity,
    required this.goalsProgress,
  });

  factory DashboardReport.fromJson(Map<String, dynamic> json) {
    return DashboardReport(
      insights: InsightsModel.fromJson(json['insights'] ?? {}),
      weeklyActivity: (json['weekly_activity'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      goalsProgress: (json['goals_progress'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
    );
  }
}
