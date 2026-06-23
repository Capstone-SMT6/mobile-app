import 'dart:math' as math;
import 'dart:ui';
import 'dart:collection';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// ─────────────────────────────────────────────────────────────
// TOP-LEVEL UTILITIES  (shared by all 3 services)
// ─────────────────────────────────────────────────────────────

/// Ekstrak koordinat [x, y] dari landmark (normalized 0..1).
List<double> _pt(PoseLandmark lm) => [lm.x, lm.y];

/// Moving-average smoothing — port dari Python deque(maxlen=N).
double _smooth(Queue<double> buf, double value, int window) {
  buf.addLast(value);
  if (buf.length > window) buf.removeFirst();
  return buf.reduce((a, b) => a + b) / buf.length;
}

/// calculate_angle(a, b, c) — port 1:1 dari Python.
/// Menghitung sudut di titik B antara vektor BA dan BC.
double calculateAngle(List<double> a, List<double> b, List<double> c) {
  final rad = math.atan2(c[1] - b[1], c[0] - b[0]) -
              math.atan2(a[1] - b[1], a[0] - b[0]);
  final angle = (rad * 180.0 / math.pi).abs();
  return angle > 180 ? 360 - angle : angle;
}

// ═════════════════════════════════════════════════════════════
// REP QUALITY TRACKER — per-rep scoring & tempo tracking
// ═════════════════════════════════════════════════════════════
class RepQualityTracker {
  final List<double> _repScores = [];
  final List<double> _repTempos = [];
  DateTime? _lastStageChange;
  int _badFormFrames = 0;
  int _totalFramesInRep = 0;

  /// Call every frame with current posture quality.
  void onFrame(bool isGoodPosture) {
    _totalFramesInRep++;
    if (!isGoodPosture) _badFormFrames++;
  }

  /// Call when exercise stage changes (up→down or down→up).
  void onStageChange(bool isGoodForm) {
    final now = DateTime.now();
    if (_lastStageChange != null) {
      final elapsed = now.difference(_lastStageChange!).inMilliseconds / 1000.0;
      if (elapsed > 0.2) _repTempos.add(elapsed);
    }
    _lastStageChange = now;
  }

  /// Call when a rep completes. Returns quality score 0-100.
  double onRepComplete() {
    if (_totalFramesInRep == 0) {
      _repScores.add(100.0);
      _resetRepCounters();
      return 100.0;
    }
    final goodRatio = 1.0 - (_badFormFrames / _totalFramesInRep);
    final score = (goodRatio * 100).clamp(0.0, 100.0);
    _repScores.add(score);
    _resetRepCounters();
    return score;
  }

  void _resetRepCounters() {
    _badFormFrames = 0;
    _totalFramesInRep = 0;
  }

  /// Average quality across all reps.
  double get avgQuality => _repScores.isEmpty
      ? 100.0
      : _repScores.reduce((a, b) => a + b) / _repScores.length;

  /// Average tempo (seconds per rep).
  double get avgTempo => _repTempos.isEmpty
      ? 0.0
      : _repTempos.reduce((a, b) => a + b) / _repTempos.length;

  /// Tempo of the last completed rep.
  double get lastTempo => _repTempos.isNotEmpty ? _repTempos.last : 0.0;

  /// Quality of the last completed rep.
  double get lastQuality => _repScores.isNotEmpty ? _repScores.last : 100.0;

  /// Whether the user is moving too fast (tempo < 0.8s).
  bool get isTooFast => lastTempo > 0 && lastTempo < 0.8;

  /// All rep scores for detailed breakdown.
  List<double> get repScores => List.unmodifiable(_repScores);

  /// Reset all tracking data.
  void reset() {
    _repScores.clear();
    _repTempos.clear();
    _lastStageChange = null;
    _resetRepCounters();
  }
}

// ─────────────────────────────────────────────────────────────
// BASE CLASS — eliminasi boilerplate init/close di tiap service
// ─────────────────────────────────────────────────────────────
abstract class _PoseServiceBase {
  late PoseDetector _detector;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );
    _initialized = true;
  }

  Future<void> close() async {
    if (_initialized) {
      await _detector.close();
      _initialized = false;
    }
  }
}

// ═════════════════════════════════════════════════════════════
// ① PUSH-UP
// Landmarks : LEFT shoulder → elbow → wrist  (siku)
//             LEFT shoulder → hip → ankle    (badan / validasi)
// Horizontal: xDiff(shoulder↔ankle) > yDiff * 1.5
// ═════════════════════════════════════════════════════════════
class PushUpAnalysis {
  final double elbowAngle;
  final double hipAngle;
  final int    repCount;
  final String stage;        // 'up' | 'down'
  final String feedback;
  final bool   isGoodPosture;
  final bool   isHorizontal;
  final List<Pose> poses;
  final double qualityScore; // 0-100
  final double tempo;        // seconds per rep

