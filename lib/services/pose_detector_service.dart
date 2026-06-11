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

// ─────────────────────────────────────────────────────────────
// REP QUALITY TRACKER — tempo + quality scoring per rep
// ─────────────────────────────────────────────────────────────
class RepQualityTracker {
  final List<double> _repScores = [];
  final List<double> _repTempos = []; // seconds per rep
  DateTime? _lastStageChange;
  int _badFormFrames = 0;
  int _totalFramesInRep = 0;
  int _commonMistakeCount = 0;
  String _mostCommonMistake = '';
  final Map<String, int> _mistakeCounts = {};

  /// Call when stage changes (e.g. up→down or down→up)
  void onStageChange(bool isGoodForm) {
    final now = DateTime.now();
    if (_lastStageChange != null) {
      final elapsed = now.difference(_lastStageChange!).inMilliseconds / 1000.0;
      if (elapsed > 0.2) { // ignore micro-transitions
        _repTempos.add(elapsed);
      }
    }
    _lastStageChange = now;
  }

  /// Call on every frame to track form quality within current rep
  void onFrame(bool isGoodForm, String feedback) {
    _totalFramesInRep++;
    if (!isGoodForm) {
      _badFormFrames++;
      if (feedback.isNotEmpty && feedback != 'Postur Bagus' && feedback != 'Mendeteksi pose...') {
        _mistakeCounts[feedback] = (_mistakeCounts[feedback] ?? 0) + 1;
      }
    }
  }

  /// Call when a rep is counted — returns quality score 0-100
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

  /// Current quality score (0-100) — average of all reps
  double get avgQuality {
    if (_repScores.isEmpty) return 0;
    return _repScores.reduce((a, b) => a + b) / _repScores.length;
  }

  /// Quality of the last rep
  double get lastRepQuality => _repScores.isEmpty ? 0 : _repScores.last;

  /// Average tempo in seconds
  double get avgTempo {
    if (_repTempos.isEmpty) return 0;
    return _repTempos.reduce((a, b) => a + b) / _repTempos.length;
  }

  /// Tempo of last rep in seconds
  double get lastTempo => _repTempos.isEmpty ? 0 : _repTempos.last;

  /// Is the current tempo too fast? (< 0.8s per half-rep)
  bool get isTooFast => lastTempo > 0 && lastTempo < 0.8;

  /// Is the current tempo too slow? (> 5s per half-rep)
  bool get isTooSlow => lastTempo > 5.0;

  /// Form summary for end-of-set display
  Map<String, dynamic> get summary => {
    'avgQuality': avgQuality.round(),
    'totalReps': _repScores.length,
    'avgTempo': double.parse(avgTempo.toStringAsFixed(1)),
    'bestRep': _repScores.isEmpty ? 0 : _repScores.reduce(math.max).round(),
    'worstRep': _repScores.isEmpty ? 0 : _repScores.reduce(math.min).round(),
    'mistakes': Map<String, int>.from(_mistakeCounts),
  };

