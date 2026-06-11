import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Singleton TTS service for real-time voice feedback during workouts.
/// Uses a queue to avoid overlapping speech in rapid rep scenarios.
class TtsService {
  TtsService._internal();
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _enabled = true;

  // Queue-based speech — prevent overlapping feedback
  final Queue<String> _speechQueue = Queue<String>();
  String? _lastSpoken;
  DateTime _lastSpokenTime = DateTime.now();

  // Debounce — don't repeat same feedback within this window
  static const Duration _debounceDuration = Duration(seconds: 2);

  // Volume/rate settings for gym environment
  double _speechRate = 0.45; // 0.0 – 1.0
  double _volume = 1.0;
  double _pitch = 1.05;

  /// Initialize TTS engine. Call once at app start or first workout page.
  Future<void> init() async {
    if (_isInitialized) return;

    // Set language — Indonesian preferred, fallback to English
    final langs = await _tts.getLanguages;
    if (langs.contains('id-ID')) {
      await _tts.setLanguage('id-ID');
    } else if (langs.contains('id')) {
      await _tts.setLanguage('id');
    } else {
      await _tts.setLanguage('en-US');
    }

    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    // Don't queue at the TTS level — we manage our own queue
    await _tts.awaitSpeakCompletion(false);

    // Listen for completion to process queue
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _processQueue();
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      debugPrint('[TTS] Error: $msg');
      _isSpeaking = false;
      _processQueue();
    });

    _isInitialized = true;
    debugPrint('[TTS] Initialized');
  }

  /// Enable or disable voice feedback
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      stop();
      _speechQueue.clear();
    }
  }

  bool get isEnabled => _enabled;

  /// Adjust speech rate (0.0 = slowest, 1.0 = fastest)
  Future<void> setRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    if (_isInitialized) await _tts.setSpeechRate(_speechRate);
  }

  /// Adjust pitch
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    if (_isInitialized) await _tts.setPitch(_pitch);
  }

  /// Speak text with debounce — won't repeat the same phrase within [debounceDuration].
  /// If [force] is true, bypasses debounce (for important events like rep counts).
  void speak(String text, {bool force = false}) {
    if (!_enabled || text.isEmpty) return;

    // Debounce: skip if same text was spoken recently
    if (!force && _lastSpoken == text) {
      final elapsed = DateTime.now().difference(_lastSpokenTime);
      if (elapsed < _debounceDuration) return;
    }

    _speechQueue.add(text);
    if (!_isSpeaking) _processQueue();
  }

  /// Speak immediately, clearing the queue (for urgent feedback like corrections).
  void speakUrgent(String text) {
    if (!_enabled || text.isEmpty) return;
    _speechQueue.clear();
    _tts.stop();
    _isSpeaking = false;
    _lastSpoken = text;
    _lastSpokenTime = DateTime.now();
    _tts.speak(text);
    _isSpeaking = true;
  }

  /// Speak rep count milestone
  void speakRepCount(int current, int target) {
    final remaining = target - current;
    if (remaining <= 0) {
      speak('Target tercapai! Bagus!', force: true);
    } else if (remaining <= 3) {
      speak('$remaining reps lagi!', force: true);
    } else if (remaining % 5 == 0 && remaining > 0) {
      speak('$remaining reps lagi, semangat!', force: true);
    }
  }

  /// Speak stage transition
  void speakStage(String stage) {
    switch (stage) {
      case 'down':
        speak('Turun...');
        break;
      case 'up':
        speak('Naik, bagus!');
        break;
    }
  }

  /// Speak form correction
  void speakCorrection(String feedback, {bool isGood = false}) {
    if (isGood) {
      speak(feedback);
    } else {
      speakUrgent(feedback);
    }
  }

  /// Speak rest timer countdown (last 3 seconds)
  void speakRestCountdown(int secondsLeft) {
    if (secondsLeft >= 1 && secondsLeft <= 3) {
      speak('$secondsLeft', force: true);
    } else if (secondsLeft == 0) {
      speak('Mulai set berikutnya!', force: true);
    }
  }

  /// Announce exercise start
  void speakExerciseStart(String exerciseName) {
    speak('Latihan selanjutnya: $exerciseName. Siap? Mulai!', force: true);
  }

  /// Announce set completion
  void speakSetComplete(int setNumber, int totalSets) {
    if (setNumber >= totalSets) {
      speak('Semua set selesai! Kerja bagus!', force: true);
    } else {
      speak('Set $setNumber selesai. Istirahat sebentar.', force: true);
    }
  }

  /// Announce workout completion
  void speakWorkoutComplete() {
    speak('Selamat! Workout hari ini sudah selesai. Mantap!', force: true);
  }

  /// Process the speech queue
  void _processQueue() {
    if (_isSpeaking || _speechQueue.isEmpty) return;

    final text = _speechQueue.removeFirst();
    _lastSpoken = text;
    _lastSpokenTime = DateTime.now();
    _isSpeaking = true;
    _tts.speak(text);
  }

  /// Stop all speech and clear queue
  Future<void> stop() async {
    _speechQueue.clear();
    _isSpeaking = false;
    if (_isInitialized) await _tts.stop();
  }

  /// Dispose TTS engine
  Future<void> dispose() async {
    _speechQueue.clear();
    _isSpeaking = false;
    if (_isInitialized) {
      await _tts.stop();
    }
    _isInitialized = false;
  }
}
