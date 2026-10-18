/// Centralized Application Configuration.
///
/// Injects compile-time environment variables passed via `--dart-define`.
/// Example for production:
/// `flutter build apk --dart-define=API_BASE_URL=https://api.kabadiwalaconnect.org/api/v1`
class AppConfig {
  AppConfig._();

  /// Primary API Base URL injected at compile time
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Returns true if targeting a live HTTPS production endpoint
  static bool get isProduction => apiBaseUrl.startsWith('https://');

  /// Candidate URLs to probe in development/emulator mode.
  /// In production, only the injected `apiBaseUrl` is queried to prevent network leakage.
  static List<String> get candidateUrls {
    if (isProduction) {
      return [apiBaseUrl];
    }
    return [
      apiBaseUrl,
      'http://10.0.2.2:8000/api/v1',
      'http://localhost:8000/api/v1',
      'http://127.0.0.1:8000/api/v1',
    ];
  }
}
