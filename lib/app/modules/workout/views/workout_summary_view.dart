import 'package:mobile_app/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Data model for workout completion summary.
class WorkoutSummaryData {
  final int totalExercises;
  final int totalSets;
  final int totalReps;
  final Duration duration;
  final double avgQuality;
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
  final int setsDone;
  final int repsDone;
  final double quality;

  const ExerciseResult({
    required this.name,
    required this.setsDone,
    required this.repsDone,
    required this.quality,
  });
}

class WorkoutSummaryView extends StatelessWidget {
  final WorkoutSummaryData data;

  const WorkoutSummaryView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          child: Column(
            children: [
              // ── Hero section ─────────────────────────────────
              _buildHeroSection(),
              const SizedBox(height: 28),

              // ── Stats grid ───────────────────────────────────
              _buildStatsGrid(),
              const SizedBox(height: 28),

              // ── Exercise breakdown ───────────────────────────
              _buildExerciseBreakdown(),
              const SizedBox(height: 32),

              // ── Done button ──────────────────────────────────
              _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final mins = data.duration.inMinutes;
    final secs = data.duration.inSeconds.remainder(60);
    final timeStr = '${mins}m ${secs.toString().padLeft(2, '0')}s';

    return Column(
      children: [
        // Trophy / congrats icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentGreen.withValues(alpha: 0.3), accentGreen.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accentGreen.withValues(alpha: 0.5), width: 2),
          ),
          child: const Icon(Icons.emoji_events_rounded, color: accentGreen, size: 52),
        ),
        const SizedBox(height: 24),
        const Text(
          'Workout Selesai! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total waktu: $timeStr',
          style: const TextStyle(color: Colors.white54, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statCard(
          icon: Icons.fitness_center_rounded,
          value: '${data.totalExercises}',
          label: 'Latihan',
          color: accentPurple,
        ),
        _statCard(
          icon: Icons.repeat_rounded,
          value: '${data.totalSets}',
          label: 'Set',
          color: const Color(0xFF29B6F6),
        ),
        _statCard(
          icon: Icons.speed_rounded,
          value: '${data.totalReps}',
          label: 'Reps',
          color: const Color(0xFFFFA726),
        ),
        _statCard(
          icon: Icons.star_rounded,
          value: '${data.avgQuality.toStringAsFixed(0)}%',
          label: 'Kualitas',
          color: data.avgQuality >= 80 ? accentGreen : const Color(0xFFF0A500),
        ),
        _statCard(
          icon: Icons.local_fire_department_rounded,
          value: '${data.currentStreak}',
          label: 'Hari Streak',
          color: const Color(0xFFEF5350),
        ),
        _statCard(
          icon: Icons.timer_rounded,
          value: '${data.duration.inMinutes}m',
          label: 'Durasi',
          color: accentGreen,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RINCIAN LATIHAN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...data.exercises.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${e.setsDone} set × ${e.repsDone}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.quality >= 80
                        ? accentGreen.withValues(alpha: 0.15)
                        : const Color(0xFFF0A500).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${e.quality.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: e.quality >= 80 ? accentGreen : const Color(0xFFF0A500),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Pop to home (pop workout stack entirely)
          Get.until((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'Kembali ke Beranda',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
