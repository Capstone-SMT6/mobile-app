import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingEquipmentPage extends StatefulWidget {
  const OnboardingEquipmentPage({super.key});

  @override
  State<OnboardingEquipmentPage> createState() =>
      _OnboardingEquipmentPageState();
}

class _OnboardingEquipmentPageState extends State<OnboardingEquipmentPage> {
  final Set<String> selectedEquipments = {};

  final List<String> equipmentOptions = [
    "Jump Rope",
    "Foam Roller",
    "Gym Ball",
    "Kettle Bell",
    "Dumbbell",
    "Pull-up Bar",
    "Resistance Band",
  ];

  void _toggleEquipment(String equipment) {
    setState(() {
      if (selectedEquipments.contains(equipment)) {
        selectedEquipments.remove(equipment);
      } else {
        selectedEquipments.add(equipment);
      }
    });
  }

  Widget _buildEquipmentOption(String equipment) {
    final bool isSelected = selectedEquipments.contains(equipment);
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

                    // Options Grid 2-3-2
                    Column(
                      children: [
                        // Row 1 (2 boxes)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEquipmentOption("Jump Rope"),
                            const SizedBox(width: 12),
                            _buildEquipmentOption("Foam Roller"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2 (3 boxes)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEquipmentOption("Gym Ball"),
                            const SizedBox(width: 12),
                            _buildEquipmentOption("Kettle Bell"),
                            const SizedBox(width: 12),
                            _buildEquipmentOption("Dumbbell"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 3 (2 boxes)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEquipmentOption("Pull-up Bar"),
                            const SizedBox(width: 12),
                            _buildEquipmentOption("Resistance Band"),
                          ],
                        ),
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
                      onPressed: () {
                        // Equipment is optional, proceed directly
                        Get.toNamed(AppRoutes.onboardingResult); // Go to Result
                      },
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
                  children: List.generate(9, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 8 ? Colors.white : Colors.white24,
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