  const PushUpAnalysis({
    required this.elbowAngle,
    required this.hipAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class PoseDetectorService extends _PoseServiceBase {
  // Singleton
  static final PoseDetectorService _i = PoseDetectorService._();
  factory PoseDetectorService() => _i;
  PoseDetectorService._();

  // Thresholds
  static const double _downThreshold  = 100.0; // elbow < 100 → down
  static const double _upThreshold    = 150.0; // elbow > 150 → up
  static const double _bodyThreshold  = 130.0; // hip  > 130 → valid body (longgar)
  static const double _hipLowWarn     = 130.0; // hip  < 130 → pinggul turun
  static const double _hipHighWarn    = 170.0; // hip  > 170 → pinggul naik
  static const double _horizontalRatio = 1.2;  // lebih sensitif
  static const int    _kWindow        = 5;

  // Expose calculateAngle secara static untuk dipakai service lain
  // ignore: prefer_function_declarations_over_variables
  static final calculateAngle = (List<double> a, List<double> b, List<double> c)
      => _calculateAngle(a, b, c);

  static double _calculateAngle(List<double> a, List<double> b, List<double> c) {
    final rad = math.atan2(c[1] - b[1], c[0] - b[0]) -
                math.atan2(a[1] - b[1], a[0] - b[0]);
    final angle = (rad * 180.0 / math.pi).abs();
    return angle > 180 ? 360 - angle : angle;
  }

  final Queue<double> _elbowBuf = Queue();
  final Queue<double> _hipBuf   = Queue();
  int    _counter = 0;
  String _stage   = 'up';
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<PushUpAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lElbow    = lm[PoseLandmarkType.leftElbow];
    final lWrist    = lm[PoseLandmarkType.leftWrist];
    final lHip      = lm[PoseLandmarkType.leftHip];
    final lAnkle    = lm[PoseLandmarkType.leftAnkle];

    if (lShoulder == null || lElbow == null || lWrist == null ||
        lHip == null    || lAnkle == null) { return null; }
    // Cek visibility semua landmark penting (threshold lebih rendah agar lebih toleran)
    if (lShoulder.likelihood < 0.4 || lElbow.likelihood < 0.4 ||
        lHip.likelihood < 0.35    || lAnkle.likelihood < 0.3) { return null; }

    final shoulder = _pt(lShoulder);
    final elbow    = _pt(lElbow);
    final wrist    = _pt(lWrist);
    final hip      = _pt(lHip);
    final ankle    = _pt(lAnkle);

    final elbowAngle = _smooth(_elbowBuf,
        calculateAngle(shoulder, elbow, wrist), _kWindow);
    final hipAngle   = _smooth(_hipBuf,
        calculateAngle(shoulder, hip, ankle),   _kWindow);

    // Deteksi horizontal: robust untuk landscape & portrait kamera
    // ML Kit mengembalikan koordinat normalized (0..1) dalam sensor space
    // Saat kamera landscape (sensor portrait 90°), tubuh push-up yang
    // sebenarnya HORIZONTAL di layar akan tampak VERTIKAL di sensor space.
    // Solusi: tubuh dianggap "horizontal" (berbaring) jika:
    //  - xDiff besar (sensor portrait, layar portrait) — kasus normal
    //  - ATAU yDiff besar (sensor portrait, layar landscape) — push-up landscape
    //  - ATAU total jarak cukup jauh (shoulder ke ankle jauh tapi kemiringan rendah)
    final xDiff = (shoulder[0] - ankle[0]).abs();
    final yDiff = (shoulder[1] - ankle[1]).abs();
    final totalDist = math.sqrt(xDiff * xDiff + yDiff * yDiff);
    // Jika salah satu sumbu mendominasi atau jarak total cukup besar
    final isHorizontal = xDiff > (yDiff * _horizontalRatio) || // layar portrait
        yDiff > (xDiff * _horizontalRatio) ||                   // layar landscape
        (totalDist > 0.15 && yDiff < 0.4);                    // kasus umum

    // Feedback
    late final String feedback;
    late final bool   isGoodPosture;

    if (!isHorizontal) {
      feedback      = 'Silakan berbaring di lantai & sejajarkan tubuh!';
      isGoodPosture = false;
    } else if (hipAngle < _hipLowWarn) {
      feedback      = 'Pinggul Terlalu Turun! Kencangkan otot inti (core).';
      isGoodPosture = false;
    } else if (hipAngle > _hipHighWarn) {
      feedback      = 'Pinggul Terlalu Naik! Turunkan pinggul agar tubuh lurus.';
      isGoodPosture = false;
    } else if (elbowAngle > _upThreshold && _stage == 'up') {
      feedback      = 'Postur Bagus! Bersiap untuk turun.';
      isGoodPosture = true;
    } else if (elbowAngle < _downThreshold && _stage == 'down') {
      feedback      = 'Dorong ke atas!';
      isGoodPosture = true;
    } else {
      feedback      = 'Pertahankan form tubuhmu.';
      isGoodPosture = true;
    }

    // Quality tracking
    _qualityTracker.onFrame(isGoodPosture && isHorizontal);

    // Counting — hanya saat horizontal & badan valid
    if (isHorizontal && hipAngle > _bodyThreshold) {
      if (elbowAngle < _downThreshold) {
        if (_stage != 'down') {
          _qualityTracker.onStageChange(isGoodPosture);
        }
        _stage = 'down';
      } else if (elbowAngle > _upThreshold && _stage == 'down') {
        _stage = 'up';
        _counter++;
        _lastQuality = _qualityTracker.onRepComplete();
        _lastTempo = _qualityTracker.lastTempo;
      }
    }

    return PushUpAnalysis(
      elbowAngle:   elbowAngle,
      hipAngle:     hipAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     feedback,
      isGoodPosture: isGoodPosture,
      isHorizontal: isHorizontal,
      poses:        poses,
      qualityScore: _lastQuality,
      tempo:        _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _elbowBuf.clear();
    _hipBuf.clear();
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ═════════════════════════════════════════════════════════════
// ② SIT-UP
// Landmarks : LEFT shoulder, hip, knee, ear, ankle
// body_angle: calculate_angle(shoulder, hip, knee)
// neck_angle: calculate_angle(ear, shoulder, hip)
// Horizontal: xDiff(shoulder↔ankle) > yDiff * 1.5
//
// Thresholds (Python):
//   DOWN  = 140  body > 140 → stage down (berbaring)
//   UP    = 80   body < 80  → stage naik
//   RANGE = 45–80 → rep valid
//   NECK  = 35   neck < 35  → leher terlalu maju
// ═════════════════════════════════════════════════════════════
class SitUpAnalysis {
  final double bodyAngle;
  final double neckAngle;
  final int    repCount;
  final String stage;        // 'down' | 'up'
  final String feedback;
  final bool   isGoodPosture;
  final bool   isHorizontal;
  final List<Pose> poses;
  final double qualityScore;
  final double tempo;

  const SitUpAnalysis({
    required this.bodyAngle,
    required this.neckAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class SitUpDetectorService extends _PoseServiceBase {
  static final SitUpDetectorService _i = SitUpDetectorService._();
  factory SitUpDetectorService() => _i;
  SitUpDetectorService._();

  // Thresholds
  static const double _downThreshold  = 140.0;
  static const double _upThreshold    = 80.0;
  static const double _goodUpMin      = 45.0;
  static const double _goodUpMax      = 90.0;
  static const double _neckThreshold  = 35.0;
  static const double _tooForwardBody = 40.0;  // body < 40 → terlalu bungkuk
  static const double _horizontalRatio = 1.5;
  static const int    _kWindow        = 5;

  final Queue<double> _bodyBuf = Queue();
  final Queue<double> _neckBuf = Queue();
  int    _counter = 0;
  String _stage   = 'down'; // mulai dari posisi berbaring
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<SitUpAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lHip      = lm[PoseLandmarkType.leftHip];
    final lKnee     = lm[PoseLandmarkType.leftKnee];
    final lEar      = lm[PoseLandmarkType.leftEar];
    final lAnkle    = lm[PoseLandmarkType.leftAnkle];

    if (lShoulder == null || lHip == null || lKnee == null ||
        lEar == null    || lAnkle == null) { return null; }
    if (lShoulder.likelihood < 0.5) { return null; }

    final shoulder = _pt(lShoulder);
    final hip      = _pt(lHip);
    final knee     = _pt(lKnee);
    final ear      = _pt(lEar);
    final ankle    = _pt(lAnkle);

    final bodyAngle = _smooth(_bodyBuf,
        calculateAngle(shoulder, hip, knee), _kWindow);
    final neckAngle = _smooth(_neckBuf,
        calculateAngle(ear, shoulder, hip),  _kWindow);

    final xDiff = (shoulder[0] - ankle[0]).abs();
    final yDiff = (shoulder[1] - ankle[1]).abs();
    final isHorizontal = xDiff > (yDiff * _horizontalRatio);

    // Feedback — prioritas dari atas ke bawah
    late final String feedback;
    late final bool   isGoodPosture;

    if (!isHorizontal) {
      feedback      = 'Berbaring terlentang di lantai untuk memulai.';
      isGoodPosture = false;
    } else if (neckAngle < _neckThreshold) {
      feedback      = 'Jangan tarik leher! Gunakan otot perutmu.';
      isGoodPosture = false;
    } else if (bodyAngle < _tooForwardBody) {
      feedback      = 'Punggung terlalu melengkung ke depan, buka dada.';
      isGoodPosture = false;
    } else if (_stage == 'up' &&
               bodyAngle > _goodUpMax &&
               bodyAngle < _downThreshold) {
      feedback      = 'Angkat punggung lebih tinggi dari lantai!';
      isGoodPosture = false;
    } else if (bodyAngle > _downThreshold) {
      feedback      = 'Posisi rebahan. Kencangkan perut & angkat!';
      isGoodPosture = true;
    } else {
      feedback      = 'Form sit-up mantap!';
      isGoodPosture = true;
    }

    // Quality tracking
    _qualityTracker.onFrame(isGoodPosture && isHorizontal);

    // Counting — hanya saat horizontal
    if (isHorizontal) {
      if (bodyAngle > _downThreshold) {
        if (_stage != 'down') {
          _qualityTracker.onStageChange(isGoodPosture);
        }
        _stage = 'down';
      } else if (bodyAngle < _upThreshold && _stage == 'down') {
        // Rep valid hanya jika sudut masuk range yang ditentukan Python
        if (bodyAngle >= _goodUpMin && bodyAngle <= _goodUpMax) {
          _counter++;
          _stage = 'up';
          _lastQuality = _qualityTracker.onRepComplete();
          _lastTempo = _qualityTracker.lastTempo;
        }
      }
    }

    return SitUpAnalysis(
      bodyAngle:    bodyAngle,
      neckAngle:    neckAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     feedback,
      isGoodPosture: isGoodPosture,
      isHorizontal: isHorizontal,
      poses:        poses,
      qualityScore: _lastQuality,
      tempo:        _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'down';
    _bodyBuf.clear();
    _neckBuf.clear();
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ═════════════════════════════════════════════════════════════
// ③ SQUAT
// Landmarks : RIGHT shoulder, hip, knee, ankle
// knee_angle: calculate_angle(hip, knee, ankle)
// back_angle: calculate_angle(shoulder, hip, knee)
//
// Thresholds (Python):
//   DOWN  = 95   knee < 95  → stage down
//   UP    = 160  knee > 160 → stage up, counter++
//   BACK  = 130  back < 130 → punggung bungkuk (P1 — risiko cedera)
//   KNEE_FWD = 0.08  |knee.x − ankle.x| > 0.08 → lutut melewati jari kaki (P2)
//
// Feedback priority:
//   P1 → "Tegakkan Punggungmu!"
//   P2 → "Lutut Melewati Jari Kaki!"
//   P3 → "Turun Lebih Dalam!" (hanya saat stage down & belum dalam)
//   P4 → "Postur Bagus!"
// ═════════════════════════════════════════════════════════════
class SquatAnalysis {
  final double kneeAngle;
  final double backAngle;
  final int    repCount;
  final String stage;        // 'up' | 'down'
  final String feedback;
  final bool   isGoodPosture;
  final List<Pose> poses;
  final double qualityScore;
  final double tempo;

  const SquatAnalysis({
    required this.kneeAngle,
    required this.backAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class SquatDetectorService extends _PoseServiceBase {
  static final SquatDetectorService _i = SquatDetectorService._();
  factory SquatDetectorService() => _i;
  SquatDetectorService._();

  // Thresholds
  static const double _downThreshold = 95.0;
  static const double _upThreshold   = 160.0;
  static const double _backThreshold = 130.0;
  static const double _kneeFwdLimit  = 0.08;
  static const int    _kWindow       = 5;

  final Queue<double> _kneeBuf = Queue();
  final Queue<double> _backBuf = Queue();
  int    _counter = 0;
  String _stage   = 'up'; // mulai dari posisi berdiri
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<SquatAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final rShoulder = lm[PoseLandmarkType.rightShoulder];
    final rHip      = lm[PoseLandmarkType.rightHip];
    final rKnee     = lm[PoseLandmarkType.rightKnee];
    final rAnkle    = lm[PoseLandmarkType.rightAnkle];

    if (rShoulder == null || rHip == null ||
        rKnee == null    || rAnkle == null) { return null; }
    if (rHip.likelihood < 0.5) { return null; }

    final shoulder = _pt(rShoulder);
    final hip      = _pt(rHip);
    final knee     = _pt(rKnee);
    final ankle    = _pt(rAnkle);

    final kneeAngle = _smooth(_kneeBuf,
        calculateAngle(hip, knee, ankle),    _kWindow);
    final backAngle = _smooth(_backBuf,
        calculateAngle(shoulder, hip, knee), _kWindow);

    // Feedback dengan urutan prioritas Python
    late final String feedback;
    late final bool   isGoodPosture;

    if (backAngle < _backThreshold) {
      // P1: cedera fatal — cek punggung lebih dulu
      feedback      = 'Tegakkan punggungmu! Busungkan dada ke depan.';
      isGoodPosture = false;
    } else if ((knee[0] - ankle[0]).abs() > _kneeFwdLimit) {
      // P2: lutut maju melebihi jari kaki (normalized x-coord)
      feedback      = 'Tarik panggul ke belakang, lutut terlalu maju!';
      isGoodPosture = false;
    } else if (_stage == 'down' && kneeAngle > _downThreshold) {
      // P3: belum cukup dalam saat sudah mulai turun
      feedback      = 'Turun lebih dalam agar paha sejajar lantai!';
      isGoodPosture = false;
    } else if (_stage == 'down') {
      feedback      = 'Tahan! Sekarang dorong ke atas.';
      isGoodPosture = true;
    } else {
      feedback      = 'Postur Bagus! Bersiap turun perlahan.';
      isGoodPosture = true;
    }

    // Quality tracking
    _qualityTracker.onFrame(isGoodPosture);

    // Counting
    if (kneeAngle < _downThreshold) {
      if (_stage != 'down') {
        _qualityTracker.onStageChange(isGoodPosture);
      }
      _stage = 'down';
    } else if (kneeAngle > _upThreshold && _stage == 'down') {
      _stage = 'up';
      _counter++;
      _lastQuality = _qualityTracker.onRepComplete();
      _lastTempo = _qualityTracker.lastTempo;
    }

    return SquatAnalysis(
      kneeAngle:    kneeAngle,
      backAngle:    backAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     feedback,
      isGoodPosture: isGoodPosture,
      poses:        poses,
      qualityScore: _lastQuality,
      tempo:        _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _kneeBuf.clear();
    _backBuf.clear();
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ═════════════════════════════════════════════════════════════
// ④ PLANK
// Auto side-selection: side with better hip visibility
// hip_angle  = calculateAngle(shoulder, hip, ankle)
// neck_angle = calculateAngle(ear, shoulder, hip)
//
// Thresholds (Python):
//   HIP_GOOD   = 165  perfect hip alignment
//   HIP_WARN   = 150  acceptable (below = form break)
//   ELBOW_ALIGN= 0.08 |shoulder.x − elbow.x| max
//   KNEE_GROUND= 0.03 knee.y < ankle.y − 0.03 → knees off ground
//   HORIZONTAL = 0.15 |shoulder.y − ankle.y| max (y-diff check)
//   STABILITY  = 4.5  std dev of hip buffer
//   NECK_GOOD  = 140  neck_angle > 140
//
// Form score: 100 − deductions (hip<150:−30, elbow:−15, knee:−20, neck:−10, stability:−15)
// Timer: only ticks while good_form is true
// ═════════════════════════════════════════════════════════════
class PlankAnalysis {
  final double hipAngle;
  final double neckAngle;
  final double duration;      // total seconds in good form
  final int    formScore;     // 0-100
  final double stability;     // std dev of hip buffer (lower = steadier)
  final String stage;         // 'running' | 'paused'
  final String feedback;
  final bool   isGoodPosture; // == good_form
  final bool   isHorizontal;
  final String side;          // 'left' | 'right' (auto-selected)
  final List<Pose> poses;

  const PlankAnalysis({
    required this.hipAngle,
    required this.neckAngle,
    required this.duration,
    required this.formScore,
    required this.stability,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.side,
    required this.poses,
  });
}

class PlankDetectorService extends _PoseServiceBase {
  static final PlankDetectorService _i = PlankDetectorService._();
  factory PlankDetectorService() => _i;
  PlankDetectorService._();

  // Thresholds
  static const double _hipGood        = 165.0;
  static const double _hipWarning     = 150.0;
  static const double _elbowLimit     = 0.08;
  static const double _kneeLimit      = 0.03;
  static const double _horizontalLim  = 0.15;
  static const double _stabilityLim   = 4.5;
  static const double _neckMin        = 140.0;
  static const double _visThresh      = 0.5;
  static const int    _kWindow        = 10;

  final Queue<double> _hipBuf = Queue();
  double    _accDuration = 0.0;
  DateTime? _plankStart;           // non-null while actively planking

  // Standard deviation (stability metric)
  double _stdDev(Queue<double> buf) {
    if (buf.length < 2) return 0.0;
    final mean = buf.reduce((a, b) => a + b) / buf.length;
    final variance = buf
        .map((v) => math.pow(v - mean, 2).toDouble())
        .reduce((a, b) => a + b) / buf.length;
    return math.sqrt(variance);
  }

  Future<PlankAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;

    // ── Auto side selection ──────────────────────────────────
    final leftVis  = lm[PoseLandmarkType.leftHip]?.likelihood  ?? 0.0;
    final rightVis = lm[PoseLandmarkType.rightHip]?.likelihood ?? 0.0;
    final isLeft   = leftVis >= rightVis;
    final side     = isLeft ? 'left' : 'right';

    final lmShoulder = lm[isLeft ? PoseLandmarkType.leftShoulder  : PoseLandmarkType.rightShoulder];
    final lmElbow    = lm[isLeft ? PoseLandmarkType.leftElbow     : PoseLandmarkType.rightElbow];
    final lmHip      = lm[isLeft ? PoseLandmarkType.leftHip       : PoseLandmarkType.rightHip];
    final lmKnee     = lm[isLeft ? PoseLandmarkType.leftKnee      : PoseLandmarkType.rightKnee];
    final lmAnkle    = lm[isLeft ? PoseLandmarkType.leftAnkle     : PoseLandmarkType.rightAnkle];
    final lmEar      = lm[isLeft ? PoseLandmarkType.leftEar       : PoseLandmarkType.rightEar];

    if (lmShoulder == null || lmHip == null ||
        lmKnee == null     || lmAnkle == null) { return null; }

    // Visibility check on important landmarks
    if ([lmShoulder, lmHip, lmKnee, lmAnkle]
        .any((l) => l.likelihood < _visThresh)) { return null; }

    final shoulder = _pt(lmShoulder);
    final hip      = _pt(lmHip);
    final knee     = _pt(lmKnee);
    final ankle    = _pt(lmAnkle);
    final elbow    = lmElbow != null ? _pt(lmElbow) : null;
    final ear      = lmEar   != null ? _pt(lmEar)   : null;

    // ── Angles ───────────────────────────────────────────────
    final rawHip    = calculateAngle(shoulder, hip, ankle);
    final neckAngle = ear != null
        ? calculateAngle(ear, shoulder, hip)
        : 180.0; // assume neutral if ear not visible
    final hipAngle  = _smooth(_hipBuf, rawHip, _kWindow);
    final stability = _stdDev(_hipBuf);

    // ── Form checks ─────────────────────────────────────────
    // Python: horizontal_diff = abs(shoulder[1] - ankle[1]) < 0.15
    final isHorizontal = (shoulder[1] - ankle[1]).abs() < _horizontalLim;
    // Python: elbow_alignment = abs(shoulder[0] - elbow[0]) < 0.08
    final elbowGood = elbow == null ||
        (shoulder[0] - elbow[0]).abs() < _elbowLimit;
    // Python: knee[1] < ankle[1] - 0.03  (smaller y = higher in image)
    final kneesLifted = knee[1] < (ankle[1] - _kneeLimit);
    // Python: neck_angle > 140
    final neckGood  = neckAngle > _neckMin;

    // ── Form score (100 − deductions) ────────────────────────
    int score = 100;
    if (hipAngle < _hipWarning)       score -= 30;
    if (!elbowGood)                   score -= 15;
    if (!kneesLifted)                 score -= 20;
    if (!neckGood)                    score -= 10;
    if (stability > _stabilityLim)    score -= 15;
    final formScore = score.clamp(0, 100);

    // ── Good form gate ───────────────────────────────────────
    final goodForm = hipAngle >= _hipWarning &&
        isHorizontal && elbowGood && kneesLifted && neckGood;

    // ── Timer (only ticks while good_form) ───────────────────
    final now = DateTime.now();
    if (goodForm) {
      _plankStart ??= now;
    } else {
      if (_plankStart != null) {
        _accDuration +=
            now.difference(_plankStart!).inMilliseconds / 1000.0;
        _plankStart = null;
      }
    }
    final currentDuration = _accDuration +
        (_plankStart != null
            ? now.difference(_plankStart!).inMilliseconds / 1000.0
            : 0.0);

    // ── Feedback (Python priority order) ─────────────────────
    late final String feedback;
    late final bool   isGoodPosture;

    if (!isHorizontal) {
      feedback      = 'Posisikan tubuh membentang mendatar.';
      isGoodPosture = false;
    } else if (!kneesLifted) {
      feedback      = 'Lutut menyentuh lantai! Angkat perlahan.';
      isGoodPosture = false;
    } else if (!elbowGood) {
      feedback      = 'Siku harus tegak lurus tepat di bawah bahu.';
      isGoodPosture = false;
    } else if (!neckGood) {
      feedback      = 'Lihat ke bawah di antara kedua tangan (leher netral).';
      isGoodPosture = false;
    } else if (stability > _stabilityLim) {
      feedback      = 'Kurangi goyangan, kencangkan otot perut!';
      isGoodPosture = false;
    } else if (hipAngle >= _hipGood) {
      feedback      = 'Plank sempurna! Tahan posisi.';
      isGoodPosture = true;
    } else if (hipAngle >= _hipWarning) {
      // Cek apakah pinggul terlalu rendah atau terlalu tinggi
      final midY = (shoulder[1] + ankle[1]) / 2;
      if (hip[1] > midY) {
        feedback = 'Pinggul terlalu turun. Naikkan sedikit!';
      } else {
        feedback = 'Pinggul menonjol ke atas. Turunkan agar lurus!';
      }
      isGoodPosture = false;
    } else {
      feedback      = 'Badan melengkung, sejajarkan bahu ke tumit.';
      isGoodPosture = false;
    }

    return PlankAnalysis(
      hipAngle:     hipAngle,
      neckAngle:    neckAngle,
      duration:     currentDuration,
      formScore:    formScore,
      stability:    stability,
      stage:        goodForm ? 'running' : 'paused',
      feedback:     feedback,
      isGoodPosture: isGoodPosture,
      isHorizontal: isHorizontal,
      side:         side,
      poses:        poses,
    );
  }

  void reset() {
    _hipBuf.clear();
    _accDuration = 0.0;
    _plankStart  = null;
  }
}

// ═════════════════════════════════════════════════════════════
// ⑤ JUMPING JACK
// Deteksi lengan naik (wrist di atas shoulder) dan kaki terbuka
// ═════════════════════════════════════════════════════════════
class JumpingJackAnalysis {
  final int    repCount;
  final String stage;        // 'up' | 'down'
  final String feedback;
  final bool   isGoodPosture;
  final List<Pose> poses;
  final double qualityScore;
  final double tempo;

  const JumpingJackAnalysis({
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class JumpingJackDetectorService extends _PoseServiceBase {
  static final JumpingJackDetectorService _i = JumpingJackDetectorService._();
  factory JumpingJackDetectorService() => _i;
  JumpingJackDetectorService._();

  int    _counter = 0;
  String _stage   = 'down';
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<JumpingJackAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final rShoulder = lm[PoseLandmarkType.rightShoulder];
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final rWrist    = lm[PoseLandmarkType.rightWrist];
    final lWrist    = lm[PoseLandmarkType.leftWrist];
    final rAnkle    = lm[PoseLandmarkType.rightAnkle];
    final lAnkle    = lm[PoseLandmarkType.leftAnkle];

    if (rShoulder == null || lShoulder == null || rWrist == null || lWrist == null || rAnkle == null || lAnkle == null) {
      return null;
    }

    // Y is 0 at top, 1 at bottom
    final bool armsUp = rWrist.y < rShoulder.y && lWrist.y < lShoulder.y;
    final bool armsDown = rWrist.y > rShoulder.y && lWrist.y > lShoulder.y;
    
    // X distance
    final double shoulderWidth = (rShoulder.x - lShoulder.x).abs();
    final double ankleWidth = (rAnkle.x - lAnkle.x).abs();
    final bool legsOpen = ankleWidth > (shoulderWidth * 1.5);
    final bool legsClosed = ankleWidth < (shoulderWidth * 1.2);

    String feedback = 'Mulai Jumping Jack!';
    bool isGood = true;

    if (armsUp && legsOpen) {
      if (_stage != 'up') {
        _stage = 'up';
        _qualityTracker.onStageChange(true);
      }
      feedback = 'Bagus! Lengan & Kaki terbuka.';
    } else if (armsDown && legsClosed) {
      if (_stage == 'up') {
        _stage = 'down';
        _counter++;
        _lastQuality = _qualityTracker.onRepComplete();
        _lastTempo = _qualityTracker.lastTempo;
      }
      feedback = 'Kembali ke posisi awal.';
    } else if (armsUp && !legsOpen) {
      feedback = 'Buka kaki lebih lebar!';
      isGood = false;
    } else if (!armsUp && legsOpen) {
      feedback = 'Angkat lengan tinggi-tinggi!';
      isGood = false;
    }

    _qualityTracker.onFrame(isGood);

    return JumpingJackAnalysis(
      repCount:       _counter,
      stage:          _stage,
      feedback:       feedback,
      isGoodPosture:  isGood,
      poses:          poses,
      qualityScore:   _lastQuality,
      tempo:          _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'down';
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ═════════════════════════════════════════════════════════════
// ⑥ HIGH KNEE
// Deteksi angkat lutut tinggi secara bergantian (alternating)
// ═════════════════════════════════════════════════════════════
class HighKneeAnalysis {
  final int    repCount;
  final String stage;        // 'right_up' | 'left_up' | 'down'
  final String feedback;
  final bool   isGoodPosture;
  final List<Pose> poses;
  final double qualityScore;
  final double tempo;

  const HighKneeAnalysis({
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class HighKneeDetectorService extends _PoseServiceBase {
  static final HighKneeDetectorService _i = HighKneeDetectorService._();
  factory HighKneeDetectorService() => _i;
  HighKneeDetectorService._();

  static const double _kneeFlexThreshold = 100.0; // knee < 100 = flexed
  static const double _extendThreshold   = 150.0; // knee > 150 = extended
  static const int    _kWindow           = 3;     // faster response than mountain climber

  final Queue<double> _rightBuf = Queue();
  final Queue<double> _leftBuf  = Queue();
  int    _counter = 0;
  String _stage   = 'down';
  String _lastDrivenKnee = ''; // 'right' or 'left'
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<HighKneeAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final rHip   = lm[PoseLandmarkType.rightHip];
    final rKnee  = lm[PoseLandmarkType.rightKnee];
    final rAnkle = lm[PoseLandmarkType.rightAnkle];
    final lHip   = lm[PoseLandmarkType.leftHip];
    final lKnee  = lm[PoseLandmarkType.leftKnee];
    final lAnkle = lm[PoseLandmarkType.leftAnkle];

    if (rHip == null || rKnee == null || rAnkle == null ||
        lHip == null || lKnee == null || lAnkle == null) {
      return null;
    }

    final rightKneeFlex = _smooth(_rightBuf,
        calculateAngle(_pt(rHip), _pt(rKnee), _pt(rAnkle)), _kWindow);
    final leftKneeFlex  = _smooth(_leftBuf,
        calculateAngle(_pt(lHip), _pt(lKnee), _pt(lAnkle)), _kWindow);

    String currentStage;
    if (rightKneeFlex < _kneeFlexThreshold && leftKneeFlex > _extendThreshold) {
      currentStage = 'right_up';
    } else if (leftKneeFlex < _kneeFlexThreshold && rightKneeFlex > _extendThreshold) {
      currentStage = 'left_up';
    } else {
      currentStage = 'down';
    }

    if (currentStage == 'right_up' && _lastDrivenKnee == 'left') {
      _counter++;
      _lastQuality = _qualityTracker.onRepComplete();
      _lastTempo = _qualityTracker.lastTempo;
      _lastDrivenKnee = 'right';
      _qualityTracker.onStageChange(true);
    } else if (currentStage == 'left_up' && _lastDrivenKnee == 'right') {
      _counter++;
      _lastQuality = _qualityTracker.onRepComplete();
      _lastTempo = _qualityTracker.lastTempo;
      _lastDrivenKnee = 'left';
      _qualityTracker.onStageChange(true);
    } else if (currentStage == 'right_up' && _lastDrivenKnee.isEmpty) {
      _lastDrivenKnee = 'right';
    } else if (currentStage == 'left_up' && _lastDrivenKnee.isEmpty) {
      _lastDrivenKnee = 'left';
    }

    _stage = currentStage;
    final bool isGood = true; // Mostly standing, just encouraging faster knees
    String feedback = 'Angkat lututmu sejajar pinggul secara bergantian!';
    if (currentStage == 'right_up' || currentStage == 'left_up') {
      feedback = 'Bagus! Pertahankan ritme.';
    }

    _qualityTracker.onFrame(isGood);

    return HighKneeAnalysis(
      repCount:       _counter,
      stage:          _stage,
      feedback:       feedback,
      isGoodPosture:  isGood,
      poses:          poses,
      qualityScore:   _lastQuality,
      tempo:          _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'down';
    _lastDrivenKnee = '';
    _rightBuf.clear();
    _leftBuf.clear();
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ═════════════════════════════════════════════════════════════
// ⑦ SHOULDER PRESS
// Menggunakan sudut bahu, siku, dan pergelangan tangan dari depan
// ═════════════════════════════════════════════════════════════
class ShoulderPressAnalysis {
  final int    repCount;
  final String stage;        // 'up' | 'down'
  final String feedback;
  final bool   isGoodPosture;
  final List<Pose> poses;
  final double qualityScore;
  final double tempo;

  const ShoulderPressAnalysis({
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
    this.qualityScore = 100.0,
    this.tempo = 0.0,
  });
}

class ShoulderPressDetectorService extends _PoseServiceBase {
  static final ShoulderPressDetectorService _i = ShoulderPressDetectorService._();
  factory ShoulderPressDetectorService() => _i;
  ShoulderPressDetectorService._();

  static const double _downThreshold = 90.0;  // siku menekuk sekitar 90 derajat
  static const double _upThreshold   = 150.0; // siku lurus ke atas
  static const int    _kWindow       = 5;

  final Queue<double> _elbowBuf = Queue();
  int    _counter = 0;
  String _stage   = 'down';
  final RepQualityTracker _qualityTracker = RepQualityTracker();
  double _lastQuality = 100.0;
  double _lastTempo = 0.0;

  Future<ShoulderPressAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    // Boleh pakai sisi kiri atau kanan yang visibilitasnya lebih bagus
    final rShoulder = lm[PoseLandmarkType.rightShoulder];
    final rElbow    = lm[PoseLandmarkType.rightElbow];
    final rWrist    = lm[PoseLandmarkType.rightWrist];
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lElbow    = lm[PoseLandmarkType.leftElbow];
    final lWrist    = lm[PoseLandmarkType.leftWrist];

    // Cek sisi yang paling valid
    bool useRight = true;
    if (rShoulder == null || rElbow == null || rWrist == null) {
      useRight = false;
    }
    if (!useRight && (lShoulder == null || lElbow == null || lWrist == null)) {
      return null;
    }

    final shoulder = useRight ? _pt(rShoulder!) : _pt(lShoulder!);
    final elbow    = useRight ? _pt(rElbow!) : _pt(lElbow!);
    final wrist    = useRight ? _pt(rWrist!) : _pt(lWrist!);

    final elbowAngle = _smooth(_elbowBuf,
        calculateAngle(shoulder, elbow, wrist), _kWindow);

    String feedback = '';
    bool isGood = true;

    if (elbowAngle < 60) {
      feedback = 'Siku terlalu turun, jaga sejajar bahu!';
      isGood = false;
    } else if (_stage == 'down' && elbowAngle > _downThreshold && elbowAngle < _upThreshold) {
      feedback = 'Dorong ke atas!';
      isGood = true;
    } else if (_stage == 'up' && elbowAngle < _upThreshold) {
      feedback = 'Turun perlahan-lahan ke bahu.';
      isGood = true;
    } else if (elbowAngle > _upThreshold) {
      feedback = 'Rentangan lengan yang bagus!';
      isGood = true;
    } else {
      feedback = 'Siap pada posisi!';
      isGood = true;
    }

    _qualityTracker.onFrame(isGood);

    if (elbowAngle < _downThreshold) {
      if (_stage != 'down') {
        _qualityTracker.onStageChange(isGood);
      }
      _stage = 'down';
    } else if (elbowAngle > _upThreshold && _stage == 'down') {
      _stage = 'up';
      _counter++;
      _lastQuality = _qualityTracker.onRepComplete();
      _lastTempo = _qualityTracker.lastTempo;
    }

    return ShoulderPressAnalysis(
      repCount:       _counter,
      stage:          _stage,
      feedback:       feedback,
      isGoodPosture:  isGood,
      poses:          poses,
      qualityScore:   _lastQuality,
      tempo:          _lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'down';
    _elbowBuf.clear();
    _qualityTracker.reset();
    _lastQuality = 100.0;
    _lastTempo = 0.0;
  }
}

// ─────────────────────────────────────────────────────────────
// HELPER: CameraImage → InputImage untuk ML Kit
// ─────────────────────────────────────────────────────────────
InputImage? cameraImageToInputImage(
  CameraImage image,
  int sensorOrientation,
  bool isFrontCamera,
) {
  // Kamera depan: rotasi dibalik agar deteksi tidak mirror
  final InputImageRotation? rotation = isFrontCamera
      ? switch (sensorOrientation) {
          90  => InputImageRotation.rotation270deg,
          270 => InputImageRotation.rotation90deg,
          _   => InputImageRotationValue.fromRawValue(sensorOrientation),
        }
      : InputImageRotationValue.fromRawValue(sensorOrientation);

  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  // Gabungkan semua plane (NV21 Android / BGRA8888 iOS)
  final WriteBuffer allBytes = WriteBuffer();
  for (final plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }

  return InputImage.fromBytes(
    bytes: allBytes.done().buffer.asUint8List(),
    metadata: InputImageMetadata(
      size:         Size(image.width.toDouble(), image.height.toDouble()),
      rotation:     rotation,
      format:       format,
      bytesPerRow:  image.planes[0].bytesPerRow,
    ),
  );
}
