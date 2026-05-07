import 'dart:math' as math;
import 'dart:ui';
import 'dart:collection';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// ─────────────────────────────────────────────────────────────
// RESULT MODEL
// ─────────────────────────────────────────────────────────────
class PushUpAnalysis {
  final double elbowAngle;   // sudut siku
  final double hipAngle;     // sudut pinggul (validasi postur)
  final int repCount;        // jumlah repetisi
  final String stage;        // 'up' atau 'down'
  final String feedback;     // pesan postur
  final bool isGoodPosture;  // postur bagus atau tidak
  final List<Pose> poses;    // raw landmarks untuk overlay

  const PushUpAnalysis({
    required this.elbowAngle,
    required this.hipAngle,
    required this.repCount,
    required this.stage,
    required this.feedback,
    required this.isGoodPosture,
    required this.poses,
  });
}

// ─────────────────────────────────────────────────────────────
// POSE DETECTOR SERVICE
// Port 1:1 dari logic Python MediaPipe kamu
// ─────────────────────────────────────────────────────────────
class PoseDetectorService {
  // ── Singleton ─────────────────────────────────────────────
  static final PoseDetectorService _instance =
      PoseDetectorService._internal();
  factory PoseDetectorService() => _instance;
  PoseDetectorService._internal();

  late PoseDetector _poseDetector;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream, // realtime camera stream
        model: PoseDetectionModel.base, // akurat & ringan
      ),
    );
    _initialized = true;
  }

  // ── Thresholds (sama persis dari Python-mu) ───────────────
  static const double _downThreshold = 100.0;   // elbow_angle < 100 → down
  static const double _upThreshold = 150.0;     // elbow_angle > 150 → up
  static const double _bodyThreshold = 150.0;   // hip_angle > 150 → valid
  static const double _hipLowWarn = 140.0;      // hip < 140 → turun
  static const double _hipHighWarn = 200.0;     // hip > 200 → terlalu naik
  static const int _smoothWindow = 5;           // moving average window

  // ── Smoothing buffers (python: deque(maxlen=5)) ───────────
  final Queue<double> _elbowBuffer = Queue<double>();
  final Queue<double> _hipBuffer = Queue<double>();

  // ── State ─────────────────────────────────────────────────
  int _counter = 0;
  String _stage = 'up';

  // ─── FUNGSI HITUNG SUDUT (port dari calculate_angle) ──────
  //
  // Python:
  //   radians = arctan2(c[1]-b[1], c[0]-b[0]) - arctan2(a[1]-b[1], a[0]-b[0])
  //   angle = abs(radians * 180 / pi)
  //   return 360 - angle if angle > 180 else angle
  //
  static double calculateAngle(
    List<double> a, // point A [x, y]
    List<double> b, // point B (titik siku/pinggul) [x, y]
    List<double> c, // point C [x, y]
  ) {
    final radians = math.atan2(c[1] - b[1], c[0] - b[0]) -
        math.atan2(a[1] - b[1], a[0] - b[0]);
    double angle = (radians * 180.0 / math.pi).abs();
    return angle > 180 ? 360 - angle : angle;
  }

  // ─── SMOOTHING (port dari numpy.mean(buffer)) ─────────────
  double _smooth(Queue<double> buffer, double newValue) {
    buffer.addLast(newValue);
    if (buffer.length > _smoothWindow) buffer.removeFirst();
    return buffer.reduce((a, b) => a + b) / buffer.length;
  }

  // ─── GET POINT dari landmark (normalized coords [0..1]) ───
  static List<double> _getPoint(PoseLandmark lm) => [lm.x, lm.y];

  // ─── PROSES FRAME KAMERA → PushUpAnalysis ─────────────────
  Future<PushUpAnalysis?> processImage(InputImage inputImage) async {
    if (!_initialized) init();

    final poses = await _poseDetector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final pose = poses.first;
    final landmarks = pose.landmarks;

    // ── Ambil landmark yang dibutuhkan ───────────────────────
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

    if (leftShoulder == null ||
        leftElbow == null ||
        leftWrist == null ||
        leftHip == null ||
        leftAnkle == null) {
      return null;
    }

    // ── Validasi visibility (python: visibility < 0.5 → skip) ─
    if (leftElbow.likelihood < 0.5) return null;

    // ── Koordinat [x, y] normalized ──────────────────────────
    final shoulder = _getPoint(leftShoulder);
    final elbow = _getPoint(leftElbow);
    final wrist = _getPoint(leftWrist);
    final hip = _getPoint(leftHip);
    final ankle = _getPoint(leftAnkle);

    // ── Hitung sudut mentah ───────────────────────────────────
    final rawElbow = calculateAngle(shoulder, elbow, wrist); // sudut siku
    final rawHip = calculateAngle(shoulder, hip, ankle);     // sudut badan

    // ── Smoothing (moving average) ────────────────────────────
    final elbowAngle = _smooth(_elbowBuffer, rawElbow);
    final hipAngle = _smooth(_hipBuffer, rawHip);

    // ── Validasi postur & feedback ────────────────────────────
    // Python:
    //   if hip_angle < 140 → "Pinggul Turun!"
    //   elif hip_angle > 200 → "Pinggul Terlalu Naik!"
    //   else → "Postur Bagus"
    final bool isGoodPosture;
    final String feedback;

    if (hipAngle < _hipLowWarn) {
      feedback = 'Pinggul Turun!';
      isGoodPosture = false;
    } else if (hipAngle > _hipHighWarn) {
      feedback = 'Pinggul Terlalu Naik!';
      isGoodPosture = false;
    } else {
      feedback = 'Postur Bagus';
      isGoodPosture = true;
    }

    // ── Counting logic ────────────────────────────────────────
    // Python:
    //   valid_body = hip_angle > BODY_THRESHOLD (150)
    //   if valid_body:
    //     if elbow_angle < DOWN_THRESHOLD (100): stage = "down"
    //     elif elbow_angle > UP_THRESHOLD (150) and stage == "down":
    //       stage = "up"; counter++
    final bool validBody = hipAngle > _bodyThreshold;

    if (validBody) {
      if (elbowAngle < _downThreshold) {
        _stage = 'down';
      } else if (elbowAngle > _upThreshold && _stage == 'down') {
        _stage = 'up';
        _counter++;
      }
    }

    return PushUpAnalysis(
      elbowAngle: elbowAngle,
      hipAngle: hipAngle,
      repCount: _counter,
      stage: _stage,
      feedback: feedback,
      isGoodPosture: isGoodPosture,
      poses: poses,
    );
  }

  // ── Reset counter (saat mulai sesi baru) ──────────────────
  void reset() {
    _counter = 0;
    _stage = 'up';
    _elbowBuffer.clear();
    _hipBuffer.clear();
  }

  Future<void> close() async {
    if (_initialized) {
      await _poseDetector.close();
      _initialized = false;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HELPER: Konversi CameraImage → InputImage untuk ML Kit
// ─────────────────────────────────────────────────────────────
InputImage? cameraImageToInputImage(
  CameraImage image,
  int sensorOrientation,
  bool isFrontCamera,
) {
  // Rotasi sensor kamera → InputImageRotation
  InputImageRotation? rotation;
  if (isFrontCamera) {
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation270deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation90deg;
        break;
      default:
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
  } else {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  }
  if (rotation == null) return null;

  // Format piksel kamera
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  // Untuk NV21 (Android) dan BGRA8888 (iOS)
  // Gabungkan semua plane bytes
  final WriteBuffer allBytes = WriteBuffer();
  for (final plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}
