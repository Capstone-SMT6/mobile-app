import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Data class for workout summary.
class WorkoutSummaryData {
  final int totalExercises;
  final int totalSets;
  final int totalReps;
  final Duration duration;
  final double avgQuality; // 0-100
  final int currentStreak;
  final List<ExerciseResult> exercises;

  const WorkoutSummaryData({
    required this.totalExercises,
    required this.totalSets,
    required this.totalReps,
    required this.duration,
    required this.avgQuality,
    required this.currentStreak,
    required this.exercises,
  });
}

class ExerciseResult {
  final String name;
  final int sets;
  final int reps;
  final String muscleGroup;

  const ExerciseResult({
    required this.name,
    required this.sets,
    required this.reps,
    required this.muscleGroup,
  });
}

/// Full-screen workout completion summary.
class WorkoutSummaryPage extends StatefulWidget {
  final WorkoutSummaryData data;

  const WorkoutSummaryPage({super.key, required this.data});

  @override
  State<WorkoutSummaryPage> createState() => _WorkoutSummaryPageState();
}

class _WorkoutSummaryPageState extends State<WorkoutSummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    _ctrl.forward();

    // Haptic celebration
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.mediumImpact());
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.lightImpact());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final minutes = d.duration.inMinutes;
    final seconds = d.duration.inSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Hero section ─────────────────────────────
              Expanded(
                flex: 2,
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6CC551).withValues(alpha: 0.3),
                                const Color(0xFF6CC551).withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF6CC551).withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFF6CC551),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Workout Selesai!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Latihan hari ini tercatat. Mantap!',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stats section ────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Main stats row
                      Row(
                        children: [
                          _SummaryStat(
                            icon: Icons.fitness_center,
                            value: '${d.totalExercises}',
                            label: 'Latihan',
                            color: const Color(0xFF7C6AF7),
                          ),
                          const SizedBox(width: 12),
                          _SummaryStat(
                            icon: Icons.repeat,
                            value: '${d.totalReps}',
                            label: 'Total Reps',
                            color: const Color(0xFFAB47BC),
                          ),
                          const SizedBox(width: 12),
                          _SummaryStat(
                            icon: Icons.timer,
                            value: '${minutes}m ${seconds}s',
                            label: 'Durasi',
                            color: const Color(0xFF29B6F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SummaryStat(
                            icon: Icons.layers,
                            value: '${d.totalSets}',
                            label: 'Total Sets',
                            color: const Color(0xFFFFA726),
                          ),
                          const SizedBox(width: 12),
                          _SummaryStat(
                            icon: Icons.stars_rounded,
                            value: '${d.avgQuality.round()}%',
                            label: 'Form Quality',
                            color: d.avgQuality >= 80
                                ? const Color(0xFF6CC551)
                                : d.avgQuality >= 50
                                    ? const Color(0xFFFFA726)
                                    : const Color(0xFFF76A6A),
                          ),
                          const SizedBox(width: 12),
                          _SummaryStat(
                            icon: Icons.local_fire_department,
                            value: '${d.currentStreak}',
                            label: 'Streak',
                            color: const Color(0xFFF76A6A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Exercise breakdown
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161824),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RINGKASAN LATIHAN',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: d.exercises.length,
                                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 16),
                                  itemBuilder: (_, i) {
                                    final ex = d.exercises[i];
                                    return Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7C6AF7).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${i + 1}',
                                              style: const TextStyle(
                                                color: Color(0xFF7C6AF7),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ex.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                ex.muscleGroup,
                                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${ex.sets}×${ex.reps}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── Action buttons ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop all the way back to workout list
                      Get.until((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CC551),
                      foregroundColor: const Color(0xFF0A0C10),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161824),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
