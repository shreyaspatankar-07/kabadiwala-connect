import 'package:flutter/services.dart';

/// HapticService provides tactile confirmation for low-literacy users
/// on key presses, selections, and error alerts.
class HapticService {
  HapticService._();

  /// Standard tap / keypad press
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Primary action / confirm button
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Big action / success event
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Error / warning feedback
  static Future<void> errorAlert() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Selection change / toggle
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
