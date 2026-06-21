import 'package:smacofit/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/core/utils/snackbar_helper.dart';

class Exercise {
  final String name;
  final String gif;
  final String desc;
  final String muscle;
  final String difficulty;
  final String target;
  final List<String> tips;
  final List<String> mistakes;

  Exercise({
    required this.name,
    required this.gif,
    required this.desc,
    required this.muscle,
    required this.difficulty,
    required this.target,
    required this.tips,
    required this.mistakes,
  });
}

class ExerciseListView extends StatelessWidget {
  const ExerciseListView({super.key});

  static final exercises = [
    Exercise(
      name: "Push Up",
      gif: "https://media.giphy.com/media/XIqCQx02E1U9W/giphy.gif",
      desc: "Latihan fundamental untuk membangun kekuatan tubuh bagian atas, khususnya otot dada, bahu, dan triceps.",
      muscle: "Punggung, Bahu, Triceps",
      difficulty: "Pemula",
      target: "3 Set x 12 Reps",
      tips: [
        "Jaga punggung lurus seperti papan",
        "Turun perlahan dengan terkontrol (siku < 100°)",
        "Posisi tangan sedikit lebih lebar dari bahu",
      ],
      mistakes: [
        "Pinggul turun menyentuh lantai",
        "Gerakan terlalu cepat tanpa kontrol",
        "Leher mendongak ke depan",
      ],
    ),
    Exercise(
      name: "Sit Up",
      gif: "https://media.giphy.com/media/3o7qE0gCO5LXcIVbTq/giphy.gif",
      desc: "Latihan inti (core strength) klasik untuk melatih stabilitas abdomen serta kekuatan otot perut.",
      muscle: "Perut, Inti",
      difficulty: "Pemula",
      target: "3 Set x 15 Reps",
      tips: [
        "Jaga leher tetap rileks dan jangan ditarik paksa",
        "Gunakan kontraksi otot perut untuk mengangkat tubuh",
        "Tekuk lutut Anda pada sudut yang nyaman",
      ],
      mistakes: [
        "Menarik leher menggunakan kedua tangan",
        "Mengangkat pinggul/bokong dari lantai",
        "Punggung terlalu melengkung secara ekstrim",
      ],
    ),
    Exercise(
      name: "Squat",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan utama untuk membangun kekuatan tubuh bagian bawah (lower body), khususnya otot kaki and glutes.",
      muscle: "Kaki, Bokong, Paha Depan",
      difficulty: "Pemula",
      target: "3 Set x 15 Reps",
      tips: [
        "Turun sampai pinggul sejajar dengan lutut (knee < 95°)",
        "Jaga lutut tetap stabil dan terbuka, jangan menekuk ke dalam",
        "Berat badan bertumpu pada tumit kaki",
      ],
      mistakes: [
        "Lutut menekuk menekuk ke dalam",
        "Lutut menekuk maju melebihi ujung jari kaki",
        "Punggung terlalu membungkuk",
      ],
    ),
    Exercise(
      name: "Plank",
      gif: "https://media.giphy.com/media/3o85xDf6Ur790FD5VC/giphy.gif",
      desc: "Latihan isometrik statik terbaik untuk membangun kekuatan inti (core), stabilitas seluruh tubuh, dan postur.",
      muscle: "Inti, Perut, Punggung Bawah",
      difficulty: "Menengah",
      target: "3 Set x 30 Sec",
      tips: [
        "Jaga tubuh tetap lurus horizontal dari kepala ke tumit",
        "Letakkan siku sejajar tepat di bawah bahu",
        "Kontraksikan perut dan bokong secara aktif",
      ],
      mistakes: [
        "Pinggul terlalu naik atau terlalu melorot turun",
        "Menjatuhkan kepala/leher tidak netral",
        "Lutut menyentuh lantai/tidak diangkat penuh",
      ],
    ),
    Exercise(
      name: "Lunge",
      gif: "https://media.giphy.com/media/l4pTfx2qLszoacZRS/giphy.gif",
      desc: "Latihan unilateral terbaik untuk membangun kekuatan kaki, keseimbangan, dan stabilitas pinggul.",
      muscle: "Kaki, Bokong, Paha",
      difficulty: "Menengah",
      target: "3 Set x 10 Reps (per kaki)",
      tips: [
        "Lutut depan tidak melewati jari kaki",
        "Jaga punggung tetap tegak lurus",
        "Turun hingga lutut belakang hampir menyentuh lantai",
      ],
      mistakes: [
        "Lutut depan terlalu maju melebihi jari kaki",
        "Badan condong ke depan",
        "Lutut belakang menyentuh lantai",
      ],
    ),
    Exercise(
      name: "Burpee",
      gif: "https://media.giphy.com/media/14gMTHGoPAUytC/giphy.gif",
      desc: "Latihan full-body intensif yang menggabungkan squat, plank, push-up, dan lompatan untuk kardio maksimal.",
      muscle: "Full Body, Kardio",
      difficulty: "Lanjutan",
      target: "3 Set x 8 Reps",
      tips: [
        "Lakukan gerakan dengan ritme yang konsisten",
        "Lompat setinggi mungkin di akhir gerakan",
        "Jaga core tight saat posisi plank",
      ],
      mistakes: [
        "Pinggul terlalu rendah saat posisi plank",
        "Tidak melompat di akhir gerakan",
        "Gerakan terlalu lambat tanpa intensitas",
      ],
    ),
    Exercise(
      name: "Mountain Climber",
      gif: "https://media.giphy.com/media/3o7TKMt1VVNkHV2PaE/giphy.gif",
      desc: "Latihan kardio intensif yang menargetkan otot inti sambil meningkatkan detak jantung.",
      muscle: "Inti, Kardio, Kaki",
      difficulty: "Menengah",
      target: "3 Set x 20 Reps",
      tips: [
        "Jaga pinggul tetap rendah dan stabil",
        "Gerakkan lutut bergantian dengan cepat",
        "Pertahankan posisi plank yang kuat",
      ],
      mistakes: [
        "Pinggul terlalu naik turun",
        "Gerakan lutut terlalu lambat",
        "Bahu tidak sejajar dengan pergelangan tangan",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Panduan Latihan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final e = exercises[index];

            return GestureDetector(
              onTap: () => Get.to(() => ExerciseDetailPage(exercise: e)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [surfaceColor, surfaceColor.withValues(alpha: 0.85), const Color(0xFF141724)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: accentGreen.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thumbnail
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            e.gif,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center,
                              color: Colors.white38,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + difficulty badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: e.difficulty == "Pemula"
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : Colors.orange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: e.difficulty == "Pemula"
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : Colors.orange.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    e.difficulty,
                                    style: TextStyle(
                                      color: e.difficulty == "Pemula"
                                          ? Colors.greenAccent
                                          : Colors.orangeAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Muscle group
                            Row(
                              children: [
                                const Icon(Icons.fitness_center_rounded, size: 12, color: accentGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e.muscle,
                                    style: const TextStyle(
                                      color: accentGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Sets / reps
                            Row(
                              children: [
                                const Icon(Icons.repeat_rounded, size: 12, color: Colors.white38),
                                const SizedBox(width: 6),
                                Text(
                                  e.target,
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
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
          // GIF
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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

          // STATS BAR
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Kesulitan",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.difficulty,
                        style: TextStyle(
                          color: exercise.difficulty == "Pemula"
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Target Latihan",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.target,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DESCRIPTION
          _card(
            title: "Deskripsi",
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF29B6F6),
            child: Text(
              exercise.desc,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // MUSCLE
          _card(
            title: "Otot yang Dilatih",
            icon: Icons.fitness_center_rounded,
            iconColor: accentPurple,
            child: Text(
              exercise.muscle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TIPS
          _card(
            title: "Tips Pro",
            icon: Icons.check_circle_outline_rounded,
            iconColor: accentGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.tips
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(
                              Icons.circle,
                              color: accentGreen,
                              size: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // MISTAKES
          _card(
            title: "Kesalahan Umum",
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF76A6A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.mistakes
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(
                              Icons.close,
                              color: Color(0xFFF76A6A),
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 32),

          // BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: accentGreen.withValues(alpha: 0.4),
              ),
              onPressed: () {
                showCustomSnackbar(
                  title: "Ditambahkan ke Latihan",
                  message: "${exercise.name} berhasil ditambahkan ke jadwal latihan Anda!",
                  backgroundColor: surfaceColor,
                );
              },
              child: const Text(
                "Tambah ke Latihan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
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
          child,
        ],
      ),
    );
  }
}
