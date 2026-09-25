import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'audio_map.dart';

/// AudioFeedbackService plays spoken prompts and feedback for low-literacy users.
/// Designed for offline operation with asset playback and verbal audio prompts.
class AudioFeedbackService {
  AudioFeedbackService({
    AudioPlayer? player,
    bool? enableAudio,
  })  : _enableAudio = enableAudio ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
        _player = player;

  AudioPlayer? _player;
  final bool _enableAudio;
  String _currentLocale = 'mr'; // Marathi by default per AGENTS.md
  bool _isPlaying = false;
  String? _lastSpokenText;

  bool get isPlaying => _isPlaying;
  String get currentLocale => _currentLocale;
  String? get lastSpokenText => _lastSpokenText;

  AudioPlayer get _getOrCreatePlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  void setLocale(String locale) {
    if (['mr', 'hi', 'en'].contains(locale)) {
      _currentLocale = locale;
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
        final player = _getOrCreatePlayer;
        await player.stop();
        await player.play(AssetSource(audioPath));
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
  }

  /// Read aloud a custom vernacular text
  Future<void> speakCustomText(String text) async {
    _lastSpokenText = text;
    debugPrint('[AudioFeedbackService] [$_currentLocale] Speaking: $text');
  }

  /// Stop current audio
  Future<void> stop() async {
    try {
      if (_enableAudio && _player != null) {
        await _player!.stop();
      }
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    _player?.dispose();
  }
}
