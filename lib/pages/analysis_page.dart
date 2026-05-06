import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String selectedRange = "Last 4 Months";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Dark premium background
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // CHART CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "EVALUATE FORM",
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
                        child: DropdownButton<String>(
                          value: selectedRange,
                          dropdownColor: const Color(0xFF222434),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: [
                            "Last week",
                            "Last month",
                            "Last 4 Months",
                            "Last year"
                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedRange = val!;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 32),

                // BAR CHART
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
                              const months = ["Aug", "Sep", "Oct", "Nov"];
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        makeGroup(0, 3, 1),
                        makeGroup(1, 4, 0),
                        makeGroup(2, 1.5, 2),
                        makeGroup(3, 3.5, 0.5),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // LEGEND
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
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SUMMARY CARD
          summaryCard(),

          const SizedBox(height: 24),

          // ERROR INSIGHT
          errorInsightCard(),
        ],
      ),
    );
  }

  // BAR DATA
  BarChartGroupData makeGroup(int x, double good, double bad) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: good,
          color: const Color(0xFF6CC551),
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: bad,
          color: const Color(0xFFF76A6A),
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // SUMMARY
  Widget summaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF222434),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildSummaryRow(Icons.local_fire_department, "Calories Burned", "320 kcal", const Color(0xFFFFA726)),
          const Divider(color: Colors.white10, height: 32),
          _buildSummaryRow(Icons.timer, "Time Under Tension", "12 min", const Color(0xFF29B6F6)),
          const Divider(color: Colors.white10, height: 32),
          _buildSummaryRow(Icons.fitness_center, "Total Reps", "120", const Color(0xFFAB47BC)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ERROR INSIGHT
  Widget errorInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF76A6A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF76A6A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF76A6A)),
              SizedBox(width: 12),
              Text(
                "Form Issues Detected",
                style: TextStyle(
                  color: Color(0xFFF76A6A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIssueText("Back terlalu melengkung saat push up"),
          const SizedBox(height: 8),
          _buildIssueText("Depth squat kurang dalam"),
          const SizedBox(height: 8),
          _buildIssueText("Tempo terlalu cepat"),
        ],
      ),
    );
  }

  Widget _buildIssueText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, color: Color(0xFFF76A6A), size: 6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
