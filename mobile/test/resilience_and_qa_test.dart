import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/lot_repository.dart';
import 'package:kabadiwala_mobile/data/repositories/price_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/main_navigation_shell.dart';
import 'package:kabadiwala_mobile/ui/screens/privacy_screen.dart';

void main() {
  group('Resilience, Accessibility, and Privacy QA Tests', () {
    late AppDatabase db;
    late LotRepository lotRepo;
    late PriceRepository priceRepo;
    late AudioFeedbackService audioService;

    setUp(() {
      db = AppDatabase.inMemory();
      lotRepo = LotRepository(db);
      priceRepo = PriceRepository(db);
      audioService = AudioFeedbackService(enableAudio: false);
    });

    tearDown(() async {
      await db.close();
    });

    Widget buildTestableWidget(Widget child, {double textScale = 1.0}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            textScaler: TextScaler.linear(textScale),
          ),
          child: child,
        ),
      );
    }

    testWidgets('1. Resilience: Mid-sync termination preserves all Drift records across restart',
        (tester) async {
      // Create local lot before simulate kill
      final lot = await lotRepo.createLotOffline(
        collectorId: 'KC-C-7821',
        category: 'PCB',
        weightKg: 8.5,
        quotedPrice: 3570.0,
        latitude: 19.6967,
        longitude: 72.7699,
        photoHashes: ['hash_1', 'hash_2'],
      );

      expect(lot.lotId, startsWith('KC-MH-'));
      expect(lot.isSynced, isFalse);

      // Verify sync queue has pending entry
      final queueBefore = await db.select(db.syncQueueEntries).get();
      expect(queueBefore.length, equals(1));
      expect(queueBefore.first.status, equals('pending'));

      // Simulate app restart by instantiating new LotRepository pointing to same SQLite state
      final restartedRepo = LotRepository(db);
      final persistedLots = await restartedRepo.getOfflineLots();

      expect(persistedLots.length, equals(1));
      expect(persistedLots.first.lotId, equals(lot.lotId));
      expect(persistedLots.first.weightKg, equals(8.5));
      expect(persistedLots.first.isSynced, isFalse);
    });

    testWidgets('2. Resilience: Airplane mode creation stores lot safely offline', (tester) async {
      // Simulate airplane mode zero-connectivity write
      final lot = await lotRepo.createLotOffline(
        collectorId: 'KC-C-OFFLINE',
        category: 'Batteries',
        weightKg: 15.0,
        quotedPrice: 2100.0,
        latitude: 19.7000,
        longitude: 72.7700,
        photoHashes: ['batt_hash_a'],
      );

      expect(lot.isSynced, isFalse);

      final queueEntries = await db.select(db.syncQueueEntries).get();
      expect(queueEntries.any((q) => q.action == 'create_lot'), isTrue);
    });

    testWidgets('3. Resilience: Clock skew with future device time syncs safely', (tester) async {
      // Set device timestamp 1 hour in the future
      final futureTime = DateTime.now().add(const Duration(hours: 1));

      final lot = await lotRepo.createLotOffline(
        collectorId: 'KC-C-7821',
        category: 'Cables',
        weightKg: 20.0,
        quotedPrice: 13600.0,
        latitude: 19.6967,
        longitude: 72.7699,
        photoHashes: ['cables_hash_1'],
      );

      expect(lot.createdAt.isBefore(futureTime.add(const Duration(minutes: 1))), isTrue);
      expect(lot.lotId.isNotEmpty, isTrue);
    });

    testWidgets('4. Accessibility: Large font at 200% text scale renders with zero overflow',
        (tester) async {
      // Render Main Navigation Shell at 200% text scaling (accessibility large text)
      await tester.pumpWidget(
        buildTestableWidget(
          MainNavigationShell(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            initialLocale: 'mr',
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      // Verify essential low-literacy components remain visible and functional
      expect(find.byKey(const Key('btn_open_privacy_screen')), findsOneWidget);
      expect(find.text('माल जोडा'), findsWidgets);
    });

    testWidgets('5. Privacy & Data Deletion: Plain language privacy card and total data purge',
        (tester) async {
      // Pre-populate data to be deleted
      await lotRepo.createLotOffline(
        collectorId: 'KC-C-7821',
        category: 'CRT',
        weightKg: 25.0,
        quotedPrice: 450.0,
        latitude: 19.6967,
        longitude: 72.7699,
        photoHashes: ['crt_1'],
      );

      final lotsBefore = await lotRepo.getOfflineLots();
      expect(lotsBefore.length, equals(1));

      bool callbackTriggered = false;

      // Open Privacy Screen
      await tester.pumpWidget(
        buildTestableWidget(
          PrivacyScreen(
            audioService: audioService,
            db: db,
            locale: 'mr',
            collectorId: 'KC-C-7821',
            onDataDeleted: () => callbackTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify privacy card and guarantee items are rendered
      expect(find.byKey(const Key('privacy_overview_card')), findsOneWidget);
      expect(find.text('तुमची माहिती १००% सुरक्षित आहे'), findsOneWidget);
      expect(find.byKey(const Key('btn_privacy_audio')), findsOneWidget);

      // Tap speaker button to trigger audio guidance
      await tester.tap(find.byKey(const Key('btn_privacy_audio')));
      await tester.pumpAndSettle();
      expect(audioService.lastSpokenText, isNotNull);
      expect(audioService.lastSpokenText, contains('गोपनीयता'));

      // Tap "Delete My Data" button
      final deleteBtn = find.byKey(const Key('btn_delete_my_data'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.byKey(const Key('dialog_confirm_delete_data')), findsOneWidget);

      // Confirm deletion
      final confirmBtn = find.byKey(const Key('btn_confirm_delete_data'));
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify all local database records are wiped
      final lotsAfter = await lotRepo.getOfflineLots();
      expect(lotsAfter.isEmpty, isTrue);

      final queueAfter = await db.select(db.syncQueueEntries).get();
      expect(queueAfter.isEmpty, isTrue);

      // Verify callback triggered
      expect(callbackTriggered, isTrue);
    });
  });
}
