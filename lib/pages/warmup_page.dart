import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'workout_session_page.dart';

// ─────────────────────────────────────────────────────────────
// DATA: Workout plan yang diteruskan ke session setelah warmup
// ─────────────────────────────────────────────────────────────
class WorkoutExercise {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final String muscleGroup;
  final String poseAngle;    // 'side', 'front', 'back'
  final String exerciseType; // 'pushup' | 'situp' | 'squat' | 'plank' | 'other'

  const WorkoutExercise({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.muscleGroup,
    required this.poseAngle,
    this.exerciseType = 'other',
  });
}

// ─────────────────────────────────────────────────────────────
// WARMUP PAGE
// ─────────────────────────────────────────────────────────────
class WarmupPage extends StatefulWidget {
  final List<WorkoutExercise> workoutPlan;

  const WarmupPage({
    super.key,
    required this.workoutPlan,
  });

  @override
  State<WarmupPage> createState() => _WarmupPageState();
}

class _WarmupPageState extends State<WarmupPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  bool _videoReady = false;
  bool _videoError = false;
  bool _navigated = false;

  // URL video pemanasan — YouTube embed tidak bisa, pakai MP4 langsung
  // Ganti dengan URL video pemanasan yang sesuai
  static const _warmupVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4';

  @override
  void initState() {
    super.initState();

    // Pulse animation untuk loading state
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.6, end: 1.0).animate(_pulseCtrl);

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.networkUrl(
      Uri.parse(_warmupVideoUrl),
    );

    try {
      await _videoCtrl.initialize();
      _videoCtrl.setLooping(false);
      _videoCtrl.play();

      // Listener: ketika video selesai → navigasi ke session
      _videoCtrl.addListener(_onVideoUpdate);

      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _navigated) return;
    final pos = _videoCtrl.value.position;
    final dur = _videoCtrl.value.duration;
    if (dur.inSeconds > 0 && pos >= dur - const Duration(milliseconds: 300)) {
      _navigated = true;
      _goToSession();
    }
  }

  void _goToSession() {
    Get.off(
      () => WorkoutSessionPage(workoutPlan: widget.workoutPlan),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _videoCtrl.removeListener(_onVideoUpdate);
    _videoCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          // ── VIDEO / PLACEHOLDER ────────────────────────────
          _buildVideoLayer(),

          // ── GRADIENT OVERLAY ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 0.75, 1.0],
                colors: [
                  Color(0xCC0A0C10),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xF20A0C10),
                ],
              ),
            ),
          ),

          // ── TOP BAR ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PillBadge(
                    icon: Icons.self_improvement_rounded,
                    label: 'Warm Up',
                    color: const Color(0xFF7C6AF7),
                  ),
                  GestureDetector(
                    onTap: _goToSession,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM INFO ────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    const Text(
                      'Sesi Pemanasan',
                      style: TextStyle(
                        color: Color(0xFF7C6AF7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ikuti gerakan pemanasan\nsebelum mulai latihan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Video progress bar
                    if (_videoReady) _buildProgressBar(),

                    const SizedBox(height: 20),

                    // Workout preview chips
                    _buildWorkoutPreview(),

                    const SizedBox(height: 24),

                    // Mulai sekarang button (manual skip)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6CC551),
                          foregroundColor: const Color(0xFF0A0C10),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mulai Workout Sekarang',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_videoError) {
      // Fallback: gradient background saat video gagal load
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1830), Color(0xFF0D0F14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _pulseAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6AF7).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      size: 40, color: Color(0xFF7C6AF7)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Siapkan dirimu...',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_videoReady) {
      return Container(
        color: const Color(0xFF0D0F14),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7C6AF7),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoCtrl.value.size.width,
          height: _videoCtrl.value.size.height,
          child: VideoPlayer(_videoCtrl),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder(
      valueListenable: _videoCtrl,
      builder: (_, VideoPlayerValue val, __) {
        final total = val.duration.inMilliseconds;
        final current = val.position.inMilliseconds;
        final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(val.position),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  _formatDuration(val.duration),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6AF7)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutPreview() {
    return Row(
      children: widget.workoutPlan.take(3).map((e) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              e.name,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PillBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
