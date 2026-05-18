import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detector_service.dart';
import '../utils/device_diagnostics.dart';
import 'pose_camera_page.dart';

class CalibrationPage extends StatefulWidget {
  final WorkoutExercise exercise;

  const CalibrationPage({super.key, required this.exercise});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  CameraController? _cameraCtrl;
  bool _cameraReady = false;
  
  // Calibration steps
  int _currentStep = 0;
  final List<String> _steps = [
    'Device Check',
    'Lighting Check',
    'Position Check',
    'Ready!',
  ];
  
  // Diagnostics
  final _diagnostics = DeviceDiagnostics();
  bool _diagnosticsComplete = false;
  
  // Pose detection untuk position check
  final _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );
  
  bool _isProcessing = false;
  bool _poseDetected = false;
  bool _isWellFramed = false;
  int _lightingCheckFrames = 0;
  Timer? _calibrationTimer;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _initializeCalibration();
  }
  
  Future<void> _initializeCalibration() async {
    // Step 1: Device diagnostics
    await _diagnostics.initialize();
    
    setState(() {
      _diagnosticsComplete = true;
      _currentStep = 1;
    });
    
    // Auto-proceed ke lighting check setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _startCamera();
    });
  }
  
  Future<void> _startCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    // Use back camera
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    
    // Use recommended settings
    final settings = _diagnostics.getRecommendedSettings();
    
    _cameraCtrl = CameraController(
      camera,
      settings['resolution'] as ResolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    
    await _cameraCtrl!.initialize();
    
    if (!mounted) return;
    
    setState(() => _cameraReady = true);
    
    // Start image stream untuk lighting & pose check
    await _cameraCtrl!.startImageStream(_processCalibrationFrame);
  }
  
  Future<void> _processCalibrationFrame(CameraImage image) async {
    if (_isProcessing || !mounted) return;
    _isProcessing = true;
    
    try {
      // Step 2: Lighting check (analyze 10 frames)
      if (_currentStep == 1 && _lightingCheckFrames < 10) {
        await _diagnostics.analyzeLighting(image);
        _lightingCheckFrames++;
        
        if (_lightingCheckFrames >= 10) {
          setState(() => _currentStep = 2);
          
          // Show warning jika lighting kurang bagus
          if (_diagnostics.currentBrightness < 0.3) {
            _showLightingWarning('Ruangan terlalu gelap. Nyalakan lampu untuk hasil terbaik.');
          } else if (_diagnostics.currentBrightness > 0.85) {
            _showLightingWarning('Terlalu terang. Hindari cahaya langsung ke kamera.');
          }
        }
      }
      
      // Step 3: Position check (detect full body pose)
      if (_currentStep == 2) {
        final sensorOrientation = _cameraCtrl!.description.sensorOrientation;
        final inputImage = cameraImageToInputImage(image, sensorOrientation, false);
        
        if (inputImage != null) {
          final poses = await _poseDetector.processImage(inputImage);
          
          if (poses.isNotEmpty) {
            final pose = poses.first;
            
            // Check apakah semua landmark penting terdeteksi dengan confidence tinggi
            final requiredLandmarks = switch (widget.exercise.exerciseType) {
              'situp' => [
                  PoseLandmarkType.leftShoulder,
                  PoseLandmarkType.leftHip,
                  PoseLandmarkType.leftKnee,
                  PoseLandmarkType.leftAnkle,
                ],
              'squat' => [
                  PoseLandmarkType.rightShoulder,
                  PoseLandmarkType.rightHip,
                  PoseLandmarkType.rightKnee,
                  PoseLandmarkType.rightAnkle,
                ],
              'plank' => [
                  PoseLandmarkType.leftShoulder,
                  PoseLandmarkType.leftElbow,
                  PoseLandmarkType.leftHip,
                  PoseLandmarkType.leftAnkle,
                ],
              _ => [
                  PoseLandmarkType.leftShoulder,
                  PoseLandmarkType.leftElbow,
                  PoseLandmarkType.leftWrist,
                  PoseLandmarkType.leftHip,
                  PoseLandmarkType.leftAnkle,
                ],
            };
            
            final allDetected = requiredLandmarks.every(
              (type) => pose.landmarks[type]?.likelihood ?? 0 > 0.7,
            );
            
            setState(() {
              _poseDetected = allDetected;
              _isWellFramed = allDetected;
            });
            
            // Auto-proceed jika pose detected selama 2 detik
            if (allDetected && _calibrationTimer == null) {
              _calibrationTimer = Timer(const Duration(seconds: 2), () {
                if (mounted && _isWellFramed) {
                  setState(() => _currentStep = 3);
                  
                  // Auto-proceed ke workout setelah 1.5 detik
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    _proceedToWorkout();
                  });
                }
              });
            } else if (!allDetected) {
              _calibrationTimer?.cancel();
              _calibrationTimer = null;
            }
          }
        }
      }
      
    } catch (e) {
      debugPrint('❌ Calibration frame error: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  void _showLightingWarning(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _proceedToWorkout() {
    // Print diagnostic report
    debugPrint(_diagnostics.generateReport());
    
    // Navigate ke workout
    Get.off(() => PoseCameraPage(exercise: widget.exercise));
  }
  
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _calibrationTimer?.cancel();
    _cameraCtrl?.stopImageStream();
    _cameraCtrl?.dispose();
    _poseDetector.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: Stack(
        children: [
          // Camera preview (jika sudah ready)
          if (_cameraReady && _cameraCtrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: CameraPreview(_cameraCtrl!),
              ),
            ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D0F14).withValues(alpha:0.95),
                    const Color(0xFF0D0F14).withValues(alpha:0.85),
                    const Color(0xFF0D0F14).withValues(alpha:0.95),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 40),
                
                // Steps indicator
                _buildStepsIndicator(),
                
                const SizedBox(height: 60),
                
                // Current step content
                Expanded(
                  child: _buildStepContent(),
                ),
                
                // Bottom actions
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kalibrasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.exercise.name,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepsIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF6CC551)
                              : isActive
                                  ? const Color(0xFF7C6AF7)
                                  : Colors.white.withValues(alpha:0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : _getStepIcon(index),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Label
                      Text(
                        _steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Line connector
                if (index < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 32),
                      color: isCompleted
                          ? const Color(0xFF6CC551)
                          : Colors.white.withValues(alpha:0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.smartphone_rounded;
      case 1:
        return Icons.lightbulb_outline_rounded;
      case 2:
        return Icons.accessibility_new_rounded;
      case 3:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
  
  Widget _buildStepContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: switch (_currentStep) {
          0 => _buildDeviceCheckContent(),
          1 => _buildLightingCheckContent(),
          2 => _buildPositionCheckContent(),
          3 => _buildReadyContent(),
          _ => const SizedBox(),
        },
      ),
    );
  }
  
  Widget _buildDeviceCheckContent() {
    if (!_diagnosticsComplete) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF7C6AF7),
          ),
          SizedBox(height: 24),
          Text(
            'Menganalisis perangkat...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _diagnostics.isLowEndDevice
              ? Icons.warning_amber_rounded
              : Icons.check_circle_rounded,
          color: _diagnostics.isLowEndDevice
              ? Colors.orange
              : const Color(0xFF6CC551),
          size: 80,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _diagnostics.deviceModel ?? 'Unknown Device',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _diagnostics.osVersion ?? '',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        if (_diagnostics.isLowEndDevice)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha:0.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Performa terbatas terdeteksi. Pengaturan akan dioptimalkan.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildLightingCheckContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _lightingCheckFrames < 10
              ? Icons.lightbulb_outline_rounded
              : _diagnostics.lightingCondition == 'Good'
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
          color: _lightingCheckFrames < 10
              ? const Color(0xFF7C6AF7)
              : _diagnostics.lightingCondition == 'Good'
                  ? const Color(0xFF6CC551)
                  : Colors.orange,
          size: 80,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _lightingCheckFrames < 10
              ? 'Mengecek pencahayaan...'
              : _diagnostics.lightingCondition,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Brightness bar
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _diagnostics.currentBrightness.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _getBrightnessColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '${(_diagnostics.currentBrightness * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Color _getBrightnessColor() {
    if (_diagnostics.currentBrightness < 0.3 || 
        _diagnostics.currentBrightness > 0.85) {
      return Colors.orange;
    } else if (_diagnostics.currentBrightness >= 0.4 && 
               _diagnostics.currentBrightness <= 0.7) {
      return const Color(0xFF6CC551);
    }
    return const Color(0xFF7C6AF7);
  }
  
  Widget _buildPositionCheckContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _poseDetected
              ? Icons.check_circle_rounded
              : Icons.accessibility_new_rounded,
          color: _poseDetected
              ? const Color(0xFF6CC551)
              : const Color(0xFF7C6AF7),
          size: 80,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _poseDetected
              ? 'Posisi Sempurna!'
              : 'Posisikan tubuh Anda',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          _getPositionGuidance(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        
        if (!_poseDetected) ...[
          const SizedBox(height: 32),
          
          // Visual guide
          _buildPositionGuide(),
        ],
      ],
    );
  }
  
  String _getPositionGuidance() {
    if (_poseDetected) {
      return 'Tubuh Anda terdeteksi dengan sempurna.\nSiap untuk memulai latihan!';
    }
    
    return switch (widget.exercise.exerciseType) {
      'pushup' || 'plank' => 
        'Posisi kamera dari samping.\nPastikan seluruh tubuh dari kepala hingga kaki terlihat.',
      'situp' =>
        'Posisi kamera dari samping.\nBerbaring dengan lutut ditekuk.',
      'squat' =>
        'Posisi kamera dari samping atau depan.\nBerdiri dengan kaki selebar bahu.',
      _ =>
        'Pastikan seluruh tubuh terlihat di kamera.',
    };
  }
  
  Widget _buildPositionGuide() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C6AF7).withValues(alpha:0.5),
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: CustomPaint(
        painter: _PositionGuidePainter(
          exerciseType: widget.exercise.exerciseType,
        ),
      ),
    );
  }
  
  Widget _buildReadyContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.rocket_launch_rounded,
          color: Color(0xFF6CC551),
          size: 80,
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Siap Memulai!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        const Text(
          'Kalibrasi selesai.\nSelamat berlatih!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Skip button
          if (_currentStep < 3)
            Expanded(
              child: OutlinedButton(
                onPressed: _proceedToWorkout,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lewati',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          if (_currentStep < 3) const SizedBox(width: 12),
          
          // Next/Start button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? _proceedToWorkout : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF7C6AF7),
                disabledBackgroundColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3 ? 'Mulai Latihan' : 'Menunggu...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// POSITION GUIDE PAINTER
// ═════════════════════════════════════════════════════════════
class _PositionGuidePainter extends CustomPainter {
  final String exerciseType;
  
  _PositionGuidePainter({required this.exerciseType});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C6AF7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // Simple stick figure based on exercise type
    switch (exerciseType) {
      case 'pushup':
        // Horizontal body
        canvas.drawLine(
          Offset(cx - 40, cy),
          Offset(cx + 40, cy),
          paint,
        );
        // Head
        canvas.drawCircle(Offset(cx + 40, cy), 8, paint);
        // Arms
        canvas.drawLine(Offset(cx - 20, cy), Offset(cx - 20, cy + 20), paint);
        canvas.drawLine(Offset(cx + 20, cy), Offset(cx + 20, cy + 20), paint);
        // Legs
        canvas.drawLine(Offset(cx - 30, cy), Offset(cx - 30, cy - 20), paint);
        
      case 'situp':
        // Body at angle
        canvas.drawLine(Offset(cx, cy + 20), Offset(cx, cy - 10), paint);
        canvas.drawLine(Offset(cx, cy - 10), Offset(cx + 15, cy - 20), paint);
        // Head
        canvas.drawCircle(Offset(cx + 15, cy - 28), 8, paint);
        // Legs
        canvas.drawLine(Offset(cx, cy + 20), Offset(cx - 20, cy + 20), paint);
        canvas.drawLine(Offset(cx - 20, cy + 20), Offset(cx - 20, cy), paint);
        
      case 'squat':
        // Vertical body
        canvas.drawLine(Offset(cx, cy - 30), Offset(cx, cy + 10), paint);
        // Head
        canvas.drawCircle(Offset(cx, cy - 38), 8, paint);
        // Bent legs
        canvas.drawLine(Offset(cx, cy + 10), Offset(cx - 15, cy + 25), paint);
        canvas.drawLine(Offset(cx, cy + 10), Offset(cx + 15, cy + 25), paint);
        canvas.drawLine(Offset(cx - 15, cy + 25), Offset(cx - 15, cy + 40), paint);
        canvas.drawLine(Offset(cx + 15, cy + 25), Offset(cx + 15, cy + 40), paint);
        
      default:
        // Generic standing figure
        canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), paint);
        canvas.drawCircle(Offset(cx, cy - 28), 8, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}