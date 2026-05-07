import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'calendar_page.dart';
import 'workout_list_page.dart';
import 'analysis_page.dart';

class BerandaPage extends StatelessWidget {
  final ColorScheme? colorScheme;
  const BerandaPage({super.key, this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderSection(),
              SizedBox(height: 32),
              ProgressCard(),
              SizedBox(height: 32),
              TodayMenu(),
              SizedBox(height: 32),
              WorkoutAnalysis(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// HEADER  — Sapa user dengan nama & greeting waktu
// ───────────────────────────────────────────────────────────────
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Obx(() {
            final username = userCtrl.user.value?.username ?? 'User';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Let's crush some weight today",
                  style: TextStyle(
                    color: const Color(0xFF6CC551).withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            _buildIconButton(
              Icons.calendar_month_rounded,
              onTap: () => Get.to(() => const CalendarPage()),
            ),
            const SizedBox(width: 12),
            _buildIconButton(Icons.notifications_none_rounded),
          ],
        )
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF222434),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// PROGRESS CARD  — Streak & progress dari UserController
// ───────────────────────────────────────────────────────────────
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    return Obx(() {
      final stats = userCtrl.stats.value;
      final streak = stats?.currentStreak ?? 0;
      final longestStreak = stats?.longestStreak ?? 7;

      // Progress = streak saat ini / target streak terpanjang (max 100%)
      final double progress = longestStreak > 0
          ? (streak / longestStreak).clamp(0.0, 1.0)
          : 0.0;
      final int progressPct = (progress * 100).round();

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF222434), Color(0xFF171925)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF6CC551).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6CC551).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6CC551),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$progressPct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tampilkan streak nyata
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day streak',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Let's continue what we started!",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Get.to(() => const WorkoutListPage()),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CC551),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(
                            color: Color(0xFF101216),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

// ───────────────────────────────────────────────────────────────
// TODAY MENU  — Menu latihan hari ini (bisa dikembangkan ke API)
// ───────────────────────────────────────────────────────────────
class TodayMenu extends StatelessWidget {
  const TodayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    // Daftar latihan berdasarkan goal user
    return Obx(() {
      final goal = userCtrl.fitnessProfile.value?.goal ?? 'default';
      final menuItems = _getMenuByGoal(goal);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Workout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const WorkoutListPage()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "See more",
                  style: TextStyle(
                    color: Color(0xFF6CC551),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...menuItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMenuItem(item[0], item[1], item[2] as IconData),
              )),
        ],
      );
    });
  }

  // Sesuaikan menu berdasarkan goal dari fitness profile
  List<List<dynamic>> _getMenuByGoal(String goal) {
    switch (goal) {
      case 'weight_loss':
        return [
          ['Jumping Jacks', '3 Set X 30 Rep', Icons.directions_run],
          ['Burpees', '3 Set X 10 Rep', Icons.fitness_center],
          ['Plank', '3 Set X 1 Min', Icons.accessibility_new],
        ];
      case 'muscle_gain':
        return [
          ['Push Up', 'Rep 20 X 5', Icons.fitness_center],
          ['Pull Up', 'Rep 10 X 3', Icons.sports_gymnastics],
          ['Squat', 'Rep 15 X 4', Icons.accessibility_new],
        ];
      default:
        return [
          ['Push Up', 'Rep 20 X 5', Icons.fitness_center],
          ['Pull Up', 'Rep 10 X 3', Icons.sports_gymnastics],
          ['Plank', '1 Min X 3', Icons.accessibility_new],
        ];
    }
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF222434),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6CC551).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6CC551), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// WORKOUT ANALYSIS BANNER
// ───────────────────────────────────────────────────────────────
class WorkoutAnalysis extends StatelessWidget {
  const WorkoutAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const AnalysisPage()),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C6AF7), Color(0xFF5A49D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6AF7).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Workouts Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Check your daily progress",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
