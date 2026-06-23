import 'package:smacofit/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/data/services/workout_service.dart';
import 'package:smacofit/app/modules/workout/views/warmup_view.dart';
import 'package:smacofit/app/modules/auth/controllers/user_controller.dart';

class WorkoutListView extends StatefulWidget {
  const WorkoutListView({super.key});

  @override
  State<WorkoutListView> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListView> {
  late final Future<ActiveExercisePlan> _planFuture;
  List<WorkoutExercise> _todayPlan = [];

  static WorkoutExercise _toWorkoutExercise(ExerciseTarget e) {
    final key = e.name.toLowerCase().trim().replaceAll('-', ' ');
    // Only the 4 exercises the app's pose detector supports
    const info = {
      'push up': ('Jaga punggung lurus, turun perlahan dan terkontrol.', 'Punggung · Bahu · Triceps', 'side', 'pushup'),
      'sit up':  ('Angkat badan sampai siku menyentuh lutut, jaga leher netral.', 'Perut · Inti · Fleksor Pinggul', 'side', 'situp'),
      'squat':   ('Turun sampai paha sejajar lantai, lutut tidak melewati jari kaki.', 'Kaki · Bokong · Paha Depan', 'side', 'squat'),
      'plank':   ('Tahan posisi tubuh lurus selama waktu yang ditentukan.', 'Inti · Punggung Bawah', 'side', 'plank'),
    };
    final (desc, muscle, angle, type) = info[key] ?? ('Ikuti gerakan dengan benar.', 'Seluruh Tubuh', 'side', 'other');
    return WorkoutExercise(
      name: e.name,
      description: desc,
      sets: e.sets,
      reps: e.reps ?? e.targetDurationSeconds ?? 30,
      muscleGroup: muscle,
      poseAngle: angle,
      exerciseType: type,
    );
  }

  @override
  void initState() {
    super.initState();
    _planFuture = WorkoutService.getActiveExercisePlan();
  }

  void _showDetailBottomSheet(ExerciseTarget item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                _statChip(Icons.repeat, '${item.sets} sets'),
                const SizedBox(width: 12),
                if (item.reps != null)
                  _statChip(Icons.fitness_center, '${item.reps} reps'),
                if (item.targetDurationSeconds != null)
                  _statChip(Icons.timer, '${item.targetDurationSeconds}s'),
                const SizedBox(width: 12),
                _statChip(
                  Icons.pause_circle_outline,
                  '${item.restSeconds}s rest',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentGreen, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Latihan Hari Ini",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ActiveExercisePlan>(
        future: _planFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentGreen),
            );
          }

          // Error
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Belum ada rencana latihan.',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            );
          }

          final exercises = snapshot.data!.exercisesForDate(DateTime.now());

          // Map to WorkoutExercise for the session (done once after build)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (exercises.isNotEmpty && mounted) {
              setState(() => _todayPlan = exercises.map(_toWorkoutExercise).toList());
            }
          });

          // Rest day
          if (exercises.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Hari ini adalah hari istirahat 🎉',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final item = exercises[index];

              return GestureDetector(
                onTap: () => _showDetailBottomSheet(item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF6CC551,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: accentGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.targetText,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white38,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: accentGreen.withValues(alpha: 0.4),
              ),
              onPressed: _todayPlan.isEmpty
                  ? null
                  : () {
                      final userStats = Get.isRegistered<UserController>()
                          ? UserController.to.stats.value
                          : null;
                      
                      final today = DateTime.now();
                      final isDoneToday = userStats?.lastActiveDate != null &&
                          userStats!.lastActiveDate!.year == today.year &&
                          userStats.lastActiveDate!.month == today.month &&
                          userStats.lastActiveDate!.day == today.day;

                      void startWorkout() {
                        Get.to(
                          () => WarmupView(workoutPlan: _todayPlan),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );
                      }

                      if (isDoneToday) {
                        Get.defaultDialog(
                          title: "Sudah Selesai!",
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                          middleText: "Anda sudah menyelesaikan sesi harian hari ini. Ingin mengulangi latihannya?",
                          textConfirm: "Ulangi Latihan",
                          textCancel: "Batal",
                          confirmTextColor: Colors.black,
                          buttonColor: accentGreen,
                          cancelTextColor: Colors.white,
                          backgroundColor: surfaceColor,
                          onConfirm: () {
                            Get.back(); // tutup dialog
                            startWorkout();
                          },
                        );
                      } else {
                        startWorkout();
                      }
                    },
              child: const Text(
                "Mulai Latihan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
