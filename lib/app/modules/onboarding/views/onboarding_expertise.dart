import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart' as import_controller;

class OnboardingExpertisePage extends StatefulWidget {
  const OnboardingExpertisePage({super.key});

  @override
  State<OnboardingExpertisePage> createState() =>
      _OnboardingExpertisePageState();
}

class _OnboardingExpertisePageState extends State<OnboardingExpertisePage> {
  String selectedExpertise = '';

  Widget _buildOptionCard(String title) {
    final bool isSelected = selectedExpertise == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedExpertise = title;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF222434),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6CC551) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFF6CC551) : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                    const SizedBox(height: 24),
                    // Logo
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
                    const Text(
                      "Seberapa ahli kamu?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Options
                    _buildOptionCard("Pemula"),
                    _buildOptionCard("Menengah"),
                    _buildOptionCard("Ahli"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section pinned
            Column(
              children: [
                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sebelumnya",
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: selectedExpertise.isNotEmpty
                          ? () {
                              final onboardingController = Get.find<import_controller.OnboardingController>();
                              if (selectedExpertise == 'Pemula') {
                                onboardingController.pengalamanFitness.value = 'Beginner';
                              } else if (selectedExpertise == 'Menengah') {
                                onboardingController.pengalamanFitness.value = 'Intermediate';
                              } else if (selectedExpertise == 'Ahli') {
                                onboardingController.pengalamanFitness.value = 'Expert';
                              }
                              Get.toNamed(AppRoutes.onboardingIntensity);
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF171925),
                        disabledForegroundColor: Colors.white38,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Selanjutnya",
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Pagination Dots (assume 8 pages, this is 6th)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 5 ? Colors.white : Colors.white24,
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
