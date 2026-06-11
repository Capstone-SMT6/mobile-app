import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/plan_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _weekly;
  bool _loading = true;
  String? _error;
  int _weeksCount = 4;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        PlanService.getAnalyticsSummary(),
        PlanService.getWeeklyAnalytics(weeks: _weeksCount),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
          _weekly = results[1] as Map<String, dynamic>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Workout Analysis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6AF7)))
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data analytics',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white30, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6AF7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final totalWorkouts = _summary?['total_workouts'] ?? 0;
    final totalReps = _summary?['total_reps'] ?? 0;
    final currentStreak = _summary?['current_streak'] ?? 0;
    final longestStreak = _summary?['longest_streak'] ?? 0;
    final totalDuration = _summary?['total_duration_minutes'] ?? 0;
    final favoriteExercises = (_summary?['favorite_exercises'] as List?) ?? [];

    final weeks = (_weekly?['weeks'] as List?) ?? [];

    return RefreshIndicator(
      color: const Color(0xFF7C6AF7),
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── STATS CARDS ────────────────────────────────────
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.fitness_center,
                label: 'Total Workout',
                value: '$totalWorkouts',
                color: const Color(0xFF7C6AF7),
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.repeat,
                label: 'Total Reps',
                value: '$totalReps',
                color: const Color(0xFFAB47BC),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.local_fire_department,
                label: 'Streak Saat Ini',
                value: '$currentStreak hari',
                color: const Color(0xFFFFA726),
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.emoji_events,
                label: 'Streak Terpanjang',
                value: '$longestStreak hari',
                color: const Color(0xFF6CC551),
              )),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.timer,
            label: 'Total Durasi Latihan',
            value: '$totalDuration menit',
            color: const Color(0xFF29B6F6),
          ),

          const SizedBox(height: 24),

          // ── WEEKLY BAR CHART ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Workout Mingguan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171925),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _weeksCount,
                          dropdownColor: const Color(0xFF222434),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(value: 4, child: Text('4 Minggu')),
                            DropdownMenuItem(value: 8, child: Text('8 Minggu')),
                            DropdownMenuItem(value: 12, child: Text('12 Minggu')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              _weeksCount = val;
                              _loadData();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: weeks.isEmpty
                      ? const Center(
                          child: Text('Belum ada data workout', style: TextStyle(color: Colors.white38)),
                        )
                      : BarChart(_buildBarChartData(weeks)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.circle, color: Color(0xFF7C6AF7), size: 10),
                    SizedBox(width: 6),
                    Text("Workout", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(width: 20),
                    Icon(Icons.circle, color: Color(0xFF6CC551), size: 10),
                    SizedBox(width: 6),
                    Text("Volume", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── SUMMARY CARD ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ringkasan",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.local_fire_department, "Total Workout", "$totalWorkouts sesi", const Color(0xFFFFA726)),
                const Divider(color: Colors.white10, height: 24),
                _buildSummaryRow(Icons.repeat, "Total Reps", "$totalReps reps", const Color(0xFFAB47BC)),
                const Divider(color: Colors.white10, height: 24),
                _buildSummaryRow(Icons.timer, "Rata-rata Durasi",
                    "${totalWorkouts > 0 ? (totalDuration / totalWorkouts).toStringAsFixed(0) : '0'} menit/sesi",
                    const Color(0xFF29B6F6)),
                const Divider(color: Colors.white10, height: 24),
                _buildSummaryRow(Icons.emoji_events, "Streak", "$currentStreak / $longestStreak hari", const Color(0xFF6CC551)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── FAVORITE EXERCISES ─────────────────────────────
          if (favoriteExercises.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF222434),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gerakan Favorit",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ...favoriteExercises.take(5).map((ex) {
                    final name = ex['exercise_name'] ?? ex['name'] ?? 'Unknown';
                    final count = ex['count'] ?? ex['total_reps'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C6AF7).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fitness_center, color: Color(0xFF7C6AF7), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                          Text(
                            '$count reps',
                            style: const TextStyle(
                              color: Color(0xFF7C6AF7),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── CONSISTENCY SCORE ──────────────────────────────
          if (_weekly?['consistency_score'] != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6CC551).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF6CC551).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF6CC551), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Skor Konsistensi: ${(_weekly!['consistency_score'] as num).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Color(0xFF6CC551),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getConsistencyMessage(_weekly!['consistency_score'] as num),
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(List<dynamic> weeks) {
    final maxWorkouts = weeks.fold<double>(1, (max, w) {
      final wc = (w['workout_count'] as num?)?.toDouble() ?? 0;
      return wc > max ? wc : max;
    });

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxWorkouts + 1,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final week = weeks[group.x.toInt()];
            final label = rodIndex == 0
                ? 'Workout: ${week['workout_count'] ?? 0}'
                : 'Volume: ${week['total_volume'] ?? 0}';
            return BarTooltipItem(
              'Minggu ${week['week_number'] ?? group.x + 1}\n$label',
              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < weeks.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'M${weeks[idx]['week_number'] ?? idx + 1}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(weeks.length, (i) {
        final w = weeks[i];
        final workoutCount = (w['workout_count'] as num?)?.toDouble() ?? 0;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: workoutCount,
              color: const Color(0xFF7C6AF7),
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  String _getConsistencyMessage(num score) {
    if (score >= 80) return 'Luar biasa! Konsistensi kamu sangat tinggi. Pertahankan!';
    if (score >= 60) return 'Bagus! Coba tingkatkan frekuensi latihan untuk hasil lebih baik.';
    if (score >= 40) return 'Cukup baik. Jadwalkan latihan rutin untuk meningkatkan konsistensi.';
    return 'Ayo mulai rutin berlatih! Konsistensi adalah kunci hasil yang baik.';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
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
    );
  }
}
