import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:smacofit/app/core/config/app_config.dart';
import 'package:smacofit/app/data/services/auth_service.dart';

/// Service for generating training plans and fitness calculations.
class PlanService {
  static final PlanService _instance = PlanService._();
  factory PlanService() => _instance;
  PlanService._();

  // ── BMR / TDEE (Mifflin-St Jeor) ─────────────────────────────

  static double calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    final isMale = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'laki-laki';
    if (isMale) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  static double calculateTDEE(double bmr, String intensity) {
    switch (intensity.toLowerCase()) {
      case 'ringan':
      case 'light':
        return bmr * 1.375;
      case 'sedang':
      case 'moderate':
        return bmr * 1.55;
      case 'berat':
      case 'heavy':
        return bmr * 1.725;
      case 'sangat_berat':
      case 'athlete':
        return bmr * 1.9;
      default:
        return bmr * 1.55; // default moderate
    }
  }

  // ── Rule-based weekly plan generation ─────────────────────────

  static Map<String, List<Map<String, dynamic>>> generateWeeklyPlan({
    required String goal,
    required String skillLevel,
    required String intensity,
    required int trainingDays,
  }) {
    final isWeightLoss = goal.toLowerCase().contains('turun') ||
        goal.toLowerCase().contains('lose') ||
        goal.toLowerCase().contains('weight loss');
    final isMuscleGain = goal.toLowerCase().contains('otot') ||
        goal.toLowerCase().contains('muscle') ||
        goal.toLowerCase().contains('gain');

    final plans = <String, List<Map<String, dynamic>>>{};
    final dayNames = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];

    // Base exercises by goal
    final baseExercises = <Map<String, dynamic>>[];
    if (isWeightLoss) {
      baseExercises.addAll([
        {'name': 'Push Up', 'sets': 3, 'reps': 12, 'muscleGroup': 'Punggung, Bahu, Triceps', 'poseAngle': 'side', 'exerciseType': 'pushup'},
        {'name': 'Squat', 'sets': 3, 'reps': 15, 'muscleGroup': 'Kaki, Bokong', 'poseAngle': 'front', 'exerciseType': 'squat'},
        {'name': 'Mountain Climber', 'sets': 3, 'reps': 20, 'muscleGroup': 'Inti, Kardio', 'poseAngle': 'front', 'exerciseType': 'mountain_climber'},
        {'name': 'Burpee', 'sets': 3, 'reps': 10, 'muscleGroup': 'Full Body, Kardio', 'poseAngle': 'side', 'exerciseType': 'burpee'},
      ]);
    } else if (isMuscleGain) {
      baseExercises.addAll([
        {'name': 'Push Up', 'sets': 4, 'reps': 10, 'muscleGroup': 'Punggung, Bahu, Triceps', 'poseAngle': 'side', 'exerciseType': 'pushup'},
        {'name': 'Squat', 'sets': 4, 'reps': 12, 'muscleGroup': 'Kaki, Bokong', 'poseAngle': 'front', 'exerciseType': 'squat'},
        {'name': 'Lunge', 'sets': 3, 'reps': 10, 'muscleGroup': 'Kaki, Bokong', 'poseAngle': 'side', 'exerciseType': 'lunge'},
        {'name': 'Plank', 'sets': 3, 'reps': 45, 'muscleGroup': 'Inti, Perut', 'poseAngle': 'side', 'exerciseType': 'plank'},
      ]);
    } else {
      baseExercises.addAll([
        {'name': 'Push Up', 'sets': 3, 'reps': 12, 'muscleGroup': 'Punggung, Bahu, Triceps', 'poseAngle': 'side', 'exerciseType': 'pushup'},
        {'name': 'Sit Up', 'sets': 3, 'reps': 15, 'muscleGroup': 'Perut, Inti', 'poseAngle': 'side', 'exerciseType': 'situp'},
        {'name': 'Squat', 'sets': 3, 'reps': 15, 'muscleGroup': 'Kaki, Bokong', 'poseAngle': 'front', 'exerciseType': 'squat'},
        {'name': 'Plank', 'sets': 3, 'reps': 30, 'muscleGroup': 'Inti, Perut', 'poseAngle': 'side', 'exerciseType': 'plank'},
      ]);
    }

    // Distribute across training days (alternating)
    final shuffled = List<Map<String, dynamic>>.from(baseExercises)..shuffle(Random(42));
    for (int i = 0; i < trainingDays; i++) {
      final dayName = dayNames[i];
      final dayExercises = <Map<String, dynamic>>[];
      // Pick 3-4 exercises per day
      final count = min(4, shuffled.length);
      for (int j = 0; j < count; j++) {
        dayExercises.add(Map<String, dynamic>.from(shuffled[(i + j) % shuffled.length]));
      }
      // Adjust sets/reps based on intensity
      final intensityMultiplier = intensity.toLowerCase() == 'berat' || intensity.toLowerCase() == 'heavy' ? 1.3 :
          intensity.toLowerCase() == 'ringan' || intensity.toLowerCase() == 'light' ? 0.7 : 1.0;
      for (final ex in dayExercises) {
        ex['sets'] = max(2, (ex['sets'] * intensityMultiplier).round());
        ex['reps'] = max(5, (ex['reps'] * intensityMultiplier).round());
      }
      plans[dayName] = dayExercises;
    }

    return plans;
  }

  // ── API: Generate and save plan to backend ────────────────────

  static Future<Map<String, dynamic>?> generatePlan() async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.post(
        Uri.parse(AppConfig.generatePlanEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── API: Get active plan ──────────────────────────────────────

  static Future<Map<String, dynamic>?> getActivePlan() async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse(AppConfig.meExercisePlanEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── API: Get analytics summary ─────────────────────────────────

  static Future<Map<String, dynamic>?> getAnalyticsSummary() async {
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse(AppConfig.analyticsSummaryEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
