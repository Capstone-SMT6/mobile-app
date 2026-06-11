import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/plan_service.dart';
import 'warmup_page.dart';

class WorkoutListPage extends StatefulWidget {
  const WorkoutListPage({super.key});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  Map<String, dynamic>? _activePlan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    try {
      final plan = await PlanService.getActivePlan();
      if (mounted) {
        setState(() {
          _activePlan = plan;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  /// Get today's exercises from the active plan
  List<WorkoutExercise> _getTodaysExercises() {
    if (_activePlan == null) return defaultWorkoutPlan;

    final days = _activePlan!['days'] as List<dynamic>? ?? [];
    // Today's day of week: DateTime weekday is 1=Mon..7=Sun, API uses 0=Mon..6=Sun
    final todayDow = DateTime.now().weekday - 1;

    final todayDay = days.firstWhere(
      (d) => d['day_of_week'] == todayDow,
      orElse: () => null,
    );

    if (todayDay == null || todayDay['is_rest_day'] == true) {
      return []; // Rest day
    }

    final exercises = todayDay['exercises'] as List<dynamic>? ?? [];
    if (exercises.isEmpty) return defaultWorkoutPlan;

    return exercises.map((e) {
      final muscleGroups = (e['muscleGroups'] as List<dynamic>?)
              ?.map((m) => m.toString())
              .join(' · ') ?? '';
      return WorkoutExercise(
        name: e['name'] as String? ?? 'Exercise',
        description: e['description'] as String? ?? '',
        sets: e['target_sets'] as int? ?? 3,
        reps: (e['target_duration_seconds'] != null)
            ? e['target_duration_seconds'] as int
            : (e['target_reps'] as int? ?? 12),
        muscleGroup: muscleGroups,
        poseAngle: e['poseAngle'] as String? ?? 'side',
        exerciseType: e['exerciseType'] as String? ?? 'other',
      );
    }).toList();
  }

  /// Generate a new plan if none exists
  Future<void> _generatePlan() async {
    setState(() => _loading = true);
    try {
      await PlanService.generatePlan();
      await _loadPlan();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to generate plan. Complete onboarding first.',
          backgroundColor: const Color(0xFF222434),
          colorText: Colors.white,
        );
      }
    }
  }

  // Menampilkan modal dari bawah (BottomSheet) menggunakan GetX
  // Menampilkan modal dari bawah (BottomSheet) menggunakan GetX
  void _showDetailBottomSheet(Map<String, String> item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF171925),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan tinggi dengan konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar (garis abu-abu kecil di atas)
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            Text(
              item["title"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // GIF Animation
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222434),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  item["gif"]!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white38,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text(
              "Instruction",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item["desc"]!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24), // Spasi bawah ekstra
          ],
        ),
      ),
      isScrollControlled: true, // Memungkinkan BottomSheet untuk tampil optimal jika layarnya kecil
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Workout Plan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            tooltip: 'Generate new plan',
            onPressed: _generatePlan,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6CC551)))
          : _error != null && _activePlan == null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CC551),
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF6CC551).withOpacity(0.4),
              ),
              onPressed: () {
                final exercises = _getTodaysExercises();
                if (exercises.isEmpty) {
                  Get.snackbar(
                    'Rest Day',
                    'Today is a rest day. Take it easy!',
                    backgroundColor: const Color(0xFF222434),
                    colorText: Colors.white,
                  );
                  return;
                }
                Get.to(
                  () => WarmupPage(workoutPlan: exercises),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              child: Text(
                _getTodaysExercises().isEmpty
                    ? "Rest Day - No Workout"
                    : "Start Today's Workout",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No workout plan found',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete onboarding or generate a new plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CC551),
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Generate Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final todayExercises = _getTodaysExercises();
    final isRestDay = todayExercises.isEmpty;
    final planInfo = _activePlan?['plan'] as Map<String, dynamic>?;
    final goalLabel = planInfo?['goal']?.toString().replaceAll('_', ' ') ?? '';
    final daysPerWeek = planInfo?['days_per_week'] ?? 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Plan info card
        if (planInfo != null)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C6AF7), Color(0xFF5A49D3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Active Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$daysPerWeek days/week • ${planInfo?['difficulty_level'] ?? 'beginner'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

        // Rest day notice
        if (isRestDay)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Icon(Icons.self_improvement, size: 48, color: Color(0xFF7C6AF7)),
                SizedBox(height: 12),
                Text(
                  'Rest Day',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Recovery is an essential part of training.\nTake it easy today!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

        // Today's exercises header
        if (!isRestDay)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "TODAY'S EXERCISES",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

        // Today's exercises list
        if (!isRestDay)
          ...todayExercises.asMap().entries.map((entry) {
            final i = entry.key;
            final ex = entry.value;
            return GestureDetector(
              onTap: () => _showDetailBottomSheet({
                'title': ex.name,
                'gif': '',
                'desc': ex.description,
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF222434),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CC551).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Color(0xFF6CC551),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ex.exerciseType == 'plank'
                                ? '${ex.sets} set × ${ex.reps}s'
                                : '${ex.sets} set × ${ex.reps} reps',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ex.muscleGroup,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 24),
      ],
    );
  }
}
