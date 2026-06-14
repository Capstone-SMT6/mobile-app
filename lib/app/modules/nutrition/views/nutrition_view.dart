import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/core/theme/app_colors.dart';
import 'package:mobile_app/app/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:mobile_app/app/routes/app_routes.dart';

class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not registered
    final NutritionController controller = Get.find<NutritionController>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text(
          'Catatan Nutrisi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: accentGreen),
            onPressed: () {
              controller.searchFoodItems('', ''); // Reset search
              Get.toNamed(AppRoutes.addFoodLog);
            },
            tooltip: 'Tambah Catatan Makanan',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: accentGreen),
            onPressed: () {
              controller.changePeriod('week');
              Get.toNamed(AppRoutes.nutritionReport);
            },
            tooltip: 'Laporan Nutrisi',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDateData(controller.selectedDate.value),
        color: accentGreen,
        backgroundColor: surfaceColor,
        child: Obx(() {
          if (controller.isLoading.value && controller.selectedDateLogs.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: accentGreen));
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(controller),
                const SizedBox(height: 20),
                _buildMacroSummaryCard(controller),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Makanan Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                _buildMealSection(controller, 'Breakfast', 'Sarapan', Icons.wb_sunny_outlined),
                _buildMealSection(controller, 'Lunch', 'Makan Siang', Icons.wb_cloudy_outlined),
                _buildMealSection(controller, 'Dinner', 'Makan Malam', Icons.nights_stay_outlined),
                _buildMealSection(controller, 'Snack', 'Camilan', Icons.local_cafe_outlined),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.searchFoodItems('', ''); // Reset search
          Get.toNamed(AppRoutes.addFoodLog);
        },
        backgroundColor: accentGreen,
        foregroundColor: bgColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector(NutritionController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () => controller.changeDate(-1),
          ),
          Obx(() => Text(
            controller.formattedSelectedDateDisplay,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          )),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () => controller.changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSummaryCard(NutritionController controller) {
    final summary = controller.selectedDateSummary.value;
    final feedback = controller.dayFeedback.value;

    final actualKcal = summary?.totalKcal ?? 0.0;
    final actualProtein = summary?.totalProteinG ?? 0.0;
    final actualCarbs = summary?.totalCarbsG ?? 0.0;
    final actualFat = summary?.totalFatG ?? 0.0;

    final targetKcal = feedback?.protein.target != null ? (feedback?.protein.target ?? 130.0) * 4 + (feedback?.carbs.target ?? 220.0) * 4 + (feedback?.fat.target ?? 65.0) * 9 : 2000.0; // Estimate or default
    // Wait, let's get targets from feedback if available, otherwise default
    final targetProtein = feedback?.protein.target ?? 130.0;
    final targetCarbs = feedback?.carbs.target ?? 220.0;
    final targetFat = feedback?.fat.target ?? 65.0;
    final targetKcalFinal = feedback != null ? (actualKcal - feedback.kcalGap) : targetKcal;

    final kcalPercent = targetKcalFinal > 0 ? (actualKcal / targetKcalFinal).clamp(0.0, 1.0) : 0.0;
    final proteinPercent = targetProtein > 0 ? (actualProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
    final carbsPercent = targetCarbs > 0 ? (actualCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
    final fatPercent = targetFat > 0 ? (actualFat / targetFat).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgress(
                value: kcalPercent,
                label: 'Kalori',
                amount: '${actualKcal.round()} kcal',
                target: 'Target: ${targetKcalFinal.round()} kcal',
                color: accentGreen,
                size: 80,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLinearMacroProgress('Protein', actualProtein, targetProtein, proteinPercent, Colors.orange),
                  const SizedBox(height: 10),
                  _buildLinearMacroProgress('Karbohidrat', actualCarbs, targetCarbs, carbsPercent, Colors.blue),
                  const SizedBox(height: 10),
                  _buildLinearMacroProgress('Lemak', actualFat, targetFat, fatPercent, Colors.redAccent),
                ],
              ),
            ],
          ),
          if (feedback != null && feedback.recommendations.isNotEmpty) ...[
            const Divider(color: borderColor, height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: accentGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback.recommendations.first,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ),
              ],

            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularProgress({
    required double value,
    required String label,
    required String amount,
    required String target,
    required Color color,
    required double size,
  }) {
    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 9, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
        Text(
          target,
          style: const TextStyle(color: textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLinearMacroProgress(String label, double actual, double target, double percent, Color color) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '${actual.round()}/${target.round()}g',
                style: const TextStyle(fontSize: 10, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(NutritionController controller, String mealType, String title, IconData icon) {
    final meals = controller.selectedDateLogs.where((log) => log.mealType.toLowerCase() == mealType.toLowerCase()).toList();

    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: true,
        leading: Icon(icon, color: accentGreen),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          '${meals.length} item • ${meals.fold(0.0, (sum, log) => sum + log.caloriesKcal).round()} kcal',
          style: const TextStyle(fontSize: 12, color: textSecondary),
        ),
        iconColor: Colors.white,
        collapsedIconColor: textSecondary,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada makanan dicatat.',
                style: TextStyle(color: textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final log = meals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      if (log.foodItem.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            log.foodItem.imageUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              width: 44,
                              height: 44,
                              color: borderColor,
                              child: const Icon(Icons.fastfood, size: 20, color: textSecondary),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.fastfood, size: 20, color: textSecondary),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.foodItem.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            Text(
                              '${log.quantity} ${log.foodItem.servingUnit} • ${log.caloriesKcal.round()} kcal',
                              style: const TextStyle(fontSize: 12, color: textSecondary),
                            ),
                            if (log.notes != null && log.notes!.isNotEmpty)
                              Text(
                                log.notes!,
                                style: const TextStyle(fontSize: 11, color: textSecondary, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: surfaceColor,
                              title: const Text('Hapus Catatan', style: TextStyle(color: Colors.white)),
                              content: Text('Hapus "${log.foodItem.name}" dari catatan makan kamu?', style: const TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Batal', style: TextStyle(color: textSecondary)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.deleteLogEntry(log.id);
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
