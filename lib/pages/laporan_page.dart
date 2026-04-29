import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';
import '../controllers/user_controller.dart';

const _bg = Color(0xFF0D0F14);
const _surface = Color(0xFF1C2030);
const _border = Color(0xFF2A2F45);
const _green = Color(0xFF4FFFB0);
const _purple = Color(0xFF7C6AF7);
const _textPrimary = Color(0xFFE8EAF2);
const _textSecondary = Color(0xFF6B7280);
const _gold = Color(0xFFF59E0B);

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final LaporanController laporanController = Get.find<LaporanController>();

    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (userController.isLoading.value && userController.stats.value == null) {
          return const Center(child: CircularProgressIndicator(color: _purple));
        }

        final stats = userController.stats.value;
        final profile = userController.fitnessProfile.value;

        return RefreshIndicator(
          onRefresh: () => userController.refreshData(),
          color: _purple,
          backgroundColor: _surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
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
                    _pbCard('Push Ups', '${stats?.totalPushUps ?? 0} reps', _purple),
                    const SizedBox(width: 12),
                    _pbCard('Sit Ups', '${stats?.totalSitUps ?? 0} reps', _green),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _pbCard('Streak', '${stats?.currentStreak ?? 0} days', _gold),
                    const SizedBox(width: 12),
                    _pbCard('Longest', '${stats?.longestStreak ?? 0} days', const Color(0xFFEC4899)),
                  ],
                ),

                const SizedBox(height: 28),

                const Text('WEEKLY ACTIVITY',
                    style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _barChart(),

                const SizedBox(height: 28),

                const Text('FITNESS GOALS',
                    style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: profile == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Complete your fitness profile to track goals',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _textSecondary, fontSize: 13),
                          ),
                        )
                      : Column(
                          children: [
                            // These are still placeholders as we don't have goal progress in DB yet
                            _goalProgress('Overall Progress', 0.15),
                            const SizedBox(height: 16),
                            _goalProgress('Consistency', 0.60),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _goalProgress(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%', style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: _bg,
            color: _green,
            minHeight: 6,
          ),
        ),
      ],
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
              AnimatedContainer(
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

}
