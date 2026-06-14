import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:mobile_app/app/modules/auth/controllers/user_controller.dart';
import 'package:mobile_app/app/routes/app_routes.dart';
import 'package:mobile_app/app/core/utils/snackbar_helper.dart';

class OnboardingResultView extends StatelessWidget {
  const OnboardingResultView({super.key});

  static const Map<String, String> _goalLabels = {
    'menurunkan_berat_badan': 'Menurunkan Berat Badan',
    'menaikkan_berat_badan': 'Menaikkan Berat Badan',
    'menjaga_kebugaran': 'Menjaga Kebugaran',
    'membentuk_otot': 'Membentuk Otot',
  };

  static const Map<String, String> _genderLabels = {
    'pria': 'Pria',
    'wanita': 'Wanita',
  };

  static const Map<String, String> _skillLabels = {
    'pemula': 'Pemula',
    'menengah': 'Menengah',
    'ahli': 'Ahli',
  };

  static const Map<String, String> _intensityLabels = {
    'rendah': 'Rendah',
    'sedang': 'Sedang',
    'tinggi': 'Tinggi',
  };

  static const Map<String, String> _dayLabels = {
    'senin': 'Senin',
    'selasa': 'Selasa',
    'rabu': 'Rabu',
    'kamis': 'Kamis',
    'jumat': 'Jumat',
    'sabtu': 'Sabtu',
    'minggu': 'Minggu',
  };

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
                style: TextStyle(fontSize: 14, color: Colors.white70),
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
                        Obx(
                          () => _buildResultRow(
                            "Tujuan",
                            _goalLabels[controller.goal.value] ??
                                controller.goal.value,
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Gender",
                            _genderLabels[controller.gender.value] ??
                                controller.gender.value,
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Usia",
                            "${controller.age.value} Tahun",
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Tinggi / Berat",
                            "${controller.height.value.round()} cm / ${controller.weight.value.round()} kg",
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Keahlian",
                            _skillLabels[controller.skillLevel.value] ??
                                controller.skillLevel.value,
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Intensitas",
                            _intensityLabels[controller.intensity.value] ??
                                controller.intensity.value,
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        Obx(
                          () => _buildResultRow(
                            "Hari Latihan",
                            controller.selectedDays
                                .map((day) => _dayLabels[day] ?? day)
                                .join(', '),
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Text(
                          "Latihan yang Didukung",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildExerciseCard(
                          "Push-Up",
                          "Dada, Trisep",
                          "Repetisi",
                        ),
                        const SizedBox(height: 12),
                        _buildExerciseCard("Sit-Up", "Perut", "Repetisi"),
                        const SizedBox(height: 12),
                        _buildExerciseCard("Squat", "Kaki, Glutes", "Repetisi"),
                        const SizedBox(height: 12),
                        _buildExerciseCard("Plank", "Inti (Core)", "Durasi"),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          try {
                            await controller.submitOnboarding();
                            await Get.find<UserController>().refreshData();
                            Get.offAllNamed(AppRoutes.home);
                          } catch (e) {
                            showCustomSnackbar(
                              title: 'Gagal',
                              message: e.toString(),
                              backgroundColor: Colors.red,
                            );
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
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF101216),
                          ),
                        )
                      : const Text(
                          "Mulai Perjalanan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
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
            child: const Icon(Icons.fitness_center, color: Color(0xFF6CC551)),
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
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
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
