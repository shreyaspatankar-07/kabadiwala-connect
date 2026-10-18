import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/data/models/pickup_request_model.dart';
import 'package:kabadiwala_mobile/data/providers/pickup_provider.dart';
import 'package:kabadiwala_mobile/ui/widgets/pickup_alert_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioFeedbackService audioService;

  setUp(() {
    audioService = AudioFeedbackService(enableAudio: false);
  });

  group('Doorstep Pickup Model Tests', () {
    test('PickupRequestDto fromJson and toJson round-trip', () {
      final json = {
        'id': 'test-uuid-123',
        'public_code': 'PR-MH-2026-TEST1',
        'status': 'CREATED',
        'categories': ['CABLES', 'BATTERIES'],
        'photo_urls': ['https://example.com/cables.jpg'],
        'address_text': 'Camp Road, Amravati',
        'latitude': 20.9320,
        'longitude': 77.7523,
        'estimated_distance_km': 1.45,
        'assigned_collector_id': null,
        'created_at': DateTime(2026, 10, 13, 10, 0, 0).toIso8601String(),
      };

      final dto = PickupRequestDto.fromJson(json);
      expect(dto.id, 'test-uuid-123');
      expect(dto.publicCode, 'PR-MH-2026-TEST1');
      expect(dto.categories, contains('CABLES'));
      expect(dto.estimatedDistanceKm, 1.45);
      expect(dto.latitude, 20.9320);

      final exported = dto.toJson();
      expect(exported['public_code'], 'PR-MH-2026-TEST1');
      expect(exported['categories'], contains('BATTERIES'));
    });
  });

  group('PickupAlertDialog Widget Tests', () {
    final samplePickup = PickupRequestDto(
      id: 'pickup-001',
      publicCode: 'PR-MH-2026-AMR01',
      status: 'CREATED',
      categories: ['CABLES', 'BATTERIES'],
      photoUrls: [],
      addressText: 'Camp Road, Amravati',
      latitude: 20.9320,
      longitude: 77.7523,
      estimatedDistanceKm: 1.2,
      createdAt: DateTime.now(),
    );

    testWidgets('Renders pickup code, distance, category chips and accept/decline buttons',
        (tester) async {
      bool accepted = false;
      bool declined = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PickupAlertDialog(
              pickup: samplePickup,
              audioService: audioService,
              locale: 'mr',
              onAccept: () => accepted = true,
              onDecline: () => declined = true,
            ),
          ),
        ),
      );

      // Verify code and distance
      expect(find.text('PR-MH-2026-AMR01'), findsOneWidget);
      expect(find.text('1.2 km'), findsOneWidget);
      expect(find.text('CABLES'), findsOneWidget);
      expect(find.text('BATTERIES'), findsOneWidget);

      // Verify buttons
      expect(find.byKey(const Key('btn_accept_pickup')), findsOneWidget);
      expect(find.byKey(const Key('btn_decline_pickup')), findsOneWidget);

      // Tap Accept
      await tester.tap(find.byKey(const Key('btn_accept_pickup')));
      await tester.pump();
      expect(accepted, isTrue);

      // Tap Decline
      await tester.tap(find.byKey(const Key('btn_decline_pickup')));
      await tester.pump();
      expect(declined, isTrue);
    });

    testWidgets('Accepted pickup displays Navigation and Arrived at Destination buttons',
        (tester) async {
      bool arrivedCalled = false;
      final acceptedPickup = PickupRequestDto(
        id: samplePickup.id,
        publicCode: samplePickup.publicCode,
        status: 'ACCEPTED',
        categories: samplePickup.categories,
        photoUrls: samplePickup.photoUrls,
        addressText: samplePickup.addressText,
        latitude: samplePickup.latitude,
        longitude: samplePickup.longitude,
        estimatedDistanceKm: samplePickup.estimatedDistanceKm,
        assignedCollectorId: 'KC-C-7821',
        createdAt: samplePickup.createdAt,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PickupAlertDialog(
              pickup: acceptedPickup,
              audioService: audioService,
              locale: 'mr',
              onAccept: () {},
              onDecline: () {},
              onArrived: () => arrivedCalled = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('btn_start_navigation')), findsOneWidget);
      expect(find.byKey(const Key('btn_arrived_destination')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_arrived_destination')));
      await tester.pump();
      expect(arrivedCalled, isTrue);
    });
  });

  group('PickupDispatchNotifier State Tests', () {
    test('State management transitions properly', () {
      final notifier = PickupDispatchNotifier(audioService: audioService);

      expect(notifier.state.nearbyPickups, isEmpty);
      expect(notifier.state.activePickup, isNull);

      final dummyPickup = PickupRequestDto(
        id: 'p-1',
        publicCode: 'PR-MH-2026-X1',
        status: 'CREATED',
        categories: ['PCB'],
        photoUrls: [],
        latitude: 20.932,
        longitude: 77.752,
        createdAt: DateTime.now(),
      );

      notifier.dismissAlert('p-1');
      expect(notifier.state.dismissedPickupIds, contains('p-1'));
    });
  });
}
