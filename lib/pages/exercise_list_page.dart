import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'warmup_page.dart';

class Exercise {
  final String name;
  final String gif;
  final String desc;
  final String muscle;
  final String category;
  final String difficulty; // 'beginner' | 'intermediate' | 'advanced'
  final String exerciseType;
  final String poseAngle;
  final int defaultSets;
  final int defaultReps;
  final List<String> tips;
  final List<String> mistakes;

  Exercise({
    required this.name,
    required this.gif,
    required this.desc,
    required this.muscle,
    required this.category,
    required this.difficulty,
    required this.exerciseType,
    required this.poseAngle,
    required this.defaultSets,
    required this.defaultReps,
    required this.tips,
    required this.mistakes,
  });
}

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  String _selectedCategory = 'Semua';

  static final exercises = [
    Exercise(
      name: "Push Up",
      gif: "https://media.giphy.com/media/XIqCQx02E1U9W/giphy.gif",
      desc: "Latihan fundamental untuk membangun kekuatan tubuh bagian atas, khususnya otot dada, bahu, dan triceps.",
      muscle: "Chest, Shoulder, Triceps",
      category: "Upper Body",
      difficulty: "beginner",
      exerciseType: "pushup",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 15,
      tips: ["Jaga punggung lurus seperti papan", "Turun perlahan dengan terkontrol", "Posisi tangan sedikit lebih lebar dari bahu"],
      mistakes: ["Pinggul turun menyentuh lantai", "Gerakan terlalu cepat", "Leher mendongak ke depan"],
    ),
    Exercise(
      name: "Sit Up",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan klasik untuk mengencangkan otot perut dan membangun kekuatan core.",
      muscle: "Abs, Core, Hip Flexors",
      category: "Core",
      difficulty: "beginner",
      exerciseType: "situp",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 15,
      tips: ["Angkat badan sampai siku menyentuh lutut", "Jaga leher tetap netral", "Kontrol gerakan naik dan turun"],
      mistakes: ["Menarik leher dengan tangan", "Gerakan terlalu cepat", "Tidak naik cukup tinggi"],
    ),
    Exercise(
      name: "Squat",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan utama untuk membangun kekuatan lower body, khususnya otot kaki dan glutes.",
      muscle: "Quads, Glutes, Hamstring",
      category: "Lower Body",
      difficulty: "beginner",
      exerciseType: "squat",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 12,
      tips: ["Turun sampai paha sejajar lantai", "Jaga lutut tetap stabil", "Berat badan bertumpu pada tumit"],
      mistakes: ["Lutut menekuk ke dalam", "Kedalaman squat kurang", "Punggung terlalu membungkuk"],
    ),
    Exercise(
      name: "Plank",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan isometrik untuk memperkuat core, stability, dan postur tubuh secara keseluruhan.",
      muscle: "Core, Lower Back, Shoulder",
      category: "Core",
      difficulty: "beginner",
      exerciseType: "plank",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 30,
      tips: ["Jaga tubuh lurus dari kepala sampai kaki", "Kencangkan otot perut", "Bernapas dengan normal"],
      mistakes: ["Pinggul terlalu naik", "Pinggul turun ke lantai", "Menahan napas"],
    ),
    Exercise(
      name: "Lunge",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan unilateral untuk membangun kekuatan dan keseimbangan kaki serta glutes.",
      muscle: "Quads, Glutes, Hamstring",
      category: "Lower Body",
      difficulty: "intermediate",
      exerciseType: "lunge",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 12,
      tips: ["Langkah cukup lebar ke depan", "Turunkan lutut belakang hampir menyentuh lantai", "Jaga torso tetap tegak"],
      mistakes: ["Lutut depan melewati jari kaki", "Torso terlalu condong ke depan", "Langkah terlalu pendek"],
    ),
    Exercise(
      name: "Burpee",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan full-body intensitas tinggi yang membakar kalori dan meningkatkan kardiovaskular.",
      muscle: "Full Body, Cardio",
      category: "Cardio",
      difficulty: "advanced",
      exerciseType: "burpee",
      poseAngle: "front",
      defaultSets: 3,
      defaultReps: 10,
      tips: ["Mulai dari posisi berdiri", "Transisi halus antara squat dan plank", "Lompat setinggi mungkin di akhir"],
      mistakes: ["Melewatkan posisi plank", "Punggung melengkung saat plank", "Tidak melompat di akhir"],
    ),
    Exercise(
      name: "Mountain Climber",
      gif: "https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif",
      desc: "Latihan dinamis dalam posisi plank yang melatih core, shoulder, dan kardiovaskular.",
      muscle: "Core, Shoulder, Cardio",
      category: "Cardio",
      difficulty: "intermediate",
      exerciseType: "mountain_climber",
      poseAngle: "side",
      defaultSets: 3,
      defaultReps: 20,
      tips: ["Jaga pinggul tetap rendah", "Tarik lutut bergantian ke arah dada", "Pertahankan posisi plank yang solid"],
      mistakes: ["Pinggul terlalu naik", "Gerakan terlalu cepat tanpa kontrol", "Lutut tidak ditarik cukup jauh"],
    ),
  ];

  static const _categories = ['Semua', 'Upper Body', 'Lower Body', 'Core', 'Cardio'];

  List<Exercise> get _filtered => _selectedCategory == 'Semua'
      ? exercises
      : exercises.where((e) => e.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text(
          "Workout Guide",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Category Filter ────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF7C6AF7) : const Color(0xFF222434),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? const Color(0xFF7C6AF7) : Colors.white10,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // ── Exercise List ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final e = _filtered[index];
                return _ExerciseCard(
                  exercise: e,
                  onTap: () => Get.to(() => ExerciseDetailPage(exercise: e)),
                  onStart: () => _startExercise(e),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startExercise(Exercise e) {
    final workoutExercise = WorkoutExercise(
      name: e.name,
      description: e.desc,
      sets: e.defaultSets,
      reps: e.defaultReps,
      muscleGroup: e.muscle,
      poseAngle: e.poseAngle,
      exerciseType: e.exerciseType,
    );
    // Navigate directly to warmup with single-exercise plan
    Get.to(() => WarmupPage(workoutPlan: [workoutExercise]));
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onStart;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF222434),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  exercise.gif,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF171925),
                    child: const Icon(Icons.fitness_center, color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Difficulty badge
                      _DifficultyBadge(difficulty: exercise.difficulty),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscle,
                    style: const TextStyle(
                      color: Color(0xFF6CC551),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${exercise.defaultSets}×${exercise.defaultReps}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6AF7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exercise.category,
                          style: const TextStyle(
                            color: Color(0xFF7C6AF7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Start button
            GestureDetector(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6CC551).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF6CC551), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      'beginner' => ('Pemula', const Color(0xFF6CC551)),
      'intermediate' => ('Menengah', const Color(0xFFFFA726)),
      'advanced' => ('Lanjutan', const Color(0xFFF76A6A)),
      _ => ('Pemula', const Color(0xFF6CC551)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── DETAIL PAGE ────────────────────────────────────────────────

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: Text(exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              color: const Color(0xFF222434),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
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
          const SizedBox(height: 16),
          // Badges row
          Row(
            children: [
              _DifficultyBadge(difficulty: exercise.difficulty),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6AF7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(exercise.category, style: const TextStyle(color: Color(0xFF7C6AF7), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${exercise.defaultSets}×${exercise.defaultReps}', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _card(
            title: "Deskripsi",
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF29B6F6),
            child: Text(exercise.desc, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          ),
          const SizedBox(height: 16),
          _card(
            title: "Target Otot",
            icon: Icons.fitness_center_rounded,
            iconColor: const Color(0xFF7C6AF7),
            child: Text(exercise.muscle, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          _card(
            title: "Pro Tips",
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF6CC551),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.tips.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.circle, color: Color(0xFF6CC551), size: 6)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: "Kesalahan Umum",
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF76A6A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.mistakes.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.close, color: Color(0xFFF76A6A), size: 12)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CC551),
                foregroundColor: const Color(0xFF101216),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: const Color(0xFF6CC551).withValues(alpha: 0.4),
              ),
              onPressed: () {
                final workoutExercise = WorkoutExercise(
                  name: exercise.name,
                  description: exercise.desc,
                  sets: exercise.defaultSets,
                  reps: exercise.defaultReps,
                  muscleGroup: exercise.muscle,
                  poseAngle: exercise.poseAngle,
                  exerciseType: exercise.exerciseType,
                );
                Get.to(() => WarmupPage(workoutPlan: [workoutExercise]));
              },
              child: const Text("Mulai Latihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
