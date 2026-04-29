import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingResultPage extends StatelessWidget {
  const OnboardingResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sma',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'Fit',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6CC551),
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Profil Kamu Siap!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Berikut adalah ringkasan data yang kamu masukkan.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Placeholder content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222434),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultRow("Tujuan", controller.target.value),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Gender", controller.jenisKelamin.value),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Usia", "${controller.usia.value} Tahun"),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Tinggi / Berat", "${controller.tinggiBadan.value} cm / ${controller.beratBadan.value} kg"),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Keahlian", controller.pengalamanFitness.value),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Intensitas", controller.tingkatAktivitas.value),
                        const Divider(color: Colors.white12, height: 24),
                        _buildResultRow("Alat", controller.ketersediaanAlat.value.isNotEmpty ? controller.ketersediaanAlat.value : 'Tidak ada'),
                        
                        const SizedBox(height: 32),
                        const Text(
                          "Rekomendasi Program Latihan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildExerciseCard("Push Up", "Dada, Trisep", "3 Set x 12 Rep"),
                        const SizedBox(height: 12),
                        _buildExerciseCard("Dumbbell Goblet Squat", "Kaki, Glutes", "3 Set x 10 Rep"),
                        const SizedBox(height: 12),
                        _buildExerciseCard("Plank", "Inti (Core)", "3 Set x 30 Detik"),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () async {
                  final success = await controller.submitOnboardingData();
                  if (success) {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CC551),
                  foregroundColor: const Color(0xFF101216),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      "Mulai Perjalanan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(String title, String target, String sets) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171925),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF6CC551),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Fokus: $target",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            sets,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6CC551),
            ),
          ),
        ],
      ),
    );
  }
}
