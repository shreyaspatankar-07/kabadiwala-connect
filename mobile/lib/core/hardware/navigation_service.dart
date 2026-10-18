import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight native navigation intent service.
/// Launches native Google Maps / turn-by-turn navigation externally,
/// saving device memory and battery by avoiding heavy embedded vector maps in Flutter.
///
/// Returns `false` immediately when the device is offline so callers can show a
/// graceful localized SnackBar instead of letting the OS throw a hard network error.
class NavigationService {
  NavigationService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Returns true if the device currently has any network access.
  Future<bool> _isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // checkConnectivity() returns a List<ConnectivityResult> in newer versions
      if (results is List) {
        return (results as List).any(
          (r) => r != ConnectivityResult.none,
        );
      }
      return results != ConnectivityResult.none;
    } catch (_) {
      // If the plugin itself fails, assume online to avoid blocking collectors.
      return true;
    }
  }

  /// Launches native turn-by-turn navigation to [latitude] / [longitude].
  ///
  /// Returns `false` when offline — the caller should show a localized
  /// warning SnackBar:
  /// ```dart
  /// final ok = await NavigationService().launchTurnByTurnNavigation(...);
  /// if (!ok && mounted) {
  ///   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  ///     content: Text(locale == 'mr'
  ///         ? 'थेट नेव्हिगेशनसाठी इंटरनेट आवश्यक आहे.'
  ///         : 'Turn-by-turn navigation needs an internet connection.'),
  ///   ));
  /// }
  /// ```
  Future<bool> launchTurnByTurnNavigation({
    required double latitude,
    required double longitude,
  }) async {
    // Guard: do not attempt any URL launch when device is offline.
    if (!await _isOnline()) {
      debugPrint('[NavigationService] Device is offline — skipping map launch.');
      return false;
    }

    // 1. Android turn-by-turn intent (Google Maps or any navigation app)
    final navUri = Uri.parse('google.navigation:q=$latitude,$longitude');
    try {
      if (await canLaunchUrl(navUri)) {
        return await launchUrl(navUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[NavigationService] google.navigation intent failed: $e');
    }

    // 2. Generic geo: URI fallback
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[NavigationService] geo: URI fallback failed: $e');
    }

    // 3. HTTPS web fallback (browser-based)
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[NavigationService] web maps fallback failed: $e');
      return false;
    }
  }
}
