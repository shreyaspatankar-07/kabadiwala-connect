import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Production OTP Service.
///
/// Delegates phone OTP send/verify to the live FastAPI backend at
/// [AppConfig.apiBaseUrl]/auth/send-otp and /auth/verify-otp.
/// The backend calls Twilio (configured via TWILIO_* Render env vars).
///
/// Usage:
/// ```dart
/// final otp = const OtpService();
/// await otp.sendOtp('+919876543210');
/// final valid = await otp.verifyOtp('+919876543210', '123456');
/// ```
class OtpService {
  OtpService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  /// Requests an OTP be sent to [phoneE164] (e.g. "+919876543210").
  ///
  /// Throws [OtpServiceException] on network failure or non-2xx response.
  Future<void> sendOtp(String phoneE164) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/send-otp');
    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: '{"phone":"$phoneE164"}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OtpServiceException(
          'OTP send failed: HTTP ${response.statusCode} — ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[OtpService] sendOtp error: $e');
      if (e is OtpServiceException) rethrow;
      throw OtpServiceException('Network error sending OTP: $e');
    }
  }

  /// Verifies [otp] for [phoneE164].
  ///
  /// Returns `true` if valid, `false` if the code is wrong.
  /// Throws [OtpServiceException] on network failure.
  Future<bool> verifyOtp(String phoneE164, String otp) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/verify-otp');
    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: '{"phone":"$phoneE164","otp":"$otp"}',
      );
      if (response.statusCode == 200) return true;
      if (response.statusCode == 401 || response.statusCode == 422) return false;
      throw OtpServiceException(
        'OTP verify failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[OtpService] verifyOtp error: $e');
      if (e is OtpServiceException) rethrow;
      throw OtpServiceException('Network error verifying OTP: $e');
    }
  }
}

/// Thrown when the OTP service encounters an unrecoverable error.
class OtpServiceException implements Exception {
  const OtpServiceException(this.message);
  final String message;
  @override
  String toString() => 'OtpServiceException: $message';
}

// End of otp_service.dart
