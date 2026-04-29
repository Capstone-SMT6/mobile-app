import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart' as import_controller;

class OnboardingGenderPage extends StatefulWidget {
  const OnboardingGenderPage({super.key});

  @override
  State<OnboardingGenderPage> createState() => _OnboardingGenderPageState();
}

class _OnboardingGenderPageState extends State<OnboardingGenderPage> {
  int? selectedIndex;

  final List<Map<String, dynamic>> genders = [
    {
      "icon": Icons.man,
      "text": "Pria",
    },
    {
      "icon": Icons.woman,
      "text": "Wanita",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216), // Dark background
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
                              color: Color(0xFF6CC551), // Light green
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
                      "Apa jenis kelamin kamu?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Grid of Genders
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.55, // Taller cards for gender selection
                      ),
                      itemCount: genders.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E202E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6CC551) : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF6CC551).withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  genders[index]["icon"],
                                  size: 96, // Larger icon for the figures
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  genders[index]["text"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button Sticking to Left Edge
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sebelumnya",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    
                    // Next Button Sticking to Right Edge
                    TextButton(
                      onPressed: selectedIndex != null ? () {
                        final onboardingController = Get.find<import_controller.OnboardingController>();
                        onboardingController.jenisKelamin.value = genders[selectedIndex!]["text"] as String;
                        Get.toNamed(AppRoutes.onboardingAge);
                      } : null,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF222434),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF171925),
                        disabledForegroundColor: Colors.white38,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Selanjutnya",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48), // Space before pagination dots
                
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 1 ? Colors.white : Colors.white24, // 2nd dot is active
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 16), // Bottom safe space
              ],
            ),
          ],
        ),
      ),
    );
  }
}
