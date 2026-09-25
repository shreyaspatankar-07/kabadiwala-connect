import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class CollectorLocation {
  const CollectorLocation({
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.isFallback,
    this.source = 'gps', // gps | last_known | manual
  });

  final String district;
  final double latitude;
  final double longitude;
  final bool isFallback;
  final String source;
}

/// LocationService handles automatic GPS acquisition with graceful offline
/// fallback to last-known position and manual district override.
class LocationService {
  LocationService({bool? enableGps})
      : _enableGps = enableGps ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final bool _enableGps;

  static const Map<String, ({double lat, double lng})> districtCoordinates = {
    'Palghar': (lat: 19.6967, lng: 72.7699),
    'Thane': (lat: 19.2183, lng: 72.9781),
    'Mumbai': (lat: 19.0760, lng: 72.8777),
    'Pune': (lat: 18.5204, lng: 73.8567),
    'Nashik': (lat: 19.9975, lng: 73.7898),
    'Nagpur': (lat: 21.1458, lng: 79.0882),
  };

  /// Acquire GPS position with fast timeout and multi-level fallback
  Future<CollectorLocation> getCurrentOrFallbackLocation({
    String defaultDistrict = 'Palghar',
  }) async {
    if (!_enableGps) {
      return _fallbackToDistrict(defaultDistrict);
    }

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await _fallbackToLastKnownOrDistrict(defaultDistrict);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return await _fallbackToLastKnownOrDistrict(defaultDistrict);
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );

      final district = _matchClosestDistrict(position.latitude, position.longitude);

      return CollectorLocation(
        district: district,
        latitude: position.latitude,
        longitude: position.longitude,
        isFallback: false,
        source: 'gps',
      );
    } catch (e) {
      debugPrint('[LocationService] GPS failed, using offline fallback: $e');
      return _fallbackToLastKnownOrDistrict(defaultDistrict);
    }
  }

  Future<CollectorLocation> _fallbackToLastKnownOrDistrict(String defaultDistrict) async {
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final district = _matchClosestDistrict(lastKnown.latitude, lastKnown.longitude);
        return CollectorLocation(
          district: district,
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          isFallback: true,
          source: 'last_known',
        );
      }
    } catch (_) {}

    return _fallbackToDistrict(defaultDistrict);
  }

  CollectorLocation _fallbackToDistrict(String defaultDistrict) {
    final coords = districtCoordinates[defaultDistrict] ?? districtCoordinates['Palghar']!;
    return CollectorLocation(
      district: defaultDistrict,
      latitude: coords.lat,
      longitude: coords.lng,
      isFallback: true,
      source: 'manual',
    );
  }

  CollectorLocation selectManualDistrict(String district) {
    final coords = districtCoordinates[district] ?? districtCoordinates['Palghar']!;
    return CollectorLocation(
      district: district,
      latitude: coords.lat,
      longitude: coords.lng,
      isFallback: false,
      source: 'manual',
    );
  }

  String _matchClosestDistrict(double lat, double lng) {
    String closest = 'Palghar';
    double minDistance = double.infinity;

    for (final entry in districtCoordinates.entries) {
      final dLat = entry.value.lat - lat;
      final dLng = entry.value.lng - lng;
      final distSq = (dLat * dLat) + (dLng * dLng);
      if (distSq < minDistance) {
        minDistance = distSq;
        closest = entry.key;
      }
    }
    return closest;
  }
}
