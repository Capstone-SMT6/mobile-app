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

    // 1. Determine active training days to ensure proper rest
    final List<String> activeDays = [];
    final tDays = trainingDays.clamp(1, 7);
    if (tDays == 1) activeDays.add('rabu');
    else if (tDays == 2) activeDays.addAll(['selasa', 'jumat']);
    else if (tDays == 3) activeDays.addAll(['senin', 'rabu', 'jumat']);
    else if (tDays == 4) activeDays.addAll(['senin', 'selasa', 'kamis', 'jumat']);
    else if (tDays == 5) activeDays.addAll(['senin', 'selasa', 'kamis', 'jumat', 'sabtu']);
    else if (tDays == 6) activeDays.addAll(['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu']);
    else activeDays.addAll(dayNames); // 7 days

    // 2. Define exercise pool
    final pushUp = {'name': 'Push Up', 'sets': 3, 'reps': 12, 'muscleGroup': 'Punggung, Bahu, Triceps', 'poseAngle': 'side', 'exerciseType': 'pushup'};
    final squat = {'name': 'Squat', 'sets': 3, 'reps': 15, 'muscleGroup': 'Kaki, Bokong', 'poseAngle': 'front', 'exerciseType': 'squat'};
    final plank = {'name': 'Plank', 'sets': 3, 'reps': 30, 'muscleGroup': 'Inti, Perut', 'poseAngle': 'side', 'exerciseType': 'plank'};
    final sitUp = {'name': 'Sit Up', 'sets': 3, 'reps': 15, 'muscleGroup': 'Perut, Inti', 'poseAngle': 'side', 'exerciseType': 'situp'};
    final jumpingJack = {'name': 'Jumping Jack', 'sets': 3, 'reps': 20, 'muscleGroup': 'Full Body, Kardio', 'poseAngle': 'front', 'exerciseType': 'jumping_jack'};
    final highKnee = {'name': 'High Knee', 'sets': 3, 'reps': 20, 'muscleGroup': 'Inti, Kardio', 'poseAngle': 'front', 'exerciseType': 'high_knee'};
    final shoulderPress = {'name': 'Shoulder Press', 'sets': 3, 'reps': 10, 'muscleGroup': 'Bahu, Triceps', 'poseAngle': 'front', 'exerciseType': 'shoulder_press'};

    // Fixed typo in squat declaration

    // 3. Create Split Routines based on Goal
    List<List<Map<String, dynamic>>> routines = [];
    if (isWeightLoss) {
      routines = [
        [jumpingJack, highKnee, plank], // Cardio & Core Focus
        [pushUp, jumpingJack, sitUp],   // Upper & Cardio
        [squat, highKnee, plank],       // Lower & Cardio
        [pushUp, squat, jumpingJack],   // Full Body HIIT
      ];
    } else if (isMuscleGain) {
      routines = [
        [pushUp, shoulderPress, plank], // Upper Body Strength
        [squat, sitUp, highKnee],       // Lower Body & Core
        [pushUp, squat, shoulderPress], // Full Body Power
      ];
    } else {
      routines = [
        [pushUp, plank, sitUp],         // Upper & Core
        [squat, jumpingJack, highKnee], // Lower & Cardio
        [pushUp, squat, shoulderPress], // Full Body
      ];
    }

    // 4. Distribute routines across active days
    int routineIndex = 0;
    
    // Intensity Multiplier
    final intensityMultiplier = intensity.toLowerCase() == 'berat' || intensity.toLowerCase() == 'heavy' ? 1.3 :
        intensity.toLowerCase() == 'ringan' || intensity.toLowerCase() == 'light' ? 0.7 : 1.0;

    for (final dayName in dayNames) {
      if (activeDays.contains(dayName)) {
        final dayExercises = <Map<String, dynamic>>[];
        final selectedRoutine = routines[routineIndex % routines.length];
        
        for (final ex in selectedRoutine) {
          final modifiedEx = Map<String, dynamic>.from(ex);
          // Scale reps and sets
          modifiedEx['sets'] = max(2, ((modifiedEx['sets'] as int) * intensityMultiplier).round());
          modifiedEx['reps'] = max(5, ((modifiedEx['reps'] as int) * intensityMultiplier).round());
          dayExercises.add(modifiedEx);
        }
        
        plans[dayName] = dayExercises;
        routineIndex++;
      } else {
        // Rest Day
        plans[dayName] = [];
      }
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
