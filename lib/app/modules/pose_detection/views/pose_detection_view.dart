import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pose_detection_controller.dart';

class PoseDetectionView extends GetView<PoseDetectionController> {
  const PoseDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Smart Coach - Pose Detection'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (!controller.isCameraInitialized.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF6CC551)));
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                // Ensure camera preview fills the screen beautifully
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CameraPreview(controller.cameraController!),
                );
              }
            );
          }),

          // Overlay for instructions
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Posisikan perangkat Anda agar seluruh tubuh terlihat di layar saat melakukan Push-up / Squat.",
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // FR-07 Real-time Feedback UI
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Obx(() {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: controller.isBadPosture.value 
                      ? Colors.redAccent.withOpacity(0.9) 
                      : const Color(0xFF6CC551).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: controller.isBadPosture.value 
                          ? Colors.redAccent.withOpacity(0.5) 
                          : const Color(0xFF6CC551).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.isBadPosture.value ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        controller.feedbackMessage.value,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
