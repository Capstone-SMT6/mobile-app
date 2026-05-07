import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detector_service.dart';
import 'warmup_page.dart';

// ─────────────────────────────────────────────────────────────
// POSE CAMERA PAGE
// Kamera live + ML Kit MediaPipe pose detection on-device
// Logic: port dari Python push-up counter kamu
// ─────────────────────────────────────────────────────────────
class PoseCameraPage extends StatefulWidget {
  final WorkoutExercise exercise;

  const PoseCameraPage({super.key, required this.exercise});

  @override
  State<PoseCameraPage> createState() => _PoseCameraPageState();
}

class _PoseCameraPageState extends State<PoseCameraPage>
    with TickerProviderStateMixin {
  // ── Camera ────────────────────────────────────────────────
  CameraController? _cameraCtrl;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _cameraError = false;
  bool _isFrontCamera = false;

  // ── ML Kit ────────────────────────────────────────────────
  final _service = PoseDetectorService();
  bool _isProcessing = false;  // throttle: skip frame jika masih proses
  PushUpAnalysis? _lastAnalysis;

  // ── Image dimensions (untuk pose overlay) ─────────────────
  Size _imageSize = Size.zero;

  // ── Animations ────────────────────────────────────────────
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    _service.init();
    _service.reset(); // reset counter tiap buka page

    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _feedbackScale = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut),
    );

    _initCamera();
  }

  // ─── INISIALISASI KAMERA ───────────────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraError = true);
        return;
      }
      await _startCamera(false);
    } catch (_) {
      if (mounted) setState(() => _cameraError = true);
    }
  }

  Future<void> _startCamera(bool useFront) async {
    if (mounted) setState(() => _cameraReady = false);

    // Pilih kamera depan atau belakang
    CameraDescription? selectedCamera;
    for (final cam in _cameras) {
      if (useFront && cam.lensDirection == CameraLensDirection.front) {
        selectedCamera = cam;
        break;
      } else if (!useFront && cam.lensDirection == CameraLensDirection.back) {
        selectedCamera = cam;
        break;
      }
    }
    selectedCamera ??= _cameras.first;

    final ctrl = CameraController(
      selectedCamera,
      ResolutionPreset.medium, // medium = 480p, lebih ringan untuk ML Kit
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Android format untuk ML Kit
    );

    await _cameraCtrl?.stopImageStream();
    await _cameraCtrl?.dispose();

    try {
      await ctrl.initialize();
      if (!mounted) return;

      _cameraCtrl = ctrl;
      _isFrontCamera = useFront;

      // ── Mulai stream frame ke ML Kit ───────────────────────
      await ctrl.startImageStream(_processFrame);

      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraError = true);
    }
  }

  // ─── PROCESS SETIAP FRAME KAMERA → ML Kit ─────────────────
  Future<void> _processFrame(CameraImage image) async {
    // Throttle: lewati frame jika masih memproses
    if (_isProcessing || !mounted) return;
    _isProcessing = true;

    try {
      final sensorOrientation =
          _cameraCtrl!.description.sensorOrientation;

      // Simpan ukuran image untuk koordinat overlay
      if (_imageSize == Size.zero) {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      }

      // Konversi CameraImage → InputImage
      final inputImage = cameraImageToInputImage(
        image,
        sensorOrientation,
        _isFrontCamera,
      );
      if (inputImage == null) return;

      // Jalankan pose detection on-device
      final analysis = await _service.processImage(inputImage);

      if (mounted && analysis != null) {
        final prevReps = _lastAnalysis?.repCount ?? 0;
        setState(() => _lastAnalysis = analysis);

        // Animasi feedback saat rep baru
        if (analysis.repCount > prevReps) {
          _feedbackCtrl.forward(from: 0);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    await _startCamera(!_isFrontCamera);
  }

  @override
  void dispose() {
    _cameraCtrl?.stopImageStream();
    _cameraCtrl?.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── LAYER 1: Camera preview ─────────────────────
          _buildCameraLayer(),

          // ── LAYER 2: Pose skeleton overlay ──────────────
          if (_cameraReady && _lastAnalysis != null)
            _buildPoseOverlay(),

          // ── LAYER 3: Top gradient ────────────────────────
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xDD000000), Colors.transparent],
              ),
            ),
          ),

          // ── LAYER 4: Bottom gradient ─────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xEE000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── LAYER 5: Top bar ─────────────────────────────
          _buildTopBar(),

          // ── LAYER 6: Bottom panel (counter & feedback) ───
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  // ─── CAMERA LAYER ──────────────────────────────────────────
  Widget _buildCameraLayer() {
    if (_cameraError) {
      return Container(
        color: const Color(0xFF0D0F14),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white24),
              SizedBox(height: 16),
              Text('Kamera tidak tersedia',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
              SizedBox(height: 8),
              Text('Pastikan izin kamera sudah diberikan',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (!_cameraReady || _cameraCtrl == null) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF7C6AF7), strokeWidth: 2),
      );
    }

    return SizedBox.expand(child: CameraPreview(_cameraCtrl!));
  }

  // ─── POSE SKELETON OVERLAY ─────────────────────────────────
  Widget _buildPoseOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: screenSize,
          painter: PosePainter(
            poses: _lastAnalysis!.poses,
            imageSize: _imageSize,
            screenSize: screenSize,
            isFrontCamera: _isFrontCamera,
            sensorOrientation:
                _cameraCtrl?.description.sensorOrientation ?? 90,
            feedback: _lastAnalysis!.feedback,
            isGoodPosture: _lastAnalysis!.isGoodPosture,
          ),
        );
      },
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _CircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.exercise.muscleGroup,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Angle badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6AF7).withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF7C6AF7).withValues(alpha:0.4)),
              ),
              child: Text(
                'Tampak ${widget.exercise.poseAngle == 'side' ? 'Samping' : 'Depan'}',
                style: const TextStyle(
                    color: Color(0xFF7C6AF7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            // Flip camera
            if (_cameras.length > 1)
              _CircleButton(
                icon: Icons.flip_camera_android_rounded,
                onTap: _toggleCamera,
              ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM PANEL ──────────────────────────────────────────
  Widget _buildBottomPanel() {
    final analysis = _lastAnalysis;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Stats row: REPS + STAGE + angles ───────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // REPS counter
                  _StatBox(
                    label: 'REPS',
                    value: '${analysis?.repCount ?? 0}',
                    color: const Color(0xFF6CC551),
                    large: true,
                  ),
                  // Divider
                  Container(
                      width: 1, height: 48, color: Colors.white12),
                  // STAGE
                  _StatBox(
                    label: 'STAGE',
                    value: (analysis?.stage ?? 'up').toUpperCase(),
                    color: analysis?.stage == 'down'
                        ? const Color(0xFFF76A6A)
                        : Colors.white,
                  ),
                  Container(
                      width: 1, height: 48, color: Colors.white12),
                  // Elbow angle
                  _StatBox(
                    label: 'SIKU',
                    value:
                        '${analysis?.elbowAngle.toStringAsFixed(0) ?? '--'}°',
                    color: Colors.white70,
                  ),
                  Container(
                      width: 1, height: 48, color: Colors.white12),
                  // Hip angle
                  _StatBox(
                    label: 'PINGGUL',
                    value:
                        '${analysis?.hipAngle.toStringAsFixed(0) ?? '--'}°',
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Feedback banner ─────────────────────────────
            ScaleTransition(
              scale: _feedbackScale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: analysis == null
                      ? Colors.black54
                      : analysis.isGoodPosture
                          ? const Color(0xFF6CC551).withValues(alpha:0.85)
                          : const Color(0xFFF76A6A).withValues(alpha:0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      analysis == null
                          ? Icons.sensors_rounded
                          : analysis.isGoodPosture
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      analysis?.feedback ??
                          'Mendeteksi pose...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Tips & Reset ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.exercise.description,
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.3),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _service.reset();
                    setState(() => _lastAnalysis = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: Colors.white60, size: 22),
                        SizedBox(height: 4),
                        Text('Reset',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Gambar skeleton pose dari ML Kit landmarks
// Sama seperti mp_drawing.draw_landmarks() di Python
// ─────────────────────────────────────────────────────────────
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size screenSize;
  final bool isFrontCamera;
  final int sensorOrientation;
  final String feedback;
  final bool isGoodPosture;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.screenSize,
    required this.isFrontCamera,
    required this.sensorOrientation,
    required this.feedback,
    required this.isGoodPosture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final goodColor = const Color(0xFF6CC551);
    final badColor = const Color(0xFFF76A6A);
    final neutralColor = const Color(0xFF7C6AF7);

    final accentColor = isGoodPosture ? goodColor : badColor;

    // Paint untuk garis skeleton
    final bonePaint = Paint()
      ..color = neutralColor.withValues(alpha:0.7)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Paint untuk joint (titik)
    final jointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Paint khusus joint yang dianalisis
    final keyJointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      final lm = pose.landmarks;

      // ── Gambar semua koneksi skeleton ───────────────────
      _drawConnections(canvas, lm, bonePaint, size);

      // ── Gambar semua joint ──────────────────────────────
      for (final landmark in lm.values) {
        if (landmark.likelihood < 0.5) continue;
        final point = _toScreen(landmark, size);

        // Joint biasa
        canvas.drawCircle(point, 5, jointPaint);
        // Lingkaran luar
        canvas.drawCircle(
          point,
          7,
          Paint()
            ..color = Colors.white.withValues(alpha:0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // ── Highlight joint kunci (shoulder, elbow, wrist, hip, ankle) ──
      final keyLandmarks = [
        lm[PoseLandmarkType.leftShoulder],
        lm[PoseLandmarkType.leftElbow],
        lm[PoseLandmarkType.leftWrist],
        lm[PoseLandmarkType.leftHip],
        lm[PoseLandmarkType.leftAnkle],
      ];

      for (final landmark in keyLandmarks) {
        if (landmark == null || landmark.likelihood < 0.5) continue;
        final point = _toScreen(landmark, size);
        canvas.drawCircle(point, 8, keyJointPaint);
        canvas.drawCircle(
          point,
          11,
          Paint()
            ..color = accentColor.withValues(alpha:0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // ── Gambar label sudut di siku ───────────────────────
      _drawAngleLabel(canvas, lm, size, accentColor);
    }
  }

  // Konversi normalized landmark [0..1] → koordinat layar
  Offset _toScreen(PoseLandmark landmark, Size size) {
    double x = landmark.x;
    double y = landmark.y;

    // Mirror untuk kamera depan
    if (isFrontCamera) x = 1.0 - x;

    // Untuk Android (sensorOrientation=90), image adalah landscape
    // tapi preview ditampilkan portrait — swap x/y
    if (sensorOrientation == 90 || sensorOrientation == 270) {
      final tmpX = x;
      x = y;
      y = tmpX;
      if (sensorOrientation == 90) {
        x = 1.0 - x;
      } else {
        y = 1.0 - y;
      }
    }

    return Offset(x * size.width, y * size.height);
  }

  void _drawConnections(
    Canvas canvas,
    Map<PoseLandmarkType, PoseLandmark> lm,
    Paint paint,
    Size size,
  ) {
    // Koneksi skeleton utama (sama seperti POSE_CONNECTIONS di MediaPipe)
    final connections = [
      // Torso
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      // Lengan kiri
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      // Lengan kanan
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      // Kaki kiri
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      // Kaki kanan
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final conn in connections) {
      final a = lm[conn[0]];
      final b = lm[conn[1]];
      if (a == null || b == null) continue;
      if (a.likelihood < 0.5 || b.likelihood < 0.5) continue;

      canvas.drawLine(
        _toScreen(a, size),
        _toScreen(b, size),
        paint,
      );
    }
  }

  void _drawAngleLabel(
    Canvas canvas,
    Map<PoseLandmarkType, PoseLandmark> lm,
    Size size,
    Color color,
  ) {
    final elbow = lm[PoseLandmarkType.leftElbow];
    final hip = lm[PoseLandmarkType.leftHip];

    // Label di titik siku
    if (elbow != null && elbow.likelihood > 0.5) {
      _drawTextLabel(
        canvas,
        _toScreen(elbow, size).translate(10, -20),
        'Siku',
        color,
      );
    }

    // Label di titik pinggul
    if (hip != null && hip.likelihood > 0.5) {
      _drawTextLabel(
        canvas,
        _toScreen(hip, size).translate(10, -20),
        'Pinggul',
        color,
      );
    }
  }

  void _drawTextLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(PosePainter old) =>
      old.poses != poses ||
      old.isGoodPosture != isGoodPosture ||
      old.feedback != feedback;
}

// ─────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: large ? 36 : 22,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
