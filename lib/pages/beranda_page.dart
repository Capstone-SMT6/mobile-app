import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';

// ── Design Tokens ──────────────────────────────────────────────
const _bg = Color(0xFF0D0F14);
const _surface = Color(0xFF1C2030);
const _border = Color(0xFF2A2F45);
const _green = Color(0xFF4FFFB0);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF6B7280);
// ───────────────────────────────────────────────────────────────

class BerandaPage extends StatelessWidget {
  final ColorScheme colorScheme;
  const BerandaPage({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final BerandaController controller = Get.find<BerandaController>();

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero stat banner ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1040), Color(0xFF0D0F14)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purple.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TODAY\'S MISSION',
                            style: TextStyle(
                                color: _green,
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Push Day',
                            style: TextStyle(
                                color: _textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        _bannerRow(Icons.local_fire_department_outlined,
                            'Streak: 7 Days 🔥'),
                        const SizedBox(height: 4),
                        _bannerRow(Icons.fitness_center_outlined,
                            'Last workout: 2 days ago'),
                        const SizedBox(height: 4),
                        _bannerRow(
                            Icons.emoji_events_outlined, 'Rank: #42 Global'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _green.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.bolt, color: _green, size: 32),
                        SizedBox(height: 4),
                        Text('2,840',
                            style: TextStyle(
                                color: _green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text('XP',
                            style:
                                TextStyle(color: _textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stat cards row ────────────────────────────────
            Row(
              children: [
                _statCard('1,240', 'kcal', Icons.whatshot_outlined, _purple),
                const SizedBox(width: 12),
                _statCard('5.2 km', 'Distance', Icons.directions_run, _green),
                const SizedBox(width: 12),
                _statCard('48 min', 'Duration',
                    Icons.timer_outlined, const Color(0xFFF59E0B)),
              ],
            ),

            const SizedBox(height: 24),

            // ── Filter chips ──────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return Obx(() {
                    final sel = controller.selectedChip.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectChip(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? _purple : _surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? _purple : _border, width: 1),
                        ),
                        child: Text(
                          controller.chips[i],
                          style: TextStyle(
                            color: sel ? Colors.white : _textSecondary,
                            fontSize: 13,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick Actions ─────────────────────────────────
            _sectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _quickAction(Icons.fitness_center, 'Log Set'),
                _quickAction(Icons.self_improvement_outlined, 'Stretch'),
                _quickAction(Icons.bar_chart_outlined, 'Progress'),
                _quickAction(Icons.calendar_today_outlined, 'Schedule'),
                _quickAction(Icons.restaurant_menu_outlined, 'Nutrition'),
                _quickAction(Icons.chat_bubble_outline, 'AI Coach'),
                _quickAction(Icons.emoji_events_outlined, 'Leaderboard'),
                _quickAction(Icons.more_horiz, 'More'),
              ],
            ),

            const SizedBox(height: 28),

            // ── Today's Workout ───────────────────────────────
            _sectionTitle("Today's Workout"),
            const SizedBox(height: 12),
            _workoutCard(
              'Bench Press',
              '4 sets × 8 reps',
              Icons.fitness_center,
              _purple,
              '80 kg',
            ),
            const SizedBox(height: 10),
            _workoutCard(
              'Overhead Press',
              '3 sets × 10 reps',
              Icons.sports_gymnastics,
              _green,
              '50 kg',
            ),
            const SizedBox(height: 10),
            _workoutCard(
              'Tricep Pushdown',
              '3 sets × 12 reps',
              Icons.sports_handball,
              const Color(0xFFF59E0B),
              '35 kg',
            ),

            const SizedBox(height: 28),

            // ── Weekly Progress ───────────────────────────────
            _sectionTitle('Weekly Progress'),
            const SizedBox(height: 12),
            _progressCard('Volume Load', 0.75, _purple),
            const SizedBox(height: 8),
            _progressCard('Cardio Goal', 0.52, _green),
            const SizedBox(height: 8),
            _progressCard('Consistency', 0.88, const Color(0xFFF59E0B)),

            const SizedBox(height: 28),

            // ── Recent Activity ───────────────────────────────
            _sectionTitle('Recent Activity'),
            const SizedBox(height: 12),
            _activityTile(Icons.check_circle_outline, _green,
                'Completed: Push Day', 'Today, 08:30'),
            _activityTile(Icons.emoji_events_outlined, _purple,
                'New PR: Bench Press 90 kg', 'Yesterday, 09:10'),
            _activityTile(Icons.directions_run, const Color(0xFFF59E0B),
                'Cardio: 5 km run completed', 'Yesterday, 07:00'),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────

  Widget _bannerRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: _textSecondary, size: 15),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(color: _textSecondary, fontSize: 12)),
        ],
      );

  Widget _statCard(String value, String label, IconData icon, Color accent) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 10),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
      );

  Widget _quickAction(IconData icon, String label) => InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _purple, size: 26),
              const SizedBox(height: 5),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: _textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );

  Widget _workoutCard(String name, String sets, IconData icon, Color accent,
          String weight) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sets,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(weight,
                  style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  Widget _progressCard(String label, double value, Color accent) {
    final pct = (value * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text('$pct%',
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityTile(
          IconData icon, Color accent, String title, String sub) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _border, size: 20),
          ],
        ),
      );
}
