import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../services/workout_service.dart';
import '../services/trends_service.dart';
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
              TrendingSection(),
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
                    color: const Color(0xFF6CC551).withValues(alpha: 0.9),
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
            color: const Color(0xFF6CC551).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6CC551).withValues(alpha: 0.1),
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
// TODAY MENU  — Fetch latihan hari ini dari active exercise plan
// ───────────────────────────────────────────────────────────────
class TodayMenu extends StatefulWidget {
  const TodayMenu({super.key});

  @override
  State<TodayMenu> createState() => _TodayMenuState();
}

class _TodayMenuState extends State<TodayMenu> {
  late final Future<ActiveExercisePlan> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = WorkoutService.getActiveExercisePlan();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActiveExercisePlan>(
      future: _planFuture,
      builder: (context, snapshot) {
        // Header always visible
        final header = Row(
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
        );

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF6CC551)),
              ),
            ],
          );
        }

        // Error / no plan state
        if (snapshot.hasError || !snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Belum ada rencana latihan.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          );
        }

        final exercises = snapshot.data!.exercisesForDate(DateTime.now());

        // Rest day state
        if (exercises.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF222434),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available, color: Colors.white38, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Hari ini adalah hari istirahat 🎉',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Exercise list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            ...exercises.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMenuItem(e.name, e.targetText),
                )),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String title, String subtitle) {
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
              color: const Color(0xFF6CC551).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: Color(0xFF6CC551), size: 24),
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
              color: const Color(0xFF7C6AF7).withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
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

// ───────────────────────────────────────────────────────────────
// TRENDING SECTION  — Top topics from Big Data (last 90 days)
// ───────────────────────────────────────────────────────────────
class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  late Future<List<TrendItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = TrendsService.fetchTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Topics 🔥',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Most researched fitness topics (last 90 days)',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<TrendItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 110,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6CC551),
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            final items = snap.data!;
            return SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _TrendCard(item: items[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final TrendItem item;
  const _TrendCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final badgeColor = item.rank <= 3 ? rankColors[item.rank - 1] : Colors.white24;

    final views = item.views90d;
    final viewsLabel = views >= 1000000
        ? '${(views / 1000000).toStringAsFixed(1)}M views'
        : '${(views / 1000).toStringAsFixed(0)}K views';

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222434),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${item.rank}',
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          Text(
            item.article,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            viewsLabel,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
