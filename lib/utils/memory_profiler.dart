import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

class MemoryProfiler {
  static MemoryProfiler? _instance;
  
  MemoryProfiler._();
  
  factory MemoryProfiler() {
    _instance ??= MemoryProfiler._();
    return _instance!;
  }
  
  vm.VmService? _vmService;
  Timer? _pollingTimer;
  
  final List<MemorySnapshot> _snapshots = [];
  int _currentMemoryMB = 0;
  int _peakMemoryMB = 0;
  
  bool get isActive => _pollingTimer?.isActive ?? false;
  
  // ─── START PROFILING ───────────────────────────────────────
  Future<void> start({Duration interval = const Duration(seconds: 2)}) async {
    if (!kDebugMode) {
      debugPrint(' Memory profiling only works in debug mode');
      return;
    }
    
    try {
      final serverUri = await developer.Service.getInfo()
          .then((info) => info.serverUri);
      
      if (serverUri == null) {
        debugPrint(' VM Service not available');
        return;
      }
      
      _vmService = await vmServiceConnectUri(
        'ws://${serverUri.authority}${serverUri.path}ws',
      );
      
      debugPrint(' Memory profiler started');
      
      // Poll memory usage
      _pollingTimer = Timer.periodic(interval, (_) => _captureSnapshot());
      
    } catch (e) {
      debugPrint(' Failed to start memory profiler: $e');
    }
  }
  
  // ─── CAPTURE MEMORY SNAPSHOT ───────────────────────────────
  Future<void> _captureSnapshot() async {
    if (_vmService == null) return;
    
    try {
      final vm = await _vmService!.getVM();
      if (vm.isolates == null || vm.isolates!.isEmpty) return;
      
      final isolateRef = vm.isolates!.first;
      final memoryUsage = await _vmService!.getMemoryUsage(isolateRef.id!);
      
      final heapUsageMB = (memoryUsage.heapUsage ?? 0) ~/ (1024 * 1024);
      final externalUsageMB = (memoryUsage.externalUsage ?? 0) ~/ (1024 * 1024);
      final totalMB = heapUsageMB + externalUsageMB;
      
      _currentMemoryMB = totalMB;
      
      if (totalMB > _peakMemoryMB) {
        _peakMemoryMB = totalMB;
      }
      
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        heapMB: heapUsageMB,
        externalMB: externalUsageMB,
        totalMB: totalMB,
      );
      
      _snapshots.add(snapshot);
      
      // Keep last 100 snapshots only
      if (_snapshots.length > 100) {
        _snapshots.removeAt(0);
      }
      
      debugPrint(' Memory: ${totalMB}MB (Heap: ${heapUsageMB}MB, External: ${externalUsageMB}MB)');
      
      // Warning jika memory usage tinggi
      if (totalMB > 200) {
        debugPrint(' High memory usage detected: ${totalMB}MB');
      }
      
    } catch (e) {
      debugPrint(' Failed to capture memory snapshot: $e');
    }
  }
  
  // ─── FORCE GARBAGE COLLECTION ──────────────────────────────
  Future<void> forceGC() async {
    if (_vmService == null) return;
    
    try {
      final vm = await _vmService!.getVM();
      if (vm.isolates == null || vm.isolates!.isEmpty) return;
      
      final isolateRef = vm.isolates!.first;
      await _vmService!.callServiceExtension(
        'ext.flutter.gcCollect',
        isolateId: isolateRef.id,
      );
      
      debugPrint(' Garbage collection triggered');
      
      // Capture snapshot after GC
      await Future.delayed(const Duration(milliseconds: 500));
      await _captureSnapshot();
      
    } catch (e) {
      debugPrint(' Failed to force GC: $e');
    }
  }
  
  // ─── GENERATE REPORT ───────────────────────────────────────
  String generateReport() {
    if (_snapshots.isEmpty) {
      return 'No memory data collected';
    }
    
    final avgMemory = _snapshots
        .map((s) => s.totalMB)
        .reduce((a, b) => a + b) / _snapshots.length;
    
    final sb = StringBuffer();
    sb.writeln('═══════════════════════════════════');
    sb.writeln('MEMORY PROFILING REPORT');
    sb.writeln('═══════════════════════════════════');
    sb.writeln('Current: ${_currentMemoryMB}MB');
    sb.writeln('Peak: ${_peakMemoryMB}MB');
    sb.writeln('Average: ${avgMemory.toStringAsFixed(1)}MB');
    sb.writeln('Snapshots: ${_snapshots.length}');
    sb.writeln('───────────────────────────────────');
    
    // Last 5 snapshots
    sb.writeln('Recent snapshots:');
    final recent = _snapshots.length > 5
        ? _snapshots.sublist(_snapshots.length - 5)
        : _snapshots;
    
    for (final snapshot in recent) {
      final time = snapshot.timestamp.toString().substring(11, 19);
      sb.writeln('  $time: ${snapshot.totalMB}MB');
    }
    
    sb.writeln('═══════════════════════════════════');
    
    return sb.toString();
  }
  
  // ─── STOP PROFILING ────────────────────────────────────────
  Future<void> stop() async {
    _pollingTimer?.cancel();
    _vmService?.dispose();
    
    debugPrint(' Memory profiler stopped');
    debugPrint(generateReport());
  }
  
  // ─── RESET ─────────────────────────────────────────────────
  void reset() {
    _snapshots.clear();
    _currentMemoryMB = 0;
    _peakMemoryMB = 0;
    debugPrint(' Memory profiler reset');
  }
}

class MemorySnapshot {
  final DateTime timestamp;
  final int heapMB;
  final int externalMB;
  final int totalMB;
  
  MemorySnapshot({
    required this.timestamp,
    required this.heapMB,
    required this.externalMB,
    required this.totalMB,
  });
}