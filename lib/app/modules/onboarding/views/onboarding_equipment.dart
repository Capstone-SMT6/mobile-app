import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart' as import_controller;

class OnboardingEquipmentPage extends StatefulWidget {
  const OnboardingEquipmentPage({super.key});

  @override
  State<OnboardingEquipmentPage> createState() =>
      _OnboardingEquipmentPageState();
}

class _OnboardingEquipmentPageState extends State<OnboardingEquipmentPage> {
  String selectedEquipment = '';

  final List<String> equipmentOptions = [
    "Gym",
    "Dumbbell",
    "Bodyweight",
  ];

  void _toggleEquipment(String equipment) {
    setState(() {
      selectedEquipment = equipment;
    });
  }

  Widget _buildEquipmentOption(String equipment) {
    final bool isSelected = selectedEquipment == equipment;
    return GestureDetector(
      onTap: () => _toggleEquipment(equipment),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6CC551)
              : const Color(0xFF222434),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          equipment,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF101216)
                : Colors.white,
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
                      "Apakah kamu memiliki akses ke\nalat olahraga berikut? (opsional)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    Column(
                      children: [
                        _buildEquipmentOption("Gym"),
                        const SizedBox(height: 16),
                        _buildEquipmentOption("Dumbbell"),
                        const SizedBox(height: 16),
                        _buildEquipmentOption("Bodyweight"),
                      ],
                    ),
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
                      onPressed: selectedEquipment.isNotEmpty
                          ? () {
                              final onboardingController = Get.find<import_controller.OnboardingController>();
                              onboardingController.ketersediaanAlat.value = selectedEquipment;
                              Get.toNamed(AppRoutes.onboardingResult); // Go to Result
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6CC551), // Final step button color
                        foregroundColor: Colors.white,
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
                        "Selesai",
                        style:
                            TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Pagination Dots (9 dots, this is 9th so index 8)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 7 ? Colors.white : Colors.white24,
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
