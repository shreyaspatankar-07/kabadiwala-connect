import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'audio_map.dart';

/// AudioFeedbackService plays spoken prompts and feedback for low-literacy users.
/// Designed for offline operation with asset playback and live TTS fallback.
class AudioFeedbackService {
  static final AudioFeedbackService _defaultInstance = AudioFeedbackService._internal();

  factory AudioFeedbackService({AudioPlayer? player, FlutterTts? tts, bool? enableAudio}) {
    if (player != null || tts != null || enableAudio != null) {
      return AudioFeedbackService._internal(player: player, tts: tts, enableAudio: enableAudio);
    }
    return _defaultInstance;
  }

  static bool _defaultEnableAudio() {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    } catch (_) {}
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  AudioFeedbackService._internal({
    AudioPlayer? player,
    FlutterTts? tts,
    bool? enableAudio,
  })  : _enableAudio = enableAudio ?? _defaultEnableAudio(),
        _player = player,
        _tts = tts;

  AudioFeedbackService.custom({
    AudioPlayer? player,
    FlutterTts? tts,
    bool? enableAudio,
  })  : _enableAudio = enableAudio ?? _defaultEnableAudio(),
        _player = player,
        _tts = tts;

  AudioPlayer? _player;
  FlutterTts? _tts;
  final bool _enableAudio;
  String _currentLocale = 'mr'; // Marathi by default per AGENTS.md
  bool _isPlaying = false;
  String? _lastSpokenText;
  bool _isTtsInitialized = false;

  bool get isPlaying => _isPlaying;
  String get currentLocale => _currentLocale;
  String? get lastSpokenText => _lastSpokenText;

  AudioPlayer get _getOrCreatePlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  FlutterTts get _getOrCreateTts {
    _tts ??= FlutterTts();
    return _tts!;
  }

  Future<void> _initTts(String locale) async {
    if (!_enableAudio) return;
    try {
      final tts = _getOrCreateTts;
      final ttsLang = locale == 'hi' ? 'hi-IN' : (locale == 'en' ? 'en-IN' : 'mr-IN');
      await tts.setLanguage(ttsLang);
      await tts.setSpeechRate(0.45); // Slower for low-literacy users
      await tts.setPitch(1.0);
      _isTtsInitialized = true;
    } catch (e) {
      debugPrint('[AudioFeedbackService] TTS init note: $e');
    }
  }

  void setLocale(String locale) {
    if (['mr', 'hi', 'en'].contains(locale)) {
      _currentLocale = locale;
      _isTtsInitialized = false;
    }
  }

  /// Speak text via live Android TTS fallback engine
  Future<void> _speakViaTts(String text, String locale) async {
    if (!_enableAudio) return;
    try {
      if (!_isTtsInitialized) {
        await _initTts(locale);
      }
      final tts = _getOrCreateTts;
      final ttsLang = locale == 'hi' ? 'hi-IN' : (locale == 'en' ? 'en-IN' : 'mr-IN');
      await tts.setLanguage(ttsLang);
      await tts.speak(text);
    } catch (e) {
      debugPrint('[AudioFeedbackService] TTS speech fallback: $e');
    }
  }

  /// Read aloud a prompt based on its string key
  Future<void> speakPrompt(String stringId, {String? localeOverride}) async {
    final locale = localeOverride ?? _currentLocale;
    final spokenText = AudioMap.getSpokenText(stringId, locale);
    _lastSpokenText = spokenText;
    final audioPath = AudioMap.getAudioPath(stringId, locale);

    try {
      _isPlaying = true;
      if (_enableAudio) {
        try {
          final player = _getOrCreatePlayer;
          await player.stop();
          await player.play(AssetSource(audioPath));
        } catch (_) {
          // Recorded clip missing -> Live Android TTS fallback
          await _speakViaTts(spokenText, locale);
        }
      } else {
        // Safe logging in test and non-Android environments
        debugPrint('[AudioFeedbackService] [$locale] Playing: $spokenText');
      }
    } catch (e) {
      debugPrint('[AudioFeedbackService] Audio playback fallback: $e');
    } finally {
      _isPlaying = false;
    }
  }

  /// Read aloud a dynamic calculated rupee price estimate
  Future<void> speakEstimate(int amount, {String? localeOverride}) async {
    final locale = localeOverride ?? _currentLocale;
    final text = AudioMap.getEstimateSpokenText(amount, locale);
    _lastSpokenText = text;
    debugPrint('[AudioFeedbackService] [$locale] Spoken Estimate: $text');
    await _speakViaTts(text, locale);
  }

  /// Read aloud price board item details (category, price per kg, trend direction)
  Future<void> speakPriceDetail({
    required String category,
    required int pricePerKg,
    required String trendDirection,
    String? localeOverride,
  }) async {
    final locale = localeOverride ?? _currentLocale;
    final text = AudioMap.getPriceDetailSpokenText(
      category: category,
      pricePerKg: pricePerKg,
      trend: trendDirection,
      locale: locale,
    );
    _lastSpokenText = text;
    debugPrint('[AudioFeedbackService] [$locale] Spoken Price Detail: $text');
    await _speakViaTts(text, locale);
  }

  /// Read aloud a custom vernacular text
  Future<void> speakCustomText(String text, {String? localeOverride}) async {
    final locale = localeOverride ?? _currentLocale;
    _lastSpokenText = text;
    debugPrint('[AudioFeedbackService] [$locale] Speaking: $text');
    await _speakViaTts(text, locale);
  }

  /// Alias for speakCustomText
  Future<void> speak(String text, {String? localeOverride}) =>
      speakCustomText(text, localeOverride: localeOverride);

  /// Read aloud best buyer summary (Recycler name, distance km, rate per kg)
  Future<void> speakBestBuyer({
    required String recyclerName,
    required double distanceKm,
    required double ratePerKg,
    String? localeOverride,
  }) async {
    final locale = localeOverride ?? _currentLocale;
    final text = AudioMap.getBestBuyerSpokenText(
      recyclerName: recyclerName,
      distanceKm: distanceKm,
      ratePerKg: ratePerKg,
      locale: locale,
    );
    _lastSpokenText = text;
    debugPrint('[AudioFeedbackService] [$locale] Spoken Best Buyer: $text');
    await _speakViaTts(text, locale);
  }

  /// Stop current audio
  Future<void> stop() async {
    try {
      if (_enableAudio) {
        if (_player != null) await _player!.stop();
        if (_tts != null) await _tts!.stop();
      }
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    _player?.dispose();
    _tts?.stop();
  }
}

