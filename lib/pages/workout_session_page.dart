import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'warmup_page.dart';
import 'pose_camera_page.dart';

// ─────────────────────────────────────────────────────────────
// WORKOUT SESSION PAGE
// Menampilkan daftar latihan satu per satu dengan timer & counter
// ─────────────────────────────────────────────────────────────
class WorkoutSessionPage extends StatefulWidget {
  final List<WorkoutExercise> workoutPlan;

  const WorkoutSessionPage({super.key, required this.workoutPlan});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _currentSet = 1;
  bool _resting = false;
  int _restSeconds = 0;

  static const _restDuration = 30; // detik istirahat antar set

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _updateProgress();
  }

  void _updateProgress() {
    final total = widget.workoutPlan.length;
    final progress =
        (_currentIndex + (_currentSet - 1) / _currentExercise.sets) / total;
    _progressCtrl.animateTo(progress.clamp(0.0, 1.0));
  }

  WorkoutExercise get _currentExercise => widget.workoutPlan[_currentIndex];

  bool get _isLastSet => _currentSet >= _currentExercise.sets;
  bool get _isLastExercise => _currentIndex >= widget.workoutPlan.length - 1;

  void _onSetDone() {
    if (_isLastSet) {
      if (_isLastExercise) {
        _finishWorkout();
      } else {
        setState(() {
          _currentIndex++;
          _currentSet = 1;
        });
        _updateProgress();
      }
    } else {
      // Mulai istirahat
      setState(() {
        _resting = true;
        _restSeconds = _restDuration;
      });
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_restSeconds <= 1) {
        setState(() {
          _resting = false;
          _currentSet++;
        });
        _updateProgress();
        return false;
      }
      setState(() => _restSeconds--);
      return true;
    });
  }

  void _skipRest() {
    setState(() {
      _resting = false;
      _currentSet++;
    });
    _updateProgress();
  }

  void _finishWorkout() {
    Get.back(); // kembali ke WorkoutList
    Get.snackbar(
      'Workout Selesai',
      'Mantap! Latihan hari ini sudah tercatat.',
      backgroundColor: const Color(0xFF222434),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Color(0xFF6CC551)),
      duration: const Duration(seconds: 3),
    );
  }

  void _openCamera() {
    Get.to(
      () => PoseCameraPage(exercise: _currentExercise),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ───────────────────────────────────────
            _buildTopBar(),

            // ── PROGRESS ──────────────────────────────────────
            _buildGlobalProgress(),

            // ── CONTENT ───────────────────────────────────────
            Expanded(
              child: _resting ? _buildRestScreen() : _buildExerciseScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2030),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2F45)),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Exercise ${_currentIndex + 1} of ${widget.workoutPlan.length}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6CC551)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── EXERCISE SCREEN ──────────────────────────────────────

  Widget _buildExerciseScreen() {
    final exercise = _currentExercise;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise card header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2030), Color(0xFF161824)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CC551).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFF6CC551),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.muscleGroup,
                        style: const TextStyle(
                          color: Color(0xFF6CC551),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Set progress
          _buildSetProgress(exercise),

          const SizedBox(height: 20),

          // Reps counter card
          _buildRepsCard(exercise),

          const SizedBox(height: 20),

          // Upcoming exercises
          _buildUpcomingList(),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Camera button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openCamera,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF7C6AF7),
                  ),
                  label: const Text(
                    'Cek Postur',
                    style: TextStyle(color: Color(0xFF7C6AF7)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF7C6AF7),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Done button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _onSetDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CC551),
                    foregroundColor: const Color(0xFF0A0C10),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLastSet && _isLastExercise
                        ? 'Selesai Workout'
                        : 'Set $_currentSet Selesai',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetProgress(WorkoutExercise exercise) {
    return Row(
      children: List.generate(exercise.sets, (i) {
        final done = i < _currentSet - 1;
        final current = i == _currentSet - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < exercise.sets - 1 ? 8 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF6CC551)
                    : current
                    ? const Color(0xFF6CC551).withValues(alpha: 0.4)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRepsCard(WorkoutExercise exercise) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            'Set $_currentSet / ${exercise.sets}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${exercise.reps}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                exercise.name == 'Plank' ? 'detik' : 'reps',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    final upcoming = widget.workoutPlan.sublist(_currentIndex + 1);
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELANJUTNYA',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ...upcoming
            .take(2)
            .map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF161824),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C6AF7).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.name,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${e.sets} set × ${e.reps}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  // ─── REST SCREEN ──────────────────────────────────────────

  Widget _buildRestScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Countdown ring
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _restSeconds / _restDuration,
                      strokeWidth: 6,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF7C6AF7),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_restSeconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'detik',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Istirahat Sejenak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set $_currentSet selesai! Ambil napas\nsebelum set berikutnya.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: _skipRest,
              child: const Text(
                'Lewati Istirahat',
                style: TextStyle(
                  color: Color(0xFF6CC551),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
