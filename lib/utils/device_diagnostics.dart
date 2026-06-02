import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class DeviceDiagnostics {
  static DeviceDiagnostics? _instance;
  
  DeviceDiagnostics._();
  
  factory DeviceDiagnostics() {
    _instance ??= DeviceDiagnostics._();
    return _instance!;
  }
  
  // Device info
  String? deviceModel;
  String? osVersion;
  bool isLowEndDevice = false;
  
  // Lighting analysis
  double currentBrightness = 0.0;
  String lightingCondition = 'Unknown';
  
  // Performance metrics
  final List<int> frameProcessingTimes = [];
  double avgFPS = 0.0;
  
  // ─── INITIALIZE DEVICE INFO ────────────────────────────
  Future<void> initialize() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      osVersion = 'Android ${androidInfo.version.release}';
      
      // Heuristic: device dengan RAM < 4GB = low-end
      // Atau SDK version < 28 (Android 9)
      isLowEndDevice = androidInfo.version.sdkInt < 28;
      
      debugPrint('📱 Device: $deviceModel');
      debugPrint('📱 OS: $osVersion');
      debugPrint('📱 Low-end: $isLowEndDevice');
      
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.model;
      osVersion = 'iOS ${iosInfo.systemVersion}';
      
      // iPhone 8 ke bawah considered low-end
      final modelNumber = iosInfo.utsname.machine;
      isLowEndDevice = _isOldIOSDevice(modelNumber);
      
      debugPrint('📱 Device: $deviceModel');
      debugPrint('📱 OS: $osVersion');
      debugPrint('📱 Low-end: $isLowEndDevice');
    }
  }
  
  bool _isOldIOSDevice(String model) {
    // iPhone models before iPhone X (2017)
    final oldModels = ['iPhone8', 'iPhone7', 'iPhone6', 'iPhone5'];
    return oldModels.any((old) => model.contains(old));
  }
  
  // ─── ANALYZE LIGHTING CONDITIONS ───────────────────────
  Future<void> analyzeLighting(CameraImage image) async {
    try {
      // Convert camera image to brightness value
      // Average luminance dari Y plane (untuk NV21 format)
      if (image.format.group == ImageFormatGroup.yuv420) {
        final yPlane = image.planes[0].bytes;
        
        // Sample 100 pixels dari tengah frame
        int sum = 0;
        final centerX = image.width ~/ 2;
        final centerY = image.height ~/ 2;
        final sampleSize = 10;
        
        for (int dy = -sampleSize; dy <= sampleSize; dy++) {
          for (int dx = -sampleSize; dx <= sampleSize; dx++) {
            final x = (centerX + dx).clamp(0, image.width - 1);
            final y = (centerY + dy).clamp(0, image.height - 1);
            final index = y * image.width + x;
            
            if (index < yPlane.length) {
              sum += yPlane[index];
            }
          }
        }
        
        // Normalize to 0-1
        final sampleCount = (sampleSize * 2 + 1) * (sampleSize * 2 + 1);
        currentBrightness = sum / (sampleCount * 255);
        
        // Categorize lighting
        if (currentBrightness < 0.2) {
          lightingCondition = 'Too Dark';
        } else if (currentBrightness < 0.4) {
          lightingCondition = 'Dim';
        } else if (currentBrightness < 0.7) {
          lightingCondition = 'Good';
        } else if (currentBrightness < 0.85) {
          lightingCondition = 'Bright';
        } else {
          lightingCondition = 'Too Bright';
        }
        
        debugPrint(' Brightness: ${(currentBrightness * 100).toStringAsFixed(1)}% - $lightingCondition');
      }
      
    } catch (e) {
      debugPrint(' Lighting analysis failed: $e');
    }
  }
  
  // ─── GET RECOMMENDED SETTINGS ───────────────────────────
  Map<String, dynamic> getRecommendedSettings() {
    int frameSkip = 2; // Default
    ResolutionPreset resolution = ResolutionPreset.medium;
    
    if (isLowEndDevice) {
      frameSkip = 3;
      resolution = ResolutionPreset.low;
    } else if (avgFPS < 15) {
      frameSkip = 3;
    } else if (avgFPS > 25) {
      frameSkip = 1;
      resolution = ResolutionPreset.high;
    }
    
    return {
      'frameSkip': frameSkip,
      'resolution': resolution,
      'needsBetterLighting': currentBrightness < 0.3 || currentBrightness > 0.85,
    };
  }
  
  // ─── GENERATE DIAGNOSTIC REPORT ────────────────────────
  String generateReport() {
    final sb = StringBuffer();
    sb.writeln('═══════════════════════════════════');
    sb.writeln('DEVICE DIAGNOSTICS REPORT');
    sb.writeln('═══════════════════════════════════');
    sb.writeln('Device: $deviceModel');
    sb.writeln('OS: $osVersion');
    sb.writeln('Performance: ${isLowEndDevice ? "Low-End" : "High-End"}');
    sb.writeln('───────────────────────────────────');
    sb.writeln('Lighting: $lightingCondition');
    sb.writeln('Brightness: ${(currentBrightness * 100).toStringAsFixed(1)}%');
    sb.writeln('───────────────────────────────────');
    
    if (frameProcessingTimes.isNotEmpty) {
      final avg = frameProcessingTimes.reduce((a, b) => a + b) / 
                  frameProcessingTimes.length;
      final max = frameProcessingTimes.reduce((a, b) => a > b ? a : b);
      final min = frameProcessingTimes.reduce((a, b) => a < b ? a : b);
      
      sb.writeln('Avg Processing: ${avg.toStringAsFixed(1)}ms');
      sb.writeln('Min/Max: $min / $max ms');
      sb.writeln('Avg FPS: ${avgFPS.toStringAsFixed(1)}');
    }
    
    sb.writeln('═══════════════════════════════════');
    
    return sb.toString();
  }
}