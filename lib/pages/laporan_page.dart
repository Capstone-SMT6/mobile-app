import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'workout_list_page.dart';

const _bg = Color(0xFF0D0F14);
const _green = Color(0xFF6CC551);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF8B92A5);
const _gold = Color(0xFFF59E0B);

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<UserController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          "Progress",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final stats = c.stats.value;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              _heroSection(stats),

              const SizedBox(height: 24),
              _insightCard(),

              const SizedBox(height: 20),
              _focusCard(),

              const SizedBox(height: 24),
              _personalBest(stats),

              const SizedBox(height: 24),
              _weeklyChart(),

              const SizedBox(height: 24),

              _goals(),

              const SizedBox(height: 32),
            ],
          );
        }),
      ),
    );
  }

  Widget _heroSection(stats) {
    final streak = stats?.currentStreak ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  streak > 0 ? Icons.local_fire_department : Icons.eco,
                  size: 16,
                  color: streak > 0 ? Colors.orangeAccent : Colors.greenAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  streak > 0 ? '$streak Day Streak' : 'Mulai streak kamu hari ini',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text("Siap untuk latihan hari ini?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _bg,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Get.to(() => const WorkoutListPage());
              },
              child: const Text("Mulai Latihan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _insightCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.lightbulb, color: _gold, size: 22),
              SizedBox(width: 8),
              Text("Wawasan AI",
                  style: TextStyle(
                      color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Form push-up Anda meningkat 15% minggu ini.\n"
            "Tetapi kedalaman squat Anda masih di bawah target.",
            style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _focusCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.center_focus_strong, color: Colors.orangeAccent, size: 22),
              SizedBox(width: 8),
              Text("Fokus Hari Ini",
                  style: TextStyle(
                      color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Text("• Tingkatkan kedalaman squat", style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5)),
          Text("• Perlambat tempo", style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _personalBest(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("REKOR PRIBADI",
            style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Row(
          children: [
            _pb("Push Ups", "${stats?.totalPushUps ?? 0}", _purple),
            const SizedBox(width: 16),
            _pb("Sit Ups", "${stats?.totalSitUps ?? 0}", _green),
          ],
        )
      ],
    );
  }

  Widget _pb(String title, String value, Color color, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: _textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: _textSecondary, fontSize: 11))],
          ],
        ),
      ),
    );
  }

  // WEEKLY
  Widget _weeklyChart() {
    final vals = [0.6, 0.3, 0.85, 0.4, 0.95, 0.5, 0.2];
    final days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AKTIVITAS MINGGUAN",
            style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(vals.length, (i) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 16,
                    height: 100 * vals[i],
                    decoration: BoxDecoration(
                      color: vals[i] > 0.8 ? _green : _purple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i],
                      style: const TextStyle(color: _textSecondary, fontSize: 12))
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // GOALS
  Widget _goals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TARGET BULANAN",
            style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _card(
          child: Column(
            children: [
              _progress("Konsistensi", 0.6),
              const SizedBox(height: 20),
              _progress("Kekuatan", 0.3),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _progress(String label, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
            Text("${(val * 100).toInt()}%", style: const TextStyle(color: _green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            color: _green,
            backgroundColor: _bg,
          ),
        )
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: child,
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: const Color(0xFF222434),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white10),
    );
  }
}
