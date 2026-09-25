import 'package:flutter/services.dart';

/// HapticService provides tactile confirmation for low-literacy users
/// on key presses, selections, and error alerts.
class HapticService {
  HapticService._();

  /// Flag to enable/disable haptics (useful for unit/widget tests and low-end devices)
  static bool enableHaptics = true;

  /// Standard tap / keypad press
  static Future<void> lightImpact() async {
    if (!enableHaptics) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Primary action / confirm button
  static Future<void> mediumImpact() async {
    if (!enableHaptics) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Big action / success event
  static Future<void> heavyImpact() async {
    if (!enableHaptics) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Error / warning feedback
  static Future<void> errorAlert() async {
    if (!enableHaptics) return;
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Selection change / toggle
  static Future<void> selectionClick() async {
    if (!enableHaptics) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
