import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight native navigation intent service.
/// Launches native Google Maps / turn-by-turn navigation externally,
/// saving device memory and battery by avoiding heavy embedded vector maps in Flutter.
class NavigationService {
  const NavigationService();

  /// Launches native turn-by-turn navigation to target coordinates.
  Future<bool> launchTurnByTurnNavigation({
    required double latitude,
    required double longitude,
  }) async {
    // 1. Android turn-by-turn intent
    final navUri = Uri.parse('google.navigation:q=$latitude,$longitude');
    try {
      if (await canLaunchUrl(navUri)) {
        return await launchUrl(navUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[NavigationService] google.navigation intent failed: $e');
    }

    // 2. Generic geo intent fallback
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[NavigationService] geo: URI fallback failed: $e');
    }

    // 3. Web URL fallback
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
