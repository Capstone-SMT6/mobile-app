import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';

const _bg = Color(0xFF0D0F14);
const _surface = Color(0xFF1C2030);
const _border = Color(0xFF2A2F45);
const _green = Color(0xFF4FFFB0);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF6B7280);
const _gold = Color(0xFFF59E0B);
const _silver = Color(0xFF9CA3AF);
const _bronze = Color(0xFFCD7F32);

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LaporanController controller = Get.find<LaporanController>();

    return Container(
      color: _bg,
      child: Column(
        children: [
          // ── Tab bar ─────────────────────────────────────────
          Obx(() => Container(
                color: _surface,
                child: Row(
                  children: [
                    _tabButton(
                      label: 'LEADERBOARD',
                      selected: controller.selectedTab.value == 0,
                      onTap: () => controller.selectTab(0),
                    ),
                    _tabButton(
                      label: 'MY STATS',
                      selected: controller.selectedTab.value == 1,
                      onTap: () => controller.selectTab(1),
                    ),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() => controller.selectedTab.value == 0
                ? _buildLeaderboardTab(controller)
                : _buildMyStatsTab()),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? _green : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? _green : _textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

  // ── Leaderboard Tab ──────────────────────────────────────────
  Widget _buildLeaderboardTab(LaporanController controller) {
    return Column(
      children: [
        // Exercise selector
        Container(
          color: _bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 36,
            child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final sel = controller.selectedExercise.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectExercise(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? _purple : _surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? _purple : _border, width: 1),
                        ),
                        child: Text(
                          controller.exercises[i],
                          style: TextStyle(
                            color: sel ? Colors.white : _textSecondary,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ),

        // Podium (top 3)
        Container(
          color: _bg,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _podiumBlock(controller.topEntries[1], 2, 80),
              const SizedBox(width: 12),
              _podiumBlock(controller.topEntries[0], 1, 100),
              const SizedBox(width: 12),
              _podiumBlock(controller.topEntries[2], 3, 64),
            ],
          ),
        ),

        // Rest of entries
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: controller.topEntries.length - 3,
            itemBuilder: (context, i) =>
                _rankTile(controller.topEntries[i + 3]),
          ),
        ),
      ],
    );
  }

  Widget _podiumBlock(Map<String, dynamic> entry, int rank, double height) {
    final Color accent = rank == 1
        ? _gold
        : rank == 2
            ? _silver
            : _bronze;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent, width: 2),
            ),
            child: Center(
              child: Text(
                (entry['name'] as String)[0],
                style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry['name'],
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '${entry['score']} pts',
            style: TextStyle(color: accent, fontSize: 11),
          ),
          const SizedBox(height: 6),
          // Podium bar
          Container(
            height: height,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankTile(Map<String, dynamic> entry) {
    final bool isYou = entry['you'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isYou ? _purple.withValues(alpha: 0.15) : _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isYou ? _purple.withValues(alpha: 0.5) : _border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry['rank']}',
              style: TextStyle(
                  color: isYou ? _purple : _textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: (isYou ? _purple : _green).withValues(alpha: 0.15),
            child: Text(
              (entry['name'] as String)[0],
              style: TextStyle(
                  color: isYou ? _purple : _green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry['name'],
              style: TextStyle(
                  color: isYou ? _purple : _textPrimary,
                  fontWeight:
                      isYou ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14),
            ),
          ),
          Text(
            '${entry['score']} pts',
            style: TextStyle(
                color: isYou ? _green : _textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── My Stats Tab ─────────────────────────────────────────────
  Widget _buildMyStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Personal bests
          const Text('PERSONAL BESTS',
              style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _pbCard('Bench Press', '90 kg', _purple),
              const SizedBox(width: 12),
              _pbCard('Squat', '120 kg', _green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _pbCard('Deadlift', '140 kg', _gold),
              const SizedBox(width: 12),
              _pbCard('Pull-ups', '20 reps', const Color(0xFFEC4899)),
            ],
          ),

          const SizedBox(height: 28),

          const Text('WEEKLY VOLUME',
              style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _barChart(),

          const SizedBox(height: 28),

          const Text('ACHIEVEMENTS',
              style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(Icons.local_fire_department, '7-Day Streak', _gold),
              _badge(Icons.emoji_events, 'Top 50 Global', _purple),
              _badge(Icons.bolt, 'PR Breaker', _green),
              _badge(Icons.star, 'Consistent', const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pbCard(String label, String value, Color accent) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 11)),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: accent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              const Text('Personal Best',
                  style: TextStyle(
                      color: _textSecondary, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _barChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final vals = [0.6, 0.3, 0.85, 0.4, 0.95, 0.5, 0.2];
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 22,
                    height: 80 * vals[i],
                    decoration: BoxDecoration(
                      color: i == 4
                          ? _green
                          : _purple.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(days[i],
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 10)),
            ],
          );
        }),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
