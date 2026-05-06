import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/workout_service.dart';
import '../controllers/user_controller.dart';

class WorkoutListPage extends StatelessWidget {
  const WorkoutListPage({super.key});

  final List<Map<String, String>> workouts = const [
    {
      "title": "Push Up",
      "gif": "https://media.giphy.com/media/XIqCQx02E1U9W/giphy.gif",
      "desc": "Push-up melatih otot dada, bahu, dan triceps."
    },
    {
      "title": "Squat",
      "gif": "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      "desc": "Squat sangat efektif untuk melatih kekuatan kaki dan glutes."
    },
    {
      "title": "Plank",
      "gif": "https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif",
      "desc": "Plank melatih core stability dan daya tahan otot perut."
    },
  ];

  // Menampilkan modal dari bawah (BottomSheet) menggunakan GetX
  void _showDetailBottomSheet(Map<String, String> item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF171925),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan tinggi dengan konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar (garis abu-abu kecil di atas)
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            Text(
              item["title"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // GIF Animation
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222434),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  item["gif"]!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white38,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text(
              "Instruction",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item["desc"]!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24), // Spasi bawah ekstra
          ],
        ),
      ),
      isScrollControlled: true, // Memungkinkan BottomSheet untuk tampil optimal jika layarnya kecil
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Dark premium background
      appBar: AppBar(
        title: const Text(
          "Workout List",
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final item = workouts[index];

          return GestureDetector(
            onTap: () => _showDetailBottomSheet(item), // Klik memunculkan dialog bawah
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF222434),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CC551).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.fitness_center, color: Color(0xFF6CC551), size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      item["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 24),
                ],
              ),
            ),
          );
        },
      ),
      
      // Tombol Start Workout dipindahkan ke Halaman List
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CC551),
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF6CC551).withOpacity(0.4),
              ),
              onPressed: () async {
                try {
                  // Simpan sesi ke backend dengan log latihan
                  final result = await WorkoutService.saveSession(
                    durationSeconds: 0,
                    logs: [
                      {'exercise_name': 'Push Up', 'set_number': 1, 'reps_completed': 20},
                      {'exercise_name': 'Push Up', 'set_number': 2, 'reps_completed': 20},
                      {'exercise_name': 'Pull Up', 'set_number': 1, 'reps_completed': 10},
                      {'exercise_name': 'Plank', 'set_number': 1, 'reps_completed': 30},
                    ],
                  );

                  // Refresh data user agar streak terupdate di Beranda
                  await Get.find<UserController>().refreshData();

                  final streak = result['streak'] ?? 0;
                  Get.snackbar(
                    'Workout Selesai',
                    streak > 0
                        ? 'Keren! Streak kamu sekarang $streak hari!'
                        : 'Latihan berhasil disimpan!',
                    backgroundColor: const Color(0xFF222434),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    icon: const Icon(Icons.check_circle, color: Color(0xFF6CC551)),
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Gagal menyimpan',
                    'Pastikan koneksi ke server aktif.',
                    backgroundColor: const Color(0xFF2A1A1A),
                    colorText: Colors.redAccent,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              child: const Text(
                "Start Workout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
