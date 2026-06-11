import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/plan_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Map<String, dynamic>? _analytics;
  bool _loading = true;
  String? _error;
  int _selectedWeeks = 4;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await PlanService.getAnalyticsSummary();
      if (mounted) {
        setState(() {
          _analytics = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _loading = false; });
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CC551)))
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _fetchAnalytics,
                  color: const Color(0xFF6CC551),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildChartCard(),
                      const SizedBox(height: 24),
                      summaryCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
          const SizedBox(height: 16),
          const Text('Gagal memuat data', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchAnalytics, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalWorkouts = _analytics?['total_workouts'] ?? 0;
    final totalReps = _analytics?['total_reps'] ?? 0;
    final streak = _analytics?['current_streak'] ?? 0;

    return Row(
      children: [
        _statCard('$totalWorkouts', 'Workouts', Icons.fitness_center, const Color(0xFFAB47BC)),
        const SizedBox(width: 12),
        _statCard('$totalReps', 'Total Reps', Icons.repeat, const Color(0xFF29B6F6)),
        const SizedBox(width: 12),
        _statCard('$streak', 'Hari Streak', Icons.local_fire_department, const Color(0xFFFFA726)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF222434),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
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
              const Text("EVALUATE FORM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF171925),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedWeeks,
                    dropdownColor: const Color(0xFF222434),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: [4, 8, 12].map((w) => DropdownMenuItem(value: w, child: Text('$w Minggu'))).toList(),
                    onChanged: (val) => setState(() => _selectedWeeks = val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const weeks = ["M1", "M2", "M3", "M4"];
                        if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(weeks[value.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white38, fontSize: 12)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white10, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroup(0, 3, 1),
                  _makeGroup(1, 4, 0),
                  _makeGroup(2, 1.5, 2),
                  _makeGroup(3, 3.5, 0.5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle, color: Color(0xFF6CC551), size: 12),
              SizedBox(width: 8),
              Text("Good", style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(width: 24),
              Icon(Icons.circle, color: Color(0xFFF76A6A), size: 12),
              SizedBox(width: 8),
              Text("Bad", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double good, double bad) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: good, color: const Color(0xFF6CC551), width: 12, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: bad, color: const Color(0xFFF76A6A), width: 12, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget summaryCard() {
    final durationSecs = _analytics?['total_duration_seconds'] ?? 0;
    final duration = (durationSecs / 60).round().toString();
    final totalReps = _analytics?['total_reps'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF222434),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildSummaryRow(Icons.fitness_center, "Total Push Ups", "${_analytics?['total_push_ups'] ?? 0}", const Color(0xFFFFA726)),
          const Divider(color: Colors.white10, height: 32),
          _buildSummaryRow(Icons.timer, "Total Duration", "${duration}min", const Color(0xFF29B6F6)),
          const Divider(color: Colors.white10, height: 32),
          _buildSummaryRow(Icons.repeat, "Total Reps", "$totalReps", const Color(0xFFAB47BC)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15))),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
