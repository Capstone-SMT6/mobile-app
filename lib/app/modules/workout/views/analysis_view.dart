import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smacofit/app/data/services/plan_service.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisView> {
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
                      _buildPostureScoreCard(),
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

  Widget _buildPostureScoreCard() {
    // Dummy score for illustration
    final score = 88.0;
    final grade = "A-";
    final message = "Teknik tubuh bagian atasmu sangat solid! Namun AI mencatat postur lutut saat Squat masih perlu sedikit perbaikan. Pertahankan konsistensi ini!";

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
              const Text("AI POSTURE SCORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6CC551).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("+5% Naik", style: TextStyle(color: Color(0xFF6CC551), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 75,
                    sections: [
                      PieChartSectionData(
                        value: score,
                        color: const Color(0xFF6CC551),
                        radius: 16,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - score,
                        color: const Color(0xFF222434), // Background hole color
                        borderSide: const BorderSide(color: Colors.white10, width: 2),
                        radius: 16,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${score.toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Grade $grade",
                        style: const TextStyle(
                          color: Color(0xFF6CC551),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // AI Insight Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF171925),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B6F6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF29B6F6), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Insight",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
