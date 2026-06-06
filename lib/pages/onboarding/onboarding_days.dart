import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../routes/app_routes.dart';

class OnboardingDaysPage extends StatelessWidget {
  const OnboardingDaysPage({super.key});

  static const List<Map<String, String>> _days = [
    {'label': 'Senin', 'value': 'senin'},
    {'label': 'Selasa', 'value': 'selasa'},
    {'label': 'Rabu', 'value': 'rabu'},
    {'label': 'Kamis', 'value': 'kamis'},
    {'label': 'Jumat', 'value': 'jumat'},
    {'label': 'Sabtu', 'value': 'sabtu'},
    {'label': 'Minggu', 'value': 'minggu'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sma',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                            TextSpan(
                              text: 'Fit',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6CC551),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Rancang Rencana Kamu Sendiri",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final requiredDays =
                            controller.intensity.value == 'tinggi'
                            ? '5-6'
                            : '${controller.requiredTrainingDays}';
                        return Text(
                          "Pilih $requiredDays hari latihan kamu",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }),
                      const SizedBox(height: 40),
                      Obx(
                        () => Column(
                          children: _days.map((day) {
                            final value = day['value']!;
                            final isSelected = controller.selectedDays.contains(
                              value,
                            );
                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  controller.selectedDays.remove(value);
                                  return;
                                }

                                final maxDays =
                                    controller.intensity.value == 'tinggi'
                                    ? 6
                                    : controller.requiredTrainingDays;
                                if (controller.selectedDays.length < maxDays) {
                                  controller.selectedDays.add(value);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222434),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6CC551)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? const Color(0xFF6CC551)
                                          : Colors.white54,
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      day['label']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? const Color(0xFF6CC551)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sebelumnya",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Obx(
                      () => TextButton(
                        onPressed: controller.hasValidSelectedDays
                            ? () => Get.toNamed(AppRoutes.onboardingResult)
                            : null,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF222434),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF171925),
                          disabledForegroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Selanjutnya",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(9, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 7 ? Colors.white : Colors.white24,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
