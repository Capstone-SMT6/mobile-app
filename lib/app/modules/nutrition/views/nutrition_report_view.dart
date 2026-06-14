import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/app/core/theme/app_colors.dart';
import 'package:mobile_app/app/modules/nutrition/controllers/nutrition_controller.dart';


class NutritionReportView extends StatelessWidget {
  const NutritionReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final NutritionController controller = Get.find<NutritionController>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Laporan Nutrisi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildPeriodSelector(controller),
            Expanded(
              child: controller.reportLoading.value
                  ? const Center(child: CircularProgressIndicator(color: accentGreen))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAverageCard(controller),
                          const SizedBox(height: 20),
                          _buildChartCard(controller),
                          const SizedBox(height: 20),
                          _buildDailyBreakdownList(controller),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPeriodSelector(NutritionController controller) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(controller, 'week', '7 Hari'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton(controller, 'month', '30 Hari'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(NutritionController controller, String period, String label) {
    final isSelected = controller.selectedPeriod.value == period;
    return ElevatedButton(
      onPressed: () => controller.changePeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? accentGreen : borderColor,
        foregroundColor: isSelected ? bgColor : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAverageCard(NutritionController controller) {
    final isWeek = controller.selectedPeriod.value == 'week';
    final data = isWeek ? controller.weeklySummaries : controller.monthlySummaries;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCalories = data.fold(0.0, (sum, item) => sum + (item['calories'] as num).toDouble());
    final avgCalories = totalCalories / data.length;

    final totalProtein = data.fold(0.0, (sum, item) => sum + (item['protein'] as num).toDouble());
    final avgProtein = totalProtein / data.length;

    final totalCarbs = data.fold(0.0, (sum, item) => sum + (item['carbs'] as num).toDouble());
    final avgCarbs = totalCarbs / data.length;

    final totalFat = data.fold(0.0, (sum, item) => sum + (item['fat'] as num).toDouble());
    final avgFat = totalFat / data.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rata-Rata Asupan Harian',
            style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${avgCalories.round()} kcal',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const Divider(color: borderColor, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo('Protein', '${avgProtein.round()}g', Colors.orange),
              _buildMacroInfo('Karb', '${avgCarbs.round()}g', Colors.blue),
              _buildMacroInfo('Lemak', '${avgFat.round()}g', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildChartCard(NutritionController controller) {
    final isWeek = controller.selectedPeriod.value == 'week';
    final data = isWeek ? controller.weeklySummaries : controller.monthlySummaries;

    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: const Center(child: Text('Belum ada data grafik.', style: TextStyle(color: textSecondary))),
      );
    }

    final double targetKcal = data.first['target_calories'] != null ? (data.first['target_calories'] as num).toDouble() : 2000.0;
    
    // Find max value in data to scale graph maxY
    double maxVal = data.fold(targetKcal, (max, item) {
      final val = (item['calories'] as num).toDouble();
      return val > max ? val : max;
    });
    
    double maxY = (maxVal * 1.15 / 500).ceil() * 500.0; // Round up to nearest 500

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final kcal = (item['calories'] as num).toDouble();
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: kcal,
              color: kcal > targetKcal ? Colors.redAccent : accentGreen,
              width: isWeek ? 16 : 6,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Konsumsi Kalori',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => surfaceColor,
                    tooltipBorder: const BorderSide(color: borderColor),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dateStr = data[group.x.toInt()]['date'] as String;
                      final dateTime = DateTime.parse(dateStr);
                      final formattedDate = DateFormat('d MMM').format(dateTime);
                      return BarTooltipItem(
                        '$formattedDate\n${rod.toY.round()} kcal',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetKcal,
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      strokeWidth: 2,

                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (line) => 'Target (${targetKcal.round()} kcal)',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox.shrink();
                        
                        final dateStr = data[index]['date'] as String;
                        final parsedDate = DateTime.parse(dateStr);
                        
                        // Show label only for every day in week, or every 5 days in month
                        if (!isWeek && index % 5 != 0 && index != data.length - 1) {
                          return const SizedBox.shrink();
                        }
                        
                        final label = isWeek ? DateFormat('E', 'id_ID').format(parsedDate) : DateFormat('d/M').format(parsedDate);
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: const TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(color: textSecondary, fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: borderColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownList(NutritionController controller) {
    final isWeek = controller.selectedPeriod.value == 'week';
    final data = isWeek ? controller.weeklySummaries : controller.monthlySummaries;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final reversedData = data.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Harian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversedData.length,
          itemBuilder: (context, index) {
            final item = reversedData[index];
            final dateStr = item['date'] as String;
            final dateParsed = DateTime.parse(dateStr);
            final dayFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateParsed);
            final calories = (item['calories'] as num).toDouble();
            final targetCalories = item['target_calories'] != null ? (item['target_calories'] as num).toDouble() : 2000.0;
            final isOver = calories > targetCalories;

            return Card(
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: borderColor),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  dayFormatted,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                subtitle: Text(
                  'Protein: ${item['protein'].round()}g • Karbohidrat: ${item['carbs'].round()}g • Lemak: ${item['fat'].round()}g',
                  style: const TextStyle(fontSize: 11, color: textSecondary),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${calories.round()} kcal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isOver ? Colors.redAccent : accentGreen,
                      ),
                    ),
                    Text(
                      'Target: ${targetCalories.round()} kcal',
                      style: const TextStyle(fontSize: 9, color: textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
