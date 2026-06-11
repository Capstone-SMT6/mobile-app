import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/pose_detector_service.dart';
import '../services/tts_service.dart';
import '../utils/device_diagnostics.dart';
import '../utils/memory_profiler.dart';
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
  final _pushUpService = PoseDetectorService();
  final _sitUpService  = SitUpDetectorService();
  final _squatService  = SquatDetectorService();
  final _plankService  = PlankDetectorService();
  final _lungeService  = LungeDetectorService();
  final _burpeeService = BurpeeDetectorService();
  final _mcService     = MountainClimberDetectorService();
  bool _isProcessing = false;

  // Union result — hanya satu yang non-null sesuai exerciseType
  PushUpAnalysis? _pushUpAnalysis;
  SitUpAnalysis?  _sitUpAnalysis;
  SquatAnalysis?  _squatAnalysis;
  PlankAnalysis?  _plankAnalysis;
  LungeAnalysis?  _lungeAnalysis;
  BurpeeAnalysis? _burpeeAnalysis;
  MountainClimberAnalysis? _mcAnalysis;

  // ── Shortcut getters (4-way switch) ──────────────────────
  // Plank: _repCount = formScore (dipakai di plank stats row)
  int get _repCount => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.repCount  ?? 0,
    'squat' => _squatAnalysis?.repCount  ?? 0,
    'plank' => _plankAnalysis?.formScore ?? 0,
    'lunge' => _lungeAnalysis?.repCount  ?? 0,
    'burpee' => _burpeeAnalysis?.repCount ?? 0,
    'mountain_climber' => _mcAnalysis?.repCount ?? 0,
    _       => _pushUpAnalysis?.repCount ?? 0,
  };
  String get _stage => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.stage  ?? 'down',
    'squat' => _squatAnalysis?.stage  ?? 'up',
    'plank' => _plankAnalysis?.stage  ?? 'paused',
    'lunge' => _lungeAnalysis?.stage  ?? 'up',
    'burpee' => _burpeeAnalysis?.stage ?? 'up',
    'mountain_climber' => _mcAnalysis?.stage ?? 'left',
    _       => _pushUpAnalysis?.stage ?? 'up',
  };
  String get _feedback => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.feedback  ?? 'Mendeteksi pose...',
    'squat' => _squatAnalysis?.feedback  ?? 'Mendeteksi pose...',
    'plank' => _plankAnalysis?.feedback  ?? 'Mendeteksi pose...',
    'lunge' => _lungeAnalysis?.feedback  ?? 'Mendeteksi pose...',
    'burpee' => _burpeeAnalysis?.feedback ?? 'Mendeteksi pose...',
    'mountain_climber' => _mcAnalysis?.feedback ?? 'Mendeteksi pose...',
    _       => _pushUpAnalysis?.feedback ?? 'Mendeteksi pose...',
  };
  bool get _isGoodPosture => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.isGoodPosture  ?? false,
    'squat' => _squatAnalysis?.isGoodPosture  ?? false,
    'plank' => _plankAnalysis?.isGoodPosture  ?? false,
    'lunge' => _lungeAnalysis?.isGoodPosture  ?? false,
    'burpee' => _burpeeAnalysis?.isGoodPosture ?? false,
    'mountain_climber' => _mcAnalysis?.isGoodPosture ?? false,
    _       => _pushUpAnalysis?.isGoodPosture ?? false,
  };
  bool get _isHorizontal => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.isHorizontal  ?? false,
    'squat' => true,   // standing — skip horizontal guard
    'plank' => _plankAnalysis?.isHorizontal  ?? false,
    'lunge' => true,   // standing exercise
    'burpee' => true,  // multi-phase standing
    'mountain_climber' => true, // plank-based, skip guard
    _       => _pushUpAnalysis?.isHorizontal ?? false,
  };
  List<Pose> get _poses => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis?.poses  ?? [],
    'squat' => _squatAnalysis?.poses  ?? [],
    'plank' => _plankAnalysis?.poses  ?? [],
    'lunge' => _lungeAnalysis?.poses  ?? [],
    'burpee' => _burpeeAnalysis?.poses ?? [],
    'mountain_climber' => _mcAnalysis?.poses ?? [],
    _       => _pushUpAnalysis?.poses ?? [],
  };
  bool get _hasAnalysis => switch (widget.exercise.exerciseType) {
    'situp' => _sitUpAnalysis != null,
    'squat' => _squatAnalysis != null,
    'plank' => _plankAnalysis != null,
    'lunge' => _lungeAnalysis != null,
    'burpee' => _burpeeAnalysis != null,
    'mountain_climber' => _mcAnalysis != null,
    _       => _pushUpAnalysis != null,
  };

  // ── Image dimensions (untuk pose overlay) ─────────────────
  Size _imageSize = Size.zero;

  // ── TTS Voice Feedback ────────────────────────────────────
  final _tts = TtsService();
  String? _lastStage;
  String? _lastFeedback;

  // ── Gyroscope / Accelerometer ─────────────────────────────
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isDeviceLandscape = false; // deteksi dari sensor

  // ── Animations ────────────────────────────────────────────
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackScale;
  late AnimationController _rotateHintCtrl;
  late Animation<double> _rotateHintAnim;

  // ══════════ PERFORMANCE OPTIMIZATION ══════════
  int _frameCounter = 0;
  int _frameSkip = 2; // Process setiap 3 frame (0, 3, 6, ...)
  DateTime? _lastProcessTime;
  final List<int> _processingTimes = []; // Track performance
  
  // Resolusi kamera — disinkronkan dengan kalibrasi
  ResolutionPreset _cameraResolution = ResolutionPreset.medium;
  
  // Auto-adjust frame skip berdasarkan device performance
  bool _isAutoTuning = true;
  Timer? _performanceMonitor;
  
  // Tambahkan properties baru
  final _diagnostics = DeviceDiagnostics();
  final _memoryProfiler = MemoryProfiler();
  
  // FPS monitoring
  int _fps = 0;
  int _fpsCounter = 0;
  DateTime _fpsTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Inisialisasi service sesuai tipe latihan
    switch (widget.exercise.exerciseType) {
      case 'situp':
        _sitUpService.init();
        _sitUpService.reset();
      case 'squat':
        _squatService.init();
        _squatService.reset();
      case 'plank':
        _plankService.init();
        _plankService.reset();
      case 'lunge':
        _lungeService.init();
        _lungeService.reset();
      case 'burpee':
        _burpeeService.init();
        _burpeeService.reset();
      case 'mountain_climber':
        _mcService.init();
        _mcService.reset();
      default:
        _pushUpService.init();
        _pushUpService.reset();
    }

    // Biarkan aplikasi bisa berputar (portrait/landscape) agar kamera bisa menyesuaikan orientasi layar fisik
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _feedbackScale = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut),
    );

    // Animasi hint putar layar (bounce)
    _rotateHintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _rotateHintAnim = Tween(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _rotateHintCtrl, curve: Curves.easeInOut),
    );

    // Subscribe accelerometer untuk deteksi orientasi real-time
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 300),
    ).listen((AccelerometerEvent event) {
      // |x| > |y| berarti device sedang landscape
      final landscape = event.x.abs() > event.y.abs();
      if (landscape != _isDeviceLandscape && mounted) {
        setState(() => _isDeviceLandscape = landscape);
      }
    });

    _initCamera();
    
    // Initialize diagnostics & profiling
    _initializeDiagnostics();
    _startPerformanceMonitoring();

    // Initialize TTS voice feedback
    _tts.init();
  }

  Future<void> _initializeDiagnostics() async {
    await _diagnostics.initialize();
    
    // Start memory profiling in debug mode
    if (kDebugMode) {
      await _memoryProfiler.start();
    }
    
    // Apply recommended settings — SAMA dengan yang dipakai di CalibrationPage
    final settings = _diagnostics.getRecommendedSettings();
    if (mounted) {
      setState(() {
        _frameSkip = settings['frameSkip'] as int;
        _cameraResolution = settings['resolution'] as ResolutionPreset;
        _isAutoTuning = false; // Use device-specific settings
      });
    }
    
    // Restart kamera dengan resolusi yang sudah dikalibrasi
    // (hanya jika kamera sudah berjalan dan resolusinya berbeda)
    if (_cameraReady && _cameraResolution != ResolutionPreset.medium) {
      await _startCamera(_isFrontCamera);
    }
  }
  
  // ─── PERFORMANCE MONITORING ─────────────────────────────
  void _startPerformanceMonitoring() {
    _performanceMonitor = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _analyzePerformance(),
    );
  }
  
  void _analyzePerformance() {
    if (_processingTimes.isEmpty) return;
    
    final avgTime = _processingTimes.reduce((a, b) => a + b) / 
                    _processingTimes.length;
    
    debugPrint('Avg processing time: ${avgTime.toStringAsFixed(1)}ms | FPS: $_fps');
    
    // Auto-tune frame skip jika terlalu lambat
    if (_isAutoTuning) {
      if (avgTime > 150 && _frameSkip < 4) {
        if (mounted) setState(() => _frameSkip++);
        debugPrint('Performance low, increasing frame skip to $_frameSkip');
      } else if (avgTime < 50 && _frameSkip > 1) {
        if (mounted) setState(() => _frameSkip--);
        debugPrint('Performance good, decreasing frame skip to $_frameSkip');
      }
    }
    
    // Clear untuk next interval
    _processingTimes.clear();
  }

  // ─── FPS COUNTER ───────────────────────────────────────
  void _updateFPS() {
    _fpsCounter++;
    final now = DateTime.now();
    
    if (now.difference(_fpsTimestamp).inMilliseconds >= 1000) {
      if (mounted) setState(() => _fps = _fpsCounter);
      _fpsCounter = 0;
      _fpsTimestamp = now;
    }
  }

  void _handleProcessingError(dynamic error) {
    _consecutiveErrors++;
    
    debugPrint('Processing error #$_consecutiveErrors: $error');
    
    // Jika error terus-menerus, tampilkan ke user
    if (_consecutiveErrors >= _maxConsecutiveErrors && mounted) {
      setState(() {
        _persistentError = 'Deteksi pose gagal. Coba ubah posisi kamera.';
      });
      
      // Auto-reset setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _consecutiveErrors >= _maxConsecutiveErrors) {
          setState(() {
            _consecutiveErrors = 0;
            _persistentError = null;
          });
        }
      });
    }
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
      _cameraResolution, // Gunakan resolusi dari kalibrasi (bukan hardcode medium)
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

  // ─── OPTIMIZED FRAME PROCESSING ────────────────────────
  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || !mounted) return;
    
    // ══════════ FRAME SKIPPING ══════════
    if (_frameCounter++ % (_frameSkip + 1) != 0) {
      _updateFPS();
      return;
    }
    
    _isProcessing = true;
    final startTime = DateTime.now();
    
    try {
      final sensorOrientation = _cameraCtrl?.description.sensorOrientation ?? 90;

      if (_imageSize == Size.zero) {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      }

      final inputImage = cameraImageToInputImage(
        image, 
        sensorOrientation, 
        _isFrontCamera,
      );
      
      if (inputImage == null) {
        debugPrint('Failed to convert camera image');
        return;
      }

      // ══════════ ML KIT PROCESSING WITH ERROR HANDLING ══════════
      await _processImageWithErrorHandling(inputImage);
      
      // Track processing time
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      _processingTimes.add(processingTime);
      
      // Keep last 20 measurements only
      if (_processingTimes.length > 20) {
        _processingTimes.removeAt(0);
      }
      
      _lastProcessTime = DateTime.now();
      
    } catch (e, stackTrace) {
      debugPrint('Frame processing error: $e');
      debugPrint(stackTrace.toString());
      
      _handleProcessingError(e);
      
    } finally {
      _isProcessing = false;
      _updateFPS();
    }
  }

  // ─── ML KIT ERROR HANDLING ─────────────────────────────
  int _consecutiveErrors = 0;
  final int _maxConsecutiveErrors = 5;
  String? _persistentError;

  // ─── SET COMPLETION CHECK ────────────────────────────────
  void _checkCompletion() {
    bool isDone = false;
    if (widget.exercise.exerciseType == 'plank') {
      if ((_plankAnalysis?.duration ?? 0) >= widget.exercise.reps) {
        isDone = true;
      }
    } else {
      if (_repCount >= widget.exercise.reps) {
        isDone = true;
      }
    }

    if (isDone && mounted) {
      HapticFeedback.heavyImpact();
      _tts.speakWorkoutComplete();
      Get.back(result: true);
    }
  }

  Future<void> _processImageWithErrorHandling(InputImage inputImage) async {
    try {
      switch (widget.exercise.exerciseType) {
        case 'situp':
          final analysis = await _sitUpService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _sitUpAnalysis?.repCount ?? 0;
            setState(() {
              _sitUpAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;
          
        case 'squat':
          final analysis = await _squatService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _squatAnalysis?.repCount ?? 0;
            setState(() {
              _squatAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;
          
        case 'plank':
          final analysis = await _plankService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final wasGood = _plankAnalysis?.isGoodPosture ?? false;
            setState(() {
              _plankAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (!wasGood && analysis.isGoodPosture) {
              HapticFeedback.lightImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakCorrection('Form bagus, tahan!', isGood: true);
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
            _checkCompletion();
          }
          break;

        case 'lunge':
          final analysis = await _lungeService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _lungeAnalysis?.repCount ?? 0;
            setState(() {
              _lungeAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;

        case 'burpee':
          final analysis = await _burpeeService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _burpeeAnalysis?.repCount ?? 0;
            setState(() {
              _burpeeAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;

        case 'mountain_climber':
          final analysis = await _mcService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _mcAnalysis?.repCount ?? 0;
            setState(() {
              _mcAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;
          
        default:
          final analysis = await _pushUpService.processImage(inputImage)
              .timeout(const Duration(milliseconds: 500));
          
          if (mounted && analysis != null) {
            final prev = _pushUpAnalysis?.repCount ?? 0;
            setState(() {
              _pushUpAnalysis = analysis;
              _consecutiveErrors = 0;
              _persistentError = null;
            });
            
            if (analysis.repCount > prev) {
              HapticFeedback.mediumImpact();
              _feedbackCtrl.forward(from: 0);
              _tts.speakRepCount(analysis.repCount, widget.exercise.reps);
              _checkCompletion();
            }
            if (analysis.stage != _lastStage) {
              _tts.speakStage(analysis.stage);
              _lastStage = analysis.stage;
            }
            if (analysis.feedback != _lastFeedback && !analysis.isGoodPosture) {
              _tts.speakCorrection(analysis.feedback);
              _lastFeedback = analysis.feedback;
            }
          }
          break;
      }
      
    } on TimeoutException {
      _handleProcessingError('ML Kit timeout - device too slow');
      
    } on PlatformException catch (e) {
      if (e.code == 'INVALID_IMAGE') {
        _handleProcessingError('Invalid camera image format');
      } else if (e.code == 'MODEL_NOT_LOADED') {
        _handleProcessingError('ML Kit model not loaded');
      } else {
        _handleProcessingError('ML Kit error: ${e.message}');
      }
      
    } catch (e) {
      _handleProcessingError('Unknown error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    await _startCamera(!_isFrontCamera);
  }

  @override
  void dispose() {
    // Stop profiling & print report
    if (kDebugMode) {
      _memoryProfiler.stop();
    }
    
    _performanceMonitor?.cancel();
    // Kembalikan orientasi ke semua arah saat keluar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _accelSub?.cancel();
    _cameraCtrl?.stopImageStream();
    _cameraCtrl?.dispose();
    _feedbackCtrl.dispose();
    _rotateHintCtrl.dispose();
    _tts.stop();
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
          if (_cameraReady && _hasAnalysis)
            _buildPoseOverlay(),

          // ── LAYER 3: Top gradient (slim) ─────────────────
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),

          // ── LAYER 4: Bottom gradient (slim) ──────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
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

          // ── LAYER 7: Rotate hint (sensor-driven) ─────────
          if (!_isDeviceLandscape) _buildRotateHint(),
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

    // Preserve camera's native aspect ratio so preview is never stretched.
    return Center(
      child: AspectRatio(
        aspectRatio: _cameraCtrl!.value.aspectRatio,
        child: CameraPreview(_cameraCtrl!),
      ),
    );
  }

  // ─── POSE SKELETON OVERLAY ─────────────────────────────────
  Widget _buildPoseOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: screenSize,
          painter: PosePainter(
            poses: _poses,
            imageSize: _imageSize,
            screenSize: screenSize,
            isFrontCamera: _isFrontCamera,
            sensorOrientation:
                _cameraCtrl?.description.sensorOrientation ?? 90,
            feedback: _feedback,
             isGoodPosture: _isGoodPosture,
            exerciseType: widget.exercise.exerciseType,
            plankSide: _plankAnalysis?.side ?? 'left',
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
            const SizedBox(width: 8),
            // Reset counter
            _CircleButton(
              icon: Icons.refresh_rounded,
              onTap: () {
                switch (widget.exercise.exerciseType) {
                  case 'situp':
                    _sitUpService.reset();
                    setState(() => _sitUpAnalysis = null);
                  case 'squat':
                    _squatService.reset();
                    setState(() => _squatAnalysis = null);
                  case 'plank':
                    _plankService.reset();
                    setState(() => _plankAnalysis = null);
                  case 'lunge':
                    _lungeService.reset();
                    setState(() => _lungeAnalysis = null);
                  case 'burpee':
                    _burpeeService.reset();
                    setState(() => _burpeeAnalysis = null);
                  case 'mountain_climber':
                    _mcService.reset();
                    setState(() => _mcAnalysis = null);
                  default:
                    _pushUpService.reset();
                    setState(() => _pushUpAnalysis = null);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM PANEL (minimalist) ────────────────────────────
  Widget _buildBottomPanel() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Compact stats pill ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                color: Colors.black.withValues(alpha: 0.65),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // REPS counter
                      _StatBox(
                        label: 'REPS',
                        value: '$_repCount',
                        color: const Color(0xFF6CC551),
                        large: true,
                      ),
                      VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                      // STAGE / STATUS
                      if (widget.exercise.exerciseType == 'plank')
                        _StatBox(
                          label: 'STATUS',
                          value: _stage.toUpperCase(),
                          color: _stage == 'running'
                              ? const Color(0xFF6CC551)
                              : Colors.white54,
                        )
                      else
                        _StatBox(
                          label: 'STAGE',
                          value: _stage.toUpperCase(),
                          color: _stage == 'down'
                              ? const Color(0xFFF76A6A)
                              : Colors.white,
                        ),
                      VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                      // Primary angle — adaptive
                      if (widget.exercise.exerciseType == 'situp') ...[
                        _StatBox(
                          label: 'BADAN',
                          value: '${_sitUpAnalysis?.bodyAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'LEHER',
                          value: '${_sitUpAnalysis?.neckAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_sitUpAnalysis?.neckAngle ?? 99) < 35
                              ? const Color(0xFFF0A500)
                              : Colors.white70,
                        ),
                      ] else if (widget.exercise.exerciseType == 'squat') ...[
                        _StatBox(
                          label: 'LUTUT',
                          value: '${_squatAnalysis?.kneeAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'PUNGGUNG',
                          value: '${_squatAnalysis?.backAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_squatAnalysis?.backAngle ?? 180) < 130
                              ? const Color(0xFFF0A500)
                              : Colors.white70,
                        ),
                      ] else if (widget.exercise.exerciseType == 'plank') ...[
                        _StatBox(
                          label: 'HIP',
                          value: '${_plankAnalysis?.hipAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_plankAnalysis?.hipAngle ?? 0) >= 165
                              ? const Color(0xFF6CC551)
                              : (_plankAnalysis?.hipAngle ?? 0) >= 150
                                  ? const Color(0xFFF0A500)
                                  : Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'FORM',
                          value: '${_plankAnalysis?.formScore ?? '--'}%',
                          color: (_plankAnalysis?.formScore ?? 0) >= 80
                              ? const Color(0xFF6CC551)
                              : (_plankAnalysis?.formScore ?? 0) >= 50
                                  ? const Color(0xFFF0A500)
                                  : const Color(0xFFF76A6A),
                        ),
                      ] else if (widget.exercise.exerciseType == 'lunge') ...[
                        _StatBox(
                          label: 'LUTUT',
                          value: '${_lungeAnalysis?.kneeAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'BADAN',
                          value: '${_lungeAnalysis?.torsoAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_lungeAnalysis?.torsoAngle ?? 180) < 150
                              ? const Color(0xFFF0A500)
                              : Colors.white70,
                        ),
                      ] else if (widget.exercise.exerciseType == 'burpee') ...[
                        _StatBox(
                          label: 'BADAN',
                          value: '${_burpeeAnalysis?.bodyAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'LUTUT',
                          value: '${_burpeeAnalysis?.kneeAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                      ] else if (widget.exercise.exerciseType == 'mountain_climber') ...[
                        _StatBox(
                          label: 'HIP',
                          value: '${_mcAnalysis?.hipAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_mcAnalysis?.hipAngle ?? 0) >= 155
                              ? const Color(0xFF6CC551)
                              : const Color(0xFFF0A500),
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'KIRI',
                          value: '${_mcAnalysis?.leftKneeAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'KANAN',
                          value: '${_mcAnalysis?.rightKneeAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                      ] else ...[
                        _StatBox(
                          label: 'SIKU',
                          value: '${_pushUpAnalysis?.elbowAngle.toStringAsFixed(0) ?? '--'}°',
                          color: Colors.white70,
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'PINGGUL',
                          value: '${_pushUpAnalysis?.hipAngle.toStringAsFixed(0) ?? '--'}°',
                          color: (_pushUpAnalysis?.hipAngle ?? 0) < 130
                              ? const Color(0xFFF76A6A)   // pinggul turun
                              : (_pushUpAnalysis?.hipAngle ?? 0) > 170
                                  ? const Color(0xFFF0A500) // pinggul naik
                                  : const Color(0xFF6CC551),
                        ),
                        VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
                        _StatBox(
                          label: 'POSISI',
                          value: (_pushUpAnalysis?.isHorizontal ?? false) ? 'OK ✓' : 'BERDIRI',
                          color: (_pushUpAnalysis?.isHorizontal ?? false)
                              ? const Color(0xFF6CC551)
                              : const Color(0xFFF76A6A),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Slim feedback chip ──────────────────────────
            ScaleTransition(
              scale: _feedbackScale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: !_hasAnalysis
                      ? Colors.black45
                      : !_isHorizontal
                          ? const Color(0xFFF0A500).withValues(alpha: 0.85)
                          : _isGoodPosture
                              ? const Color(0xFF6CC551).withValues(alpha: 0.80)
                              : const Color(0xFFF76A6A).withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !_hasAnalysis
                          ? Icons.sensors_rounded
                          : !_isHorizontal
                              ? Icons.accessibility_new_rounded
                              : _isGoodPosture
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _hasAnalysis ? _feedback : 'Mendeteksi pose...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ROTATE HINT OVERLAY (sensor-driven) ──────────────────
  Widget _buildRotateHint() {
    return AnimatedOpacity(
      opacity: _isDeviceLandscape ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon putar dengan animasi bounce
              AnimatedBuilder(
                animation: _rotateHintAnim,
                builder: (_, __) => Transform.rotate(
                  angle: _rotateHintAnim.value,
                  child: const Icon(
                    Icons.screen_rotation_rounded,
                    color: Color(0xFF7C6AF7),
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Putar layar ke Landscape',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Untuk deteksi push-up/plank yang akurat,\ngunakan mode Landscape.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Indikator horizontal / vertikal
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OrientDot(active: false, label: 'Portrait'),
                  const SizedBox(width: 12),
                  _OrientDot(active: true, label: 'Landscape'),
                ],
              ),
            ],
          ),
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
  final String exerciseType; // 'pushup' | 'situp' | 'squat' | 'plank' | 'lunge' | 'burpee' | 'mountain_climber'
  final String plankSide;   // 'left' | 'right' — used only for plank

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.screenSize,
    required this.isFrontCamera,
    required this.sensorOrientation,
    required this.feedback,
    required this.isGoodPosture,
    this.exerciseType = 'pushup',
    this.plankSide = 'left',
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

      // ── Highlight joint kunci ───────────────────────────
      // Sit-up: LEFT  shoulder, hip, knee, ear
      // Squat:  RIGHT shoulder, hip, knee, ankle
      // Plank:  auto side (plankSide) shoulder, elbow, hip, knee, ankle, ear
      // Push-up: LEFT shoulder, elbow, wrist, hip, ankle
      final isPlankLeft = plankSide == 'left';
      final keyLandmarks = switch (exerciseType) {
        'situp' => [
            lm[PoseLandmarkType.leftShoulder],
            lm[PoseLandmarkType.leftHip],
            lm[PoseLandmarkType.leftKnee],
            lm[PoseLandmarkType.leftEar],
          ],
        'squat' => [
            lm[PoseLandmarkType.rightShoulder],
            lm[PoseLandmarkType.rightHip],
            lm[PoseLandmarkType.rightKnee],
            lm[PoseLandmarkType.rightAnkle],
          ],
        'plank' => [
            lm[isPlankLeft ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder],
            lm[isPlankLeft ? PoseLandmarkType.leftElbow    : PoseLandmarkType.rightElbow],
            lm[isPlankLeft ? PoseLandmarkType.leftHip      : PoseLandmarkType.rightHip],
            lm[isPlankLeft ? PoseLandmarkType.leftKnee     : PoseLandmarkType.rightKnee],
            lm[isPlankLeft ? PoseLandmarkType.leftAnkle    : PoseLandmarkType.rightAnkle],
            lm[isPlankLeft ? PoseLandmarkType.leftEar      : PoseLandmarkType.rightEar],
          ],
        'lunge' => [
            lm[PoseLandmarkType.rightShoulder],
            lm[PoseLandmarkType.rightHip],
            lm[PoseLandmarkType.rightKnee],
            lm[PoseLandmarkType.rightAnkle],
            lm[PoseLandmarkType.leftKnee],
          ],
        'burpee' => [
            lm[PoseLandmarkType.rightShoulder],
            lm[PoseLandmarkType.rightHip],
            lm[PoseLandmarkType.rightKnee],
            lm[PoseLandmarkType.rightAnkle],
          ],
        'mountain_climber' => [
            lm[PoseLandmarkType.leftShoulder],
            lm[PoseLandmarkType.leftHip],
            lm[PoseLandmarkType.leftKnee],
            lm[PoseLandmarkType.rightKnee],
            lm[PoseLandmarkType.leftAnkle],
            lm[PoseLandmarkType.rightAnkle],
          ],
        _ => [
            lm[PoseLandmarkType.leftShoulder],
            lm[PoseLandmarkType.leftElbow],
            lm[PoseLandmarkType.leftWrist],
            lm[PoseLandmarkType.leftHip],
            lm[PoseLandmarkType.leftAnkle],
          ],
      };

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
    if (exerciseType == 'situp') {
      // Sit-up: label di pinggul (body angle) dan bahu (neck angle)
      final hip = lm[PoseLandmarkType.leftHip];
      final shoulder = lm[PoseLandmarkType.leftShoulder];
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Badan', color);
      }
      if (shoulder != null && shoulder.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(shoulder, size).translate(10, -20),
            'Leher', color);
      }
    } else if (exerciseType == 'squat') {
      // Squat: label di lutut (knee angle) dan pinggul (back angle)
      final knee = lm[PoseLandmarkType.rightKnee];
      final hip  = lm[PoseLandmarkType.rightHip];
      if (knee != null && knee.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(knee, size).translate(10, -20),
            'Lutut', color);
      }
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Punggung', color);
      }
    } else if (exerciseType == 'plank') {
      // Plank: label di pinggul (hip angle) dan bahu (neck angle)
      final isLeft = plankSide == 'left';
      final hip      = lm[isLeft ? PoseLandmarkType.leftHip      : PoseLandmarkType.rightHip];
      final shoulder = lm[isLeft ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder];
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Hip', color);
      }
      if (shoulder != null && shoulder.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(shoulder, size).translate(10, -20),
            'Leher', color);
      }
    } else if (exerciseType == 'lunge') {
      final knee = lm[PoseLandmarkType.rightKnee];
      final shoulder = lm[PoseLandmarkType.rightShoulder];
      if (knee != null && knee.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(knee, size).translate(10, -20),
            'Lutut', color);
      }
      if (shoulder != null && shoulder.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(shoulder, size).translate(10, -20),
            'Badan', color);
      }
    } else if (exerciseType == 'burpee') {
      final knee = lm[PoseLandmarkType.rightKnee];
      final hip = lm[PoseLandmarkType.rightHip];
      if (knee != null && knee.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(knee, size).translate(10, -20),
            'Lutut', color);
      }
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Badan', color);
      }
    } else if (exerciseType == 'mountain_climber') {
      final hip = lm[PoseLandmarkType.leftHip];
      final leftKnee = lm[PoseLandmarkType.leftKnee];
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Hip', color);
      }
      if (leftKnee != null && leftKnee.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(leftKnee, size).translate(10, -20),
            'Lutut', color);
      }
    } else {
      // Push-up: label di siku dan pinggul
      final elbow = lm[PoseLandmarkType.leftElbow];
      final hip = lm[PoseLandmarkType.leftHip];
      if (elbow != null && elbow.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(elbow, size).translate(10, -20),
            'Siku', color);
      }
      if (hip != null && hip.likelihood > 0.5) {
        _drawTextLabel(canvas, _toScreen(hip, size).translate(10, -20),
            'Pinggul', color);
      }
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
      old.feedback != feedback ||
      old.exerciseType != exerciseType;
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

// ─────────────────────────────────────────────────────────────
// HELPER: Indikator orientasi di rotate-hint overlay
// ─────────────────────────────────────────────────────────────
class _OrientDot extends StatelessWidget {
  final bool active;
  final String label;

  const _OrientDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: active ? 36 : 16,
          height: 16,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF7C6AF7)
                : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF7C6AF7) : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
