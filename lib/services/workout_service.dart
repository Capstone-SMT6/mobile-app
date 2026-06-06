import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class ExerciseTarget {
  final String name;
  final int sets;
  final int? reps;
  final int? targetDurationSeconds;
  final int restSeconds;

  ExerciseTarget({
    required this.name,
    required this.sets,
    required this.reps,
    required this.targetDurationSeconds,
    required this.restSeconds,
  });

  factory ExerciseTarget.fromJson(Map<String, dynamic> json) {
    return ExerciseTarget(
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int?,
      targetDurationSeconds: json['target_duration_seconds'] as int?,
      restSeconds: json['rest_seconds'] as int,
    );
  }

  String get targetText {
    if (targetDurationSeconds != null) {
      return '$sets set x $targetDurationSeconds detik';
    }
    return '$sets set x $reps rep';
  }
}

class PlanDaySchedule {
  final int dayOfWeek;
  final bool isRestDay;
  final List<ExerciseTarget> exercises;

  PlanDaySchedule({
    required this.dayOfWeek,
    required this.isRestDay,
    required this.exercises,
  });

  factory PlanDaySchedule.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List<dynamic>? ?? [])
        .map((item) => ExerciseTarget.fromJson(item as Map<String, dynamic>))
        .toList();

    return PlanDaySchedule(
      dayOfWeek: json['day_of_week'] as int,
      isRestDay: json['is_rest_day'] as bool,
      exercises: exercises,
    );
  }
}

class ActiveExercisePlan {
  final String id;
  final String goal;
  final int daysPerWeek;
  final String difficultyLevel;
  final List<PlanDaySchedule> days;

  ActiveExercisePlan({
    required this.id,
    required this.goal,
    required this.daysPerWeek,
    required this.difficultyLevel,
    required this.days,
  });

  factory ActiveExercisePlan.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>? ?? [])
        .map((item) => PlanDaySchedule.fromJson(item as Map<String, dynamic>))
        .toList();

    return ActiveExercisePlan(
      id: json['id'] as String,
      goal: json['goal'] as String,
      daysPerWeek: json['days_per_week'] as int,
      difficultyLevel: json['difficulty_level'] as String,
      days: days,
    );
  }

  List<ExerciseTarget> exercisesForDate(DateTime date) {
    final dayIndex = date.weekday - 1;
    for (final day in days) {
      if (day.dayOfWeek == dayIndex) return day.exercises;
    }
    return [];
  }
}

class WorkoutService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Simpan sesi latihan ke backend, return streak terbaru
  static Future<Map<String, dynamic>> saveSession({
    int durationSeconds = 0,
    List<Map<String, dynamic>> logs = const [],
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'duration_seconds': durationSeconds,
      'logs': logs,
    });

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/workouts/sessions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to save workout session: ${response.statusCode}');
    }
  }

  /// Ambil semua sesi latihan (untuk kalender)
  static Future<List<DateTime>> getSessionDates() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/workouts/sessions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((s) => DateTime.parse(s['date'] as String)).toList();
    } else {
      throw Exception('Failed to fetch sessions: ${response.statusCode}');
    }
  }

  static Future<ActiveExercisePlan> getActiveExercisePlan() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.meExercisePlanEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ActiveExercisePlan.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to fetch exercise plan: ${response.statusCode}');
    }
  }
}
