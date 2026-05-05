import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Exercise {
  final String name;
  final String gif;
  final String desc;
  final String muscle;
  final List<String> tips;
  final List<String> mistakes;

  Exercise({
    required this.name,
    required this.gif,
    required this.desc,
    required this.muscle,
    required this.tips,
    required this.mistakes,
  });
}

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

  static final exercises = [
    Exercise(
      name: "Push Up",
      gif: "https://media.giphy.com/media/XIqCQx02E1U9W/giphy.gif",
      desc: "Latihan fundamental untuk membangun kekuatan tubuh bagian atas, khususnya otot dada, bahu, dan triceps.",
      muscle: "Chest, Shoulder, Triceps",
      tips: ["Jaga punggung lurus seperti papan", "Turun perlahan dengan terkontrol", "Posisi tangan sedikit lebih lebar dari bahu"],
      mistakes: ["Pinggul turun menyentuh lantai", "Gerakan terlalu cepat", "Leher mendongak ke depan"],
    ),
    Exercise(
      name: "Squat",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan utama untuk membangun kekuatan lower body, khususnya otot kaki dan glutes.",
      muscle: "Legs, Glutes",
      tips: ["Turun sampai pinggul sejajar dengan lutut", "Jaga lutut tetap stabil dan terbuka", "Berat badan bertumpu pada tumit"],
      mistakes: ["Lutut menekuk ke dalam", "Kedalaman squat kurang (half squat)", "Punggung terlalu membungkuk"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Premium dark background
      appBar: AppBar(
        title: const Text(
          "Workout Guide",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Dihilangkan karena menempel di Bottom Nav
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final e = exercises[index];

            return GestureDetector(
              onTap: () {
                Get.to(() => ExerciseDetailPage(exercise: e));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF222434),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          e.gif,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Colors.white38),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.muscle,
                            style: const TextStyle(
                              color: Color(0xFF6CC551), // Hijau aksen
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 🎥 GIF
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                exercise.gif,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 📌 DESCRIPTION
          _card(
            title: "Description",
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF29B6F6),
            child: Text(
              exercise.desc,
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
            ),
          ),

          const SizedBox(height: 16),

          // 💪 MUSCLE
          _card(
            title: "Target Muscle",
            icon: Icons.fitness_center_rounded,
            iconColor: const Color(0xFF7C6AF7), // Ungu
            child: Text(
              exercise.muscle,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // ✅ TIPS
          _card(
            title: "Pro Tips",
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF6CC551), // Hijau
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.tips
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Icon(Icons.circle, color: Color(0xFF6CC551), size: 6),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ❌ MISTAKES
          _card(
            title: "Common Mistakes",
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF76A6A), // Merah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.mistakes
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Icon(Icons.close, color: Color(0xFFF76A6A), size: 12),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 32),

          // 🔥 BUTTON
          SizedBox(
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
              onPressed: () {
                Get.snackbar(
                  "Added to Workout",
                  "${exercise.name} berhasil ditambahkan ke jadwal latihan Anda!",
                  backgroundColor: const Color(0xFF222434),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  icon: const Icon(Icons.check_circle, color: Color(0xFF6CC551)),
                );
              },
              child: const Text(
                "Add to Workout",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222434),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }
}
