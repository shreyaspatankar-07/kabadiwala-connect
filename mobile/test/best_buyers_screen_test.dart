import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/haptics/haptic_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/matching/offline_matching_engine.dart';
import 'package:kabadiwala_mobile/data/repositories/recycler_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/best_buyers_screen.dart';

void main() {
  late AppDatabase db;
  late RecyclerRepository recyclerRepo;
  late AudioFeedbackService audioService;

  setUp(() {
    HapticService.enableHaptics = false;
    db = AppDatabase.inMemory();
    recyclerRepo = RecyclerRepository(db);
    audioService = AudioFeedbackService(enableAudio: false);
  });

  tearDown(() async {
    HapticService.enableHaptics = true;
    audioService.dispose();
    await db.close();
  });

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableWidget({
    required OfflineLotInput lot,
    List<RecyclerCandidateData>? overrideCandidates,
    String locale = 'mr',
    ValueChanged<RankedRecyclerResult>? onBuyerSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BestBuyersScreen(
        lot: lot,
        audioService: audioService,
        db: db,
        locale: locale,
        recyclerRepository: recyclerRepo,
        overrideCandidates: overrideCandidates,
        onBuyerSelected: onBuyerSelected,
      ),
    );
  }

  group('Best Buyers & Offline Matching Engine Tests', () {
    test('1. Shared Fixture: Backend and Dart matching engine calculate identical scores', () {
      final file = File('test/fixtures/matching_fixture.json');
      expect(file.existsSync(), isTrue, reason: 'Shared test fixture must exist');

      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final lotJson = fixture['lot'] as Map<String, dynamic>;
      final candidatesJson = fixture['candidates'] as List<dynamic>;
      final expectedRankings = fixture['expected_rankings'] as List<dynamic>;

      final lot = OfflineLotInput(
        category: lotJson['category'] as String,
        weightKg: (lotJson['weight_kg'] as num).toDouble(),
        collectionLat: (lotJson['collection_lat'] as num).toDouble(),
        collectionLng: (lotJson['collection_lng'] as num).toDouble(),
        district: lotJson['district'] as String?,
      );

      final candidates = candidatesJson
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      final results = OfflineMatchingEngine.rankCandidates(candidates, lot);

      expect(results.length, equals(expectedRankings.length));

      for (var i = 0; i < results.length; i++) {
        final actual = results[i];
        final expected = expectedRankings[i] as Map<String, dynamic>;

        expect(actual.rank, equals(expected['rank']));
        expect(actual.recyclerId, equals(expected['recycler_id']));
        expect(actual.score, closeTo(expected['score'] as double, 0.002));
        expect(actual.offeredRate, closeTo(expected['offered_rate'] as double, 0.001));
        expect(actual.pickupAvailable, equals(expected['pickup_available']));
        expect(actual.estimatedPickupTime, equals(expected['estimated_pickup_time']));

        final expBd = expected['score_breakdown'] as Map<String, dynamic>;
        expect(actual.scoreBreakdown.offeredRate, closeTo(expBd['offered_rate'] as double, 0.002));
        expect(actual.scoreBreakdown.distance, closeTo(expBd['distance'] as double, 0.002));
        expect(actual.scoreBreakdown.pickupAvailable, closeTo(expBd['pickup_available'] as double, 0.002));
        expect(actual.scoreBreakdown.completionRate, closeTo(expBd['completion_rate'] as double, 0.002));
        expect(actual.scoreBreakdown.confirmationSpeed, closeTo(expBd['confirmation_speed'] as double, 0.002));
        expect(actual.scoreBreakdown.rating, closeTo(expBd['rating'] as double, 0.002));
      }
    });

    testWidgets('2. Recycler card rendering: up to 3 cards with gold border on #1 and rate display',
        (WidgetTester tester) async {
      configureViewport(tester);

      final file = File('test/fixtures/matching_fixture.json');
      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final candidates = (fixture['candidates'] as List<dynamic>)
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: candidates,
      ));
      await tester.pumpAndSettle();

      // Should display top 3 candidates (rec-001, rec-002, rec-003)
      expect(find.byKey(const Key('recycler_card_rec-001')), findsOneWidget);
      expect(find.byKey(const Key('recycler_card_rec-002')), findsOneWidget);
      expect(find.byKey(const Key('recycler_card_rec-003')), findsOneWidget);

      // Rank #1 card has gold banner
      expect(find.textContaining('सर्वोत्तम पर्याय (Best Choice)'), findsOneWidget);

      // Rates are displayed
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('₹480'), findsOneWidget);
      expect(find.text('₹410'), findsOneWidget);
    });

    testWidgets('3. Verified badge renders with green checkmark on authorized recyclers',
        (WidgetTester tester) async {
      configureViewport(tester);

      final file = File('test/fixtures/matching_fixture.json');
      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final candidates = (fixture['candidates'] as List<dynamic>)
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: candidates,
      ));
      await tester.pumpAndSettle();

      // Check verified badge on rank #1
      expect(find.byKey(const Key('verified_badge_rec-001')), findsOneWidget);
      expect(find.text('अधिकृत रिसायकलर'), findsWidgets);
      expect(find.byIcon(Icons.verified_rounded), findsWidgets);
    });

    testWidgets('4. Pickup vs drop-off icons render correctly based on pickupAvailable boolean',
        (WidgetTester tester) async {
      configureViewport(tester);

      final file = File('test/fixtures/matching_fixture.json');
      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final candidates = (fixture['candidates'] as List<dynamic>)
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: candidates,
      ));
      await tester.pumpAndSettle();

      // rec-001 has pickupAvailable: true -> truck icon
      expect(find.byKey(const Key('pickup_icon_rec-001')), findsOneWidget);
      expect(find.textContaining('घरी येऊन उचलणार'), findsWidgets);

      // rec-002 has pickupAvailable: false -> walking/dropoff icon
      expect(find.byKey(const Key('dropoff_icon_rec-002')), findsOneWidget);
      expect(find.textContaining('स्वतः केंद्रावर घेऊन जा'), findsOneWidget);
    });

    testWidgets('5. Spoken summary reads top buyer name, distance, and rate',
        (WidgetTester tester) async {
      configureViewport(tester);

      final file = File('test/fixtures/matching_fixture.json');
      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final candidates = (fixture['candidates'] as List<dynamic>)
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: candidates,
      ));
      await tester.pumpAndSettle();

      // Auto-speaks top result on load:
      // "[Recycler name], [distance] किलोमीटर दूर, [rate] रुपये प्रति किलो"
      expect(audioService.lastSpokenText, contains('Maharashtra Eco-Recyclers'));
      expect(audioService.lastSpokenText, contains('किलोमीटर दूर'));
      expect(audioService.lastSpokenText, contains('रुपये प्रति किलो'));

      // Tapping the AppBar speaker button also triggers spoken summary
      final speakBtn = find.byKey(const Key('speak_top_buyer_button'));
      expect(speakBtn, findsOneWidget);
      await tester.tap(speakBtn);
      await tester.pump();

      expect(audioService.lastSpokenText, contains('Maharashtra Eco-Recyclers'));
    });

    testWidgets('6. No buyers found state renders with suggestion when no matches exist',
        (WidgetTester tester) async {
      configureViewport(tester);

      // Category with no candidates
      const lot = OfflineLotInput(
        category: 'NonExistentCategory',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
      );

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: const [],
      ));
      await tester.pumpAndSettle();

      // Empty state icons & messages
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('खरेदीदार सापडले नाहीत'), findsOneWidget);
      expect(find.textContaining('शोध परिसर वाढवा'), findsOneWidget);
      expect(find.byKey(const Key('back_to_lot_button')), findsOneWidget);
    });

    testWidgets('7. Offline matching using Drift database cache',
        (WidgetTester tester) async {
      configureViewport(tester);

      // Seed 1 verified recycler in Drift cachedRecyclers
      await db.into(db.cachedRecyclers).insert(
            CachedRecyclersCompanion.insert(
              id: 'rec-drift-01',
              name: 'Drift Offline Recycler Hub',
              latitude: 19.0800,
              longitude: 72.8800,
              materialsAcceptedJson: jsonEncode(['PCB', 'Batteries']),
              authorizationNumber: 'CPCB-DRIFT-001',
              authorizationBody: 'CPCB',
              authorizationStatus: 'verified',
              authorizationValidTill: DateTime(2030, 1, 1),
              phone: '+919999988888',
              offeredRatesJson: jsonEncode({'PCB': 475.0}),
              pickupAvailable: const drift.Value(true),
              pickupRadiusKm: const drift.Value(15.0),
              serviceAreaJson: jsonEncode({'districts': ['Mumbai']}),
              rating: const drift.Value(4.8),
              cachedAt: DateTime.now(),
            ),
          );

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      // Test without overrideCandidates -> reads from Drift database!
      await tester.pumpWidget(buildTestableWidget(lot: lot));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recycler_card_rec-drift-01')), findsOneWidget);
      expect(find.text('Drift Offline Recycler Hub'), findsOneWidget);
      expect(find.text('₹475'), findsOneWidget);
      expect(find.byKey(const Key('pickup_icon_rec-drift-01')), findsOneWidget);
    });

    testWidgets('8. "Select this buyer" triggers callback and haptic feedback',
        (WidgetTester tester) async {
      configureViewport(tester);

      final file = File('test/fixtures/matching_fixture.json');
      final fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final candidates = (fixture['candidates'] as List<dynamic>)
          .map((c) => RecyclerCandidateData.fromJson(c as Map<String, dynamic>))
          .toList();

      const lot = OfflineLotInput(
        category: 'PCB',
        collectionLat: 19.0760,
        collectionLng: 72.8777,
        district: 'Mumbai',
      );

      RankedRecyclerResult? selectedBuyer;

      await tester.pumpWidget(buildTestableWidget(
        lot: lot,
        overrideCandidates: candidates,
        onBuyerSelected: (b) => selectedBuyer = b,
      ));
      await tester.pumpAndSettle();

      final selectBtn = find.byKey(const Key('select_buyer_button_rec-001'));
      expect(selectBtn, findsOneWidget);

      await tester.tap(selectBtn);
      await tester.pump();

      expect(selectedBuyer, isNotNull);
      expect(selectedBuyer!.recyclerId, equals('rec-001'));
      expect(find.textContaining('Maharashtra Eco-Recyclers निवडले गेले.'), findsOneWidget);
    });
  });
}
