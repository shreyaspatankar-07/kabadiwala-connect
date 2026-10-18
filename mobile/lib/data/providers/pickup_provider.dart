import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/audio/audio_service.dart';
import '../../core/auth/session_service.dart';
import '../../core/config/app_config.dart';
import '../models/pickup_request_model.dart';
import '../../main.dart';

class PickupDispatchState {
  final List<PickupRequestDto> nearbyPickups;
  final PickupRequestDto? activePickup;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> dismissedPickupIds;

  const PickupDispatchState({
    this.nearbyPickups = const [],
    this.activePickup,
    this.isLoading = false,
    this.errorMessage,
    this.dismissedPickupIds = const {},
  });

  PickupDispatchState copyWith({
    List<PickupRequestDto>? nearbyPickups,
    PickupRequestDto? activePickup,
    bool? isLoading,
    String? errorMessage,
    Set<String>? dismissedPickupIds,
  }) {
    return PickupDispatchState(
      nearbyPickups: nearbyPickups ?? this.nearbyPickups,
      activePickup: activePickup ?? this.activePickup,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dismissedPickupIds: dismissedPickupIds ?? this.dismissedPickupIds,
    );
  }
}

class PickupDispatchNotifier extends StateNotifier<PickupDispatchState> {
  final http.Client _client;
  final AudioFeedbackService _audioService;

  static List<String> get _urlsToTry => AppConfig.candidateUrls;

  PickupDispatchNotifier({
    http.Client? client,
    AudioFeedbackService? audioService,
  })  : _client = client ?? http.Client(),
        _audioService = audioService ?? AudioFeedbackService(),
        super(const PickupDispatchState());

  /// Polls or fetches nearby requests using PostGIS ST_DWithin backend endpoint
  Future<List<PickupRequestDto>> fetchNearbyPickups({
    required double lat,
    required double lng,
    double radiusMeters = 2500.0,
    bool playAudioAlert = true,
  }) async {
    state = state.copyWith(isLoading: true);

    for (final base in _urlsToTry) {
      try {
        final uri = Uri.parse('$base/pickup/nearby').replace(queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radius_meters': radiusMeters.toString(),
        });

        final response = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final items = data
              .map((json) => PickupRequestDto.fromJson(json as Map<String, dynamic>))
              .where((p) => !state.dismissedPickupIds.contains(p.id))
              .toList();

          // Play vernacular voice alert if new pickup is discovered
          if (items.isNotEmpty && playAudioAlert) {
            final first = items.first;
            final distStr = (first.estimatedDistanceKm ?? 1.5).toStringAsFixed(1);
            final catsStr = first.categories.join(', ');
            final prompt = 'नवीन पिकअप उपलब्ध — $distStr किमी दूर, $catsStr';
            await _audioService.speak(prompt);
          }

          state = state.copyWith(nearbyPickups: items, isLoading: false);
          return items;
        }
      } catch (e) {
        // Try next fallback URL
        debugPrint('[PickupDispatch] Nearby poll failed on $base: $e');
      }
    }

    state = state.copyWith(isLoading: false);
    return state.nearbyPickups;
  }

  /// Collector accepts a pickup request
  Future<bool> acceptPickup(PickupRequestDto pickup) async {
    state = state.copyWith(isLoading: true);

    for (final base in _urlsToTry) {
      try {
        final uri = Uri.parse('$base/pickup/${pickup.id}/accept');
        final response = await _client.post(uri).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final updated = PickupRequestDto.fromJson(jsonDecode(response.body));
          final remaining = state.nearbyPickups.where((p) => p.id != pickup.id).toList();

          state = state.copyWith(
            activePickup: updated,
            nearbyPickups: remaining,
            isLoading: false,
          );

          await _audioService.speak('पिकअप स्वीकारले आहे. नॅव्हिगेशन सुरू करा.');
          return true;
        }
      } catch (e) {
        debugPrint('[PickupDispatch] Accept failed on $base: $e');
      }
    }

    // Local optimistic acceptance if offline
    final collectorId = await SessionService.getCollectorId() ?? await SessionService.getOrCreateCollectorId();
    final optimistic = PickupRequestDto(
      id: pickup.id,
      publicCode: pickup.publicCode,
      status: 'ACCEPTED',
      categories: pickup.categories,
      photoUrls: pickup.photoUrls,
      addressText: pickup.addressText,
      latitude: pickup.latitude,
      longitude: pickup.longitude,
      estimatedDistanceKm: pickup.estimatedDistanceKm,
      assignedCollectorId: collectorId,
      createdAt: pickup.createdAt,
    );

    final remaining = state.nearbyPickups.where((p) => p.id != pickup.id).toList();
    state = state.copyWith(
      activePickup: optimistic,
      nearbyPickups: remaining,
      isLoading: false,
    );
    await _audioService.speak('पिकअप स्वीकारले आहे.');
    return true;
  }

  /// Mark arrived at destination
  Future<bool> markArrived(String pickupId) async {
    for (final base in _urlsToTry) {
      try {
        final uri = Uri.parse('$base/pickup/$pickupId/arrived');
        final response = await _client.post(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          debugPrint('[PickupDispatch] Marked arrived for $pickupId');
          break;
        }
      } catch (_) {}
    }

    if (state.activePickup != null && state.activePickup!.id == pickupId) {
      state = state.copyWith(
        activePickup: PickupRequestDto(
          id: state.activePickup!.id,
          publicCode: state.activePickup!.publicCode,
          status: 'ARRIVED',
          categories: state.activePickup!.categories,
          photoUrls: state.activePickup!.photoUrls,
          addressText: state.activePickup!.addressText,
          latitude: state.activePickup!.latitude,
          longitude: state.activePickup!.longitude,
          estimatedDistanceKm: state.activePickup!.estimatedDistanceKm,
          assignedCollectorId: state.activePickup!.assignedCollectorId,
          createdAt: state.activePickup!.createdAt,
        ),
      );
    }
    await _audioService.speak('तुम्ही पोहोचला आहात. वजन व माल तपासा.');
    return true;
  }

  /// Complete pickup after offline lot creation
  Future<bool> completePickup(String pickupId, {String? lotId}) async {
    for (final base in _urlsToTry) {
      try {
        final uri = Uri.parse('$base/pickup/$pickupId/complete');
        final response = await _client
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'lot_id': lotId}),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          break;
        }
      } catch (_) {}
    }

    state = state.copyWith(activePickup: null);
    await _audioService.speak('पिकअप यशस्वीरित्या पूर्ण झाले.');
    return true;
  }

  /// Dismisses alert locally so it won't ring repeatedly
  void dismissAlert(String pickupId) {
    final dismissed = {...state.dismissedPickupIds, pickupId};
    final remaining = state.nearbyPickups.where((p) => p.id != pickupId).toList();
    state = state.copyWith(
      nearbyPickups: remaining,
      dismissedPickupIds: dismissed,
    );
  }
}

final pickupDispatchProvider =
    StateNotifierProvider<PickupDispatchNotifier, PickupDispatchState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return PickupDispatchNotifier(audioService: audioService);
});