  void reset() {
    _repScores.clear();
    _repTempos.clear();
    _lastStageChange = null;
    _badFormFrames = 0;
    _totalFramesInRep = 0;
    _commonMistakeCount = 0;
    _mostCommonMistake = '';
    _mistakeCounts.clear();
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
  final double qualityScore; // 0-100 avg quality
  final double tempo;        // seconds per half-rep

  const PushUpAnalysis({
    required this.elbowAngle,
    required this.hipAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.poses,
    this.qualityScore = 0,
    this.tempo = 0,
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
  final _quality = RepQualityTracker();

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
      feedback      = 'Silakan ambil posisi di lantai!';
      isGoodPosture = false;
    } else if (hipAngle < _hipLowWarn) {
      feedback      = 'Pinggul Turun!';
      isGoodPosture = false;
    } else if (hipAngle > _hipHighWarn) {
      feedback      = 'Pinggul Terlalu Naik!';
      isGoodPosture = false;
    } else {
      feedback      = 'Postur Bagus';
      isGoodPosture = true;
    }

    // Counting — hanya saat horizontal & badan valid
    if (isHorizontal && hipAngle > _bodyThreshold) {
      if (elbowAngle < _downThreshold) {
        if (_stage != 'down') {
          _quality.onStageChange(isGoodPosture);
          _stage = 'down';
        }
      } else if (elbowAngle > _upThreshold && _stage == 'down') {
        _stage = 'up';
        _quality.onStageChange(isGoodPosture);
        _quality.onRepComplete();
        _counter++;
      }
    }
    _quality.onFrame(isGoodPosture, feedback);

    return PushUpAnalysis(
      elbowAngle:   elbowAngle,
      hipAngle:     hipAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     _quality.isTooFast ? 'Terlalu Cepat! Perlambat.' : feedback,
      isGoodPosture: _quality.isTooFast ? false : isGoodPosture,
      isHorizontal: isHorizontal,
      poses:        poses,
      qualityScore: _quality.avgQuality,
      tempo:        _quality.lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _elbowBuf.clear();
    _hipBuf.clear();
    _quality.reset();
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
    this.qualityScore = 0,
    this.tempo = 0,
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
  final _quality  = RepQualityTracker();

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
      feedback      = 'Silakan berbaring di lantai!';
      isGoodPosture = false;
    } else if (neckAngle < _neckThreshold) {
      feedback      = 'Leher Terlalu Maju!';
      isGoodPosture = false;
    } else if (bodyAngle < _tooForwardBody) {
      feedback      = 'Terlalu Membungkuk!';
      isGoodPosture = false;
    } else if (_stage == 'up' &&
               bodyAngle > _goodUpMax &&
               bodyAngle < _downThreshold) {
      feedback      = 'Naik Lebih Tinggi!';
      isGoodPosture = false;
    } else if (bodyAngle > _downThreshold) {
      feedback      = 'Posisi Bawah / Siap';
      isGoodPosture = true;
    } else {
      feedback      = 'Postur Bagus';
      isGoodPosture = true;
    }

    // Counting — hanya saat horizontal
    if (isHorizontal) {
      if (bodyAngle > _downThreshold) {
        if (_stage != 'down') {
          _quality.onStageChange(isGoodPosture);
          _stage = 'down';
        }
      } else if (bodyAngle < _upThreshold && _stage == 'down') {
        // Rep valid hanya jika sudut masuk range yang ditentukan Python
        if (bodyAngle >= _goodUpMin && bodyAngle <= _goodUpMax) {
          _quality.onStageChange(isGoodPosture);
          _quality.onRepComplete();
          _counter++;
          _stage = 'up';
        }
      }
    }
    _quality.onFrame(isGoodPosture, feedback);

    return SitUpAnalysis(
      bodyAngle:    bodyAngle,
      neckAngle:    neckAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     _quality.isTooFast ? 'Terlalu Cepat! Perlambat.' : feedback,
      isGoodPosture: _quality.isTooFast ? false : isGoodPosture,
      isHorizontal: isHorizontal,
      poses:        poses,
      qualityScore: _quality.avgQuality,
      tempo:        _quality.lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'down';
    _bodyBuf.clear();
    _neckBuf.clear();
    _quality.reset();
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
    this.qualityScore = 0,
    this.tempo = 0,
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
  final _quality  = RepQualityTracker();

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
      feedback      = 'Tegakkan Punggungmu!';
      isGoodPosture = false;
    } else if ((knee[0] - ankle[0]).abs() > _kneeFwdLimit) {
      // P2: lutut maju melebihi jari kaki (normalized x-coord)
      feedback      = 'Lutut Melewati Jari Kaki!';
      isGoodPosture = false;
    } else if (_stage == 'down' && kneeAngle > _downThreshold) {
      // P3: belum cukup dalam saat sudah mulai turun
      feedback      = 'Turun Lebih Dalam!';
      isGoodPosture = false;
    } else {
      feedback      = 'Postur Bagus!';
      isGoodPosture = true;
    }

    // Counting
    if (kneeAngle < _downThreshold) {
      if (_stage != 'down') {
        _quality.onStageChange(isGoodPosture);
        _stage = 'down';
      }
    } else if (kneeAngle > _upThreshold && _stage == 'down') {
      _stage = 'up';
      _quality.onStageChange(isGoodPosture);
      _quality.onRepComplete();
      _counter++;
    }
    _quality.onFrame(isGoodPosture, feedback);

    return SquatAnalysis(
      kneeAngle:    kneeAngle,
      backAngle:    backAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     _quality.isTooFast ? 'Terlalu Cepat! Perlambat.' : feedback,
      isGoodPosture: _quality.isTooFast ? false : isGoodPosture,
      poses:        poses,
      qualityScore: _quality.avgQuality,
      tempo:        _quality.lastTempo,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _kneeBuf.clear();
    _backBuf.clear();
    _quality.reset();
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
      feedback      = 'Tubuh Belum Horizontal!';
      isGoodPosture = false;
    } else if (!kneesLifted) {
      feedback      = 'Angkat Lututmu!';
      isGoodPosture = false;
    } else if (!elbowGood) {
      feedback      = 'Sejajarkan Siku di Bawah Bahu!';
      isGoodPosture = false;
    } else if (!neckGood) {
      feedback      = 'Jaga Leher Tetap Netral!';
      isGoodPosture = false;
    } else if (stability > _stabilityLim) {
      feedback      = 'Tahan Posisi!';
      isGoodPosture = false;
    } else if (hipAngle >= _hipGood) {
      feedback      = 'Plank Sempurna!';
      isGoodPosture = true;
    } else if (hipAngle >= _hipWarning) {
      // Cek apakah pinggul terlalu rendah atau terlalu tinggi
      final midY = (shoulder[1] + ankle[1]) / 2;
      if (hip[1] > midY) {
        feedback = 'Angkat Pinggulmu!';
      } else {
        feedback = 'Turunkan Pinggulmu!';
      }
      isGoodPosture = false;
    } else {
      feedback      = 'Perbaiki Posturmu!';
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

// ─────────────────────────────────────────────────────────────
// ⑤ LUNGE
// Landmarks: LEFT shoulder, hip, knee, ankle + RIGHT knee
// knee_angle: calculate_angle(hip, knee, ankle) on front leg
// torso_angle: calculate_angle(shoulder, hip, knee) — uprightness
//
// Thresholds:
//   DOWN  = 100  knee < 100 → stage down
//   UP    = 160  knee > 160 → stage up, counter++
//   TORSO = 150  torso < 150 → leaning forward too much
//   KNEE_FWD = 0.10  |knee.x − ankle.x| > 0.10 → knee past toes
// ═════════════════════════════════════════════════════════════
class LungeAnalysis {
  final double kneeAngle;
  final double torsoAngle;
  final int repCount;
  final String stage;
  final String feedback;
  final bool isGoodPosture;
  final List<Pose> poses;

  const LungeAnalysis({
    required this.kneeAngle,
    required this.torsoAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
  });
}

class LungeDetectorService extends _PoseServiceBase {
  static final LungeDetectorService _i = LungeDetectorService._();
  factory LungeDetectorService() => _i;
  LungeDetectorService._();

  static const double _downThreshold = 100.0;
  static const double _upThreshold = 160.0;
  static const double _torsoThreshold = 150.0;
  static const double _kneeFwdLimit = 0.10;
  static const int _kWindow = 5;

  final Queue<double> _kneeBuf = Queue();
  final Queue<double> _torsoBuf = Queue();
  int _counter = 0;
  String _stage = 'up';

  Future<LungeAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lHip = lm[PoseLandmarkType.leftHip];
    final lKnee = lm[PoseLandmarkType.leftKnee];
    final lAnkle = lm[PoseLandmarkType.leftAnkle];

    if (lShoulder == null || lHip == null ||
        lKnee == null || lAnkle == null) {
      return null;
    }
    if (lHip.likelihood < 0.5) return null;

    final shoulder = _pt(lShoulder);
    final hip = _pt(lHip);
    final knee = _pt(lKnee);
    final ankle = _pt(lAnkle);

    final kneeAngle = _smooth(_kneeBuf,
        calculateAngle(hip, knee, ankle), _kWindow);
    final torsoAngle = _smooth(_torsoBuf,
        calculateAngle(shoulder, hip, knee), _kWindow);

    late final String feedback;
    late final bool isGoodPosture;

    if (torsoAngle < _torsoThreshold) {
      feedback = 'Tegakkan Badanmu!';
      isGoodPosture = false;
    } else if ((knee[0] - ankle[0]).abs() > _kneeFwdLimit) {
      feedback = 'Lutut Melewati Jari Kaki!';
      isGoodPosture = false;
    } else if (_stage == 'down' && kneeAngle > _downThreshold && kneeAngle < _upThreshold) {
      feedback = 'Turun Lebih Dalam!';
      isGoodPosture = false;
    } else {
      feedback = 'Postur Bagus!';
      isGoodPosture = true;
    }

    if (kneeAngle < _downThreshold) {
      _stage = 'down';
    } else if (kneeAngle > _upThreshold && _stage == 'down') {
      _stage = 'up';
      _counter++;
    }

    return LungeAnalysis(
      kneeAngle: kneeAngle,
      torsoAngle: torsoAngle,
      repCount: _counter,
      stage: _stage,
      feedback: feedback,
      isGoodPosture: isGoodPosture,
      poses: poses,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'up';
    _kneeBuf.clear();
    _torsoBuf.clear();
  }
}

// ═════════════════════════════════════════════════════════════
// ⑥ BURPEE
// Multi-phase detection using body angle + vertical position
// Phases: standing → squat → plank → pushup → squat → jump
// Simplified: count full cycles standing → down → up → standing
// ═════════════════════════════════════════════════════════════
class BurpeeAnalysis {
  final double bodyAngle;
  final double kneeAngle;
  final int repCount;
  final String stage; // 'up' | 'down' | 'plank'
  final String feedback;
  final bool isGoodPosture;
  final List<Pose> poses;

  const BurpeeAnalysis({
    required this.bodyAngle,
    required this.kneeAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
  });
}

class BurpeeDetectorService extends _PoseServiceBase {
  static final BurpeeDetectorService _i = BurpeeDetectorService._();
  factory BurpeeDetectorService() => _i;
  BurpeeDetectorService._();

  // Burpee phases detected via knee angle + body angle
  static const double _squatThreshold = 110.0; // knee < 110 → squat position
  static const double _standingThreshold = 155.0; // knee > 155 → standing
  static const double _plankBodyThreshold = 160.0; // body > 160 → body straight (plank)
  static const int _kWindow = 5;

  final Queue<double> _kneeBuf = Queue();
  final Queue<double> _bodyBuf = Queue();
  int _counter = 0;
  String _stage = 'up'; // 'up' | 'down' | 'plank'
  bool _wasInPlank = false;

  Future<BurpeeAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lHip = lm[PoseLandmarkType.leftHip];
    final lKnee = lm[PoseLandmarkType.leftKnee];
    final lAnkle = lm[PoseLandmarkType.leftAnkle];

    if (lShoulder == null || lHip == null ||
        lKnee == null || lAnkle == null) {
      return null;
    }
    if (lHip.likelihood < 0.4) return null;

    final shoulder = _pt(lShoulder);
    final hip = _pt(lHip);
    final knee = _pt(lKnee);
    final ankle = _pt(lAnkle);

    final kneeAngle = _smooth(_kneeBuf,
        calculateAngle(hip, knee, ankle), _kWindow);
    final bodyAngle = _smooth(_bodyBuf,
        calculateAngle(shoulder, hip, ankle), _kWindow);

    // Detect if in plank (horizontal) position
    final xDiff = (shoulder[0] - ankle[0]).abs();
    final yDiff = (shoulder[1] - ankle[1]).abs();
    final isHorizontal = xDiff > (yDiff * 1.2) || yDiff > (xDiff * 1.2);
    final isInPlank = isHorizontal && bodyAngle > _plankBodyThreshold;

    late final String feedback;
    late final bool isGoodPosture;

    if (_stage == 'up') {
      feedback = 'Siap! Turun ke posisi squat.';
      isGoodPosture = true;
    } else if (_stage == 'down' && !isInPlank) {
      feedback = 'Turun ke posisi plank!';
      isGoodPosture = true;
    } else if (isInPlank) {
      feedback = 'Plank! Sekarang loncat berdiri!';
      isGoodPosture = true;
    } else {
      feedback = 'Lanjutkan gerakan!';
      isGoodPosture = true;
    }

    // State machine: up → down → plank → up = 1 rep
    if (kneeAngle < _squatThreshold && _stage == 'up') {
      _stage = 'down';
      _wasInPlank = false;
    } else if (isInPlank && _stage == 'down') {
      _wasInPlank = true;
      _stage = 'plank';
    } else if (kneeAngle > _standingThreshold && (_stage == 'plank' || (_stage == 'down' && _wasInPlank))) {
      _stage = 'up';
      _counter++;
      _wasInPlank = false;
    }

    return BurpeeAnalysis(
      bodyAngle: bodyAngle,
      kneeAngle: kneeAngle,
      repCount: _counter,
      stage: _stage,
      feedback: feedback,
      isGoodPosture: isGoodPosture,
      poses: poses,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'up';
    _wasInPlank = false;
    _kneeBuf.clear();
    _bodyBuf.clear();
  }
}

// ═════════════════════════════════════════════════════════════
// ⑦ MOUNTAIN CLIMBER
// Alternating knee drives in plank position
// Tracks knee angle changes to count alternating reps
// ═════════════════════════════════════════════════════════════
class MountainClimberAnalysis {
  final double leftKneeAngle;
  final double rightKneeAngle;
  final double hipAngle;
  final int repCount;
  final String stage; // 'left' | 'right' — which knee is forward
  final String feedback;
  final bool isGoodPosture;
  final List<Pose> poses;

  const MountainClimberAnalysis({
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.hipAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
  });
}

class MountainClimberDetectorService extends _PoseServiceBase {
  static final MountainClimberDetectorService _i =
      MountainClimberDetectorService._();
  factory MountainClimberDetectorService() => _i;
  MountainClimberDetectorService._();

  static const double _kneeForwardThreshold = 120.0; // knee bent = forward
  static const double _kneeExtendedThreshold = 150.0; // knee straight = back
  static const double _hipGood = 155.0;
  static const double _hipWarn = 140.0;
  static const int _kWindow = 5;

  final Queue<double> _leftKneeBuf = Queue();
  final Queue<double> _rightKneeBuf = Queue();
  final Queue<double> _hipBuf = Queue();
  int _counter = 0;
  String _stage = 'left'; // which leg is currently forward

  Future<MountainClimberAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final lm = poses.first.landmarks;
    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final lHip = lm[PoseLandmarkType.leftHip];
    final lKnee = lm[PoseLandmarkType.leftKnee];
    final lAnkle = lm[PoseLandmarkType.leftAnkle];
    final rHip = lm[PoseLandmarkType.rightHip];
    final rKnee = lm[PoseLandmarkType.rightKnee];
    final rAnkle = lm[PoseLandmarkType.rightAnkle];

    if (lShoulder == null || lHip == null || lKnee == null || lAnkle == null ||
        rHip == null || rKnee == null || rAnkle == null) {
      return null;
    }
    if (lHip.likelihood < 0.4 || rHip.likelihood < 0.4) return null;

    final lShoulderPt = _pt(lShoulder);
    final lHipPt = _pt(lHip);
    final lKneePt = _pt(lKnee);
    final lAnklePt = _pt(lAnkle);
    final rHipPt = _pt(rHip);
    final rKneePt = _pt(rKnee);
    final rAnklePt = _pt(rAnkle);

    final leftKneeAngle = _smooth(_leftKneeBuf,
        calculateAngle(lHipPt, lKneePt, lAnklePt), _kWindow);
    final rightKneeAngle = _smooth(_rightKneeBuf,
        calculateAngle(rHipPt, rKneePt, rAnklePt), _kWindow);
    final hipAngle = _smooth(_hipBuf,
        calculateAngle(lShoulderPt, lHipPt, lAnklePt), _kWindow);

    // Hip height check
    late final String feedback;
    late final bool isGoodPosture;

    if (hipAngle < _hipWarn) {
      feedback = 'Angkat Pinggulmu!';
      isGoodPosture = false;
    } else if (hipAngle < _hipGood) {
      feedback = 'Pinggul Sedikit Turun!';
      isGoodPosture = false;
    } else {
      feedback = 'Bagus! Terus bergerak!';
      isGoodPosture = true;
    }

    // Alternating knee detection
    final leftForward = leftKneeAngle < _kneeForwardThreshold;
    final rightForward = rightKneeAngle < _kneeForwardThreshold;
    final leftExtended = leftKneeAngle > _kneeExtendedThreshold;
    final rightExtended = rightKneeAngle > _kneeExtendedThreshold;

    // Count when legs alternate
    if (_stage == 'left' && rightForward && leftExtended) {
      _stage = 'right';
      _counter++;
    } else if (_stage == 'right' && leftForward && rightExtended) {
      _stage = 'left';
      _counter++;
    }

    return MountainClimberAnalysis(
      leftKneeAngle: leftKneeAngle,
      rightKneeAngle: rightKneeAngle,
      hipAngle: hipAngle,
      repCount: _counter,
      stage: _stage,
      feedback: feedback,
      isGoodPosture: isGoodPosture,
      poses: poses,
    );
  }

  void reset() {
    _counter = 0;
    _stage = 'left';
    _leftKneeBuf.clear();
    _rightKneeBuf.clear();
    _hipBuf.clear();
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
