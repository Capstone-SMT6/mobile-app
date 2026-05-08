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

  const PushUpAnalysis({
    required this.elbowAngle,
    required this.hipAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.poses,
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
  static const double _bodyThreshold  = 150.0; // hip  > 150 → valid body
  static const double _hipLowWarn     = 140.0; // hip  < 140 → pinggul turun
  static const double _hipHighWarn    = 165.0; // hip  > 165 → pinggul naik
  static const double _horizontalRatio = 1.5;
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
    if (lElbow.likelihood < 0.5) { return null; }

    final shoulder = _pt(lShoulder);
    final elbow    = _pt(lElbow);
    final wrist    = _pt(lWrist);
    final hip      = _pt(lHip);
    final ankle    = _pt(lAnkle);

    final elbowAngle = _smooth(_elbowBuf,
        calculateAngle(shoulder, elbow, wrist), _kWindow);
    final hipAngle   = _smooth(_hipBuf,
        calculateAngle(shoulder, hip, ankle),   _kWindow);

    // Deteksi horizontal: saat plank/push-up selisih X >> selisih Y
    final xDiff = (shoulder[0] - ankle[0]).abs();
    final yDiff = (shoulder[1] - ankle[1]).abs();
    final isHorizontal = xDiff > (yDiff * _horizontalRatio);

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
        _stage = 'down';
      } else if (elbowAngle > _upThreshold && _stage == 'down') {
        _stage = 'up';
        _counter++;
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
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _elbowBuf.clear();
    _hipBuf.clear();
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

  const SitUpAnalysis({
    required this.bodyAngle,
    required this.neckAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.isHorizontal,
    required this.poses,
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
        _stage = 'down';
      } else if (bodyAngle < _upThreshold && _stage == 'down') {
        // Rep valid hanya jika sudut masuk range yang ditentukan Python
        if (bodyAngle >= _goodUpMin && bodyAngle <= _goodUpMax) {
          _counter++;
          _stage = 'up';
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
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'down';
    _bodyBuf.clear();
    _neckBuf.clear();
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

  const SquatAnalysis({
    required this.kneeAngle,
    required this.backAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
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
      _stage = 'down';
    } else if (kneeAngle > _upThreshold && _stage == 'down') {
      _stage = 'up';
      _counter++;
    }

    return SquatAnalysis(
      kneeAngle:    kneeAngle,
      backAngle:    backAngle,
      repCount:     _counter,
      stage:        _stage,
      feedback:     feedback,
      isGoodPosture: isGoodPosture,
      poses:        poses,
    );
  }

  void reset() {
    _counter = 0;
    _stage   = 'up';
    _kneeBuf.clear();
    _backBuf.clear();
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
