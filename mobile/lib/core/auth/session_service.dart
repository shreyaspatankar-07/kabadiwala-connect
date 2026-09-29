import 'package:shared_preferences/shared_preferences.dart';

/// SessionService manages the fast cold-start session state in SharedPreferences
/// paired with the SQLite Drift database for heavy relational records.
class SessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCollectorId = 'collector_id';
  static const String _keyPinHash = 'collector_pin_hash';
  static const String _keyLocale = 'preferred_locale';

  /// Save login session upon completing PIN setup
  static Future<void> saveSession({
    required String collectorId,
    required String pinHash,
    String locale = 'mr',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCollectorId, collectorId);
    await prefs.setString(_keyPinHash, pinHash);
    await prefs.setString(_keyLocale, locale);
  }

  /// Check if the collector has an active session on device cold start
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get current cached collector ID
  static Future<String?> getCollectorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCollectorId);
  }

  /// Get preferred locale from session cache
  static Future<String?> getPreferredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocale);
  }

  /// Verify entered PIN against cached PIN hash
  static Future<bool> verifyPin(String enteredHash) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_keyPinHash);
    return savedHash != null && savedHash == enteredHash;
  }

  /// Clear session on complete data purge
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyCollectorId);
    await prefs.remove(_keyPinHash);
    await prefs.remove(_keyLocale);
  }
}
