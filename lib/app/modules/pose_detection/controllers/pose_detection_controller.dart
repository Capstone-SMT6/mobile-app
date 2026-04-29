import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionController extends GetxController {
  CameraController? cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  
  RxBool isCameraInitialized = false.obs;
  RxString feedbackMessage = "Mulai Latihan...".obs;
  RxBool isBadPosture = false.obs;

  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      cameraController!.startImageStream((image) {
        if (_isProcessing) return;
        _isProcessing = true;
        _processCameraImage(image);
      });
    } catch (e) {
      feedbackMessage.value = "Gagal memuat kamera: $e";
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = cameraController!.description;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation270deg;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv420;
      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      final poses = await _poseDetector.processImage(inputImage);

      _evaluatePose(poses);
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _evaluatePose(List<Pose> poses) {
    if (poses.isEmpty) {
      feedbackMessage.value = "Tubuh tidak terdeteksi";
      isBadPosture.value = false;
      return;
    }

    final pose = poses.first;
    // FR-04, FR-05: Ekstraksi Keypoints
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];

    // Evaluasi Push-Up / Squat Example
    if (shoulder != null && elbow != null && wrist != null && hip != null) {
      // FR-06: Evaluasi Logika Koreksi (Trigonometri)
      double backAngle = 0;
      if (knee != null) {
        backAngle = _calculateAngle(shoulder.x, shoulder.y, hip.x, hip.y, knee.x, knee.y);
      }

      if (backAngle > 0 && backAngle < 150) {
        // FR-07: Real-time Feedback (Punggung Melorot)
        feedbackMessage.value = "AWAS! Luruskan punggung Anda!";
        isBadPosture.value = true;
      } else {
        feedbackMessage.value = "Postur Bagus. Lanjutkan!";
        isBadPosture.value = false;
      }
    } else {
      feedbackMessage.value = "Pastikan seluruh tubuh masuk layar";
      isBadPosture.value = false;
    }
  }

  double _calculateAngle(double ax, double ay, double bx, double by, double cx, double cy) {
    double radians = atan2(cy - by, cx - bx) - atan2(ay - by, ax - bx);
    double angle = (radians * 180.0 / pi).abs();
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _poseDetector.close();
    super.onClose();
  }
}
