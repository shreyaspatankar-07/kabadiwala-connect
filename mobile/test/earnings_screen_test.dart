import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/haptics/haptic_service.dart';
import 'package:kabadiwala_mobile/core/pdf/pdf_statement_generator.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/ledger_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/earnings_screen.dart';

void main() {
  late AppDatabase db;
  late AudioFeedbackService audioService;
  late LedgerRepository ledgerRepo;

  setUp(() {
    HapticService.enableHaptics = false;
    db = AppDatabase.inMemory();
    audioService = AudioFeedbackService(enableAudio: false);
    ledgerRepo = LedgerRepository(db);
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

  Future<void> seedTestData() async {
    const collectorId = 'KC-C-TEST01';
    final now = DateTime.now();

    // 1. Seed Recycler
    await db.into(db.cachedRecyclers).insert(
          CachedRecyclersCompanion.insert(
            id: 'REC-ECO-01',
            name: 'EcoRecycle Solutions',
            latitude: 19.0760,
            longitude: 72.8777,
            materialsAcceptedJson: jsonEncode(['PCB', 'Batteries']),
            authorizationNumber: 'CPCB-REC-2024-MH01',
            authorizationBody: 'CPCB',
            authorizationStatus: 'verified',
            authorizationValidTill: now.add(const Duration(days: 365)),
            phone: '+91 98200 99999',
            offeredRatesJson: jsonEncode({'PCB': 420.0}),
            pickupAvailable: const drift.Value(true),
            pickupRadiusKm: const drift.Value(25.0),
            serviceAreaJson: jsonEncode({'districts': ['Mumbai']}),
            rating: const drift.Value(4.8),
            cachedAt: now,
          ),
        );

    // 2. Seed Transactions
    await db.into(db.localTransactions).insert(
          LocalTransactionsCompanion.insert(
            lotId: 'LOT-PCB-01',
            clientLotUuid: 'uuid-pcb-01',
            collectorId: collectorId,
            category: 'PCB',
            weightKg: 10.0,
            quotedPrice: 4200.0,
            collectionLat: 19.0760,
            collectionLng: 72.8777,
            createdAt: now.subtract(const Duration(hours: 2)),
            finalPrice: const drift.Value(4200.0),
            recyclerId: const drift.Value('REC-ECO-01'),
            paymentStatus: const drift.Value('cash_received'),
            transactionStatus: const drift.Value('handed_over'),
          ),
        );

    await db.into(db.localTransactions).insert(
          LocalTransactionsCompanion.insert(
            lotId: 'LOT-BATT-02',
            clientLotUuid: 'uuid-batt-02',
            collectorId: collectorId,
            category: 'Batteries',
            weightKg: 20.0,
            quotedPrice: 2400.0,
            collectionLat: 19.0760,
            collectionLng: 72.8777,
            createdAt: now.subtract(const Duration(days: 2)),
            finalPrice: const drift.Value(2400.0),
            recyclerId: const drift.Value('REC-ECO-01'),
            paymentStatus: const drift.Value('pending'),
            transactionStatus: const drift.Value('handed_over'),
          ),
        );

    // 3. Seed Ledger entries
    await db.into(db.localLedger).insert(
          LocalLedgerCompanion.insert(
            id: 'ENTRY-001',
            collectorId: collectorId,
            lotId: const drift.Value('LOT-PCB-01'),
            entryType: 'credit',
            amount: 4200.0,
            paymentMode: const drift.Value('cash_received'),
            description: 'Cash received for 10kg PCB',
            balanceAfter: 4200.0,
            recordedAt: now.subtract(const Duration(hours: 2)),
          ),
        );

    await db.into(db.localLedger).insert(
          LocalLedgerCompanion.insert(
            id: 'ENTRY-002',
            collectorId: collectorId,
            lotId: const drift.Value('LOT-BATT-02'),
            entryType: 'credit',
            amount: 2400.0,
            paymentMode: const drift.Value('pending'),
            description: 'Pending payment for 20kg Batteries',
            balanceAfter: 6600.0,
            recordedAt: now.subtract(const Duration(days: 2)),
          ),
        );
  }

  group('Earnings Screen & Cash Ledger Tests', () {
    testWidgets('1. Summary tiles display Today, This Week, and This Month in rupees', (tester) async {
      configureViewport(tester);
      await seedTestData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EarningsScreen(
            db: db,
            audioService: audioService,
            locale: 'mr',
            ledgerRepository: ledgerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Three Summary Tiles
      expect(find.byKey(const Key('tile_today')), findsOneWidget);
      expect(find.byKey(const Key('tile_week')), findsOneWidget);
      expect(find.byKey(const Key('tile_month')), findsOneWidget);

      // Verify amounts: Today = ₹4200 inside tile_today, Week = ₹6600, Month = ₹6600
      expect(
        find.descendant(of: find.byKey(const Key('tile_today')), matching: find.text('₹4200')),
        findsOneWidget,
      );
      expect(find.text('₹6600'), findsNWidgets(2)); // Week and Month both have 6600
    });

    testWidgets('2. Received vs. pending split bar visually reflects proportions', (tester) async {
      configureViewport(tester);
      await seedTestData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EarningsScreen(
            db: db,
            audioService: audioService,
            locale: 'mr',
            ledgerRepository: ledgerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('earnings_split_bar')), findsOneWidget);
      expect(find.textContaining('मिळाले: ₹4200'), findsOneWidget);
      expect(find.textContaining('येणे बाकी: ₹2400'), findsOneWidget);
    });

    testWidgets('3. Pending dues section displayed prominently with recycler contact button', (tester) async {
      configureViewport(tester);
      await seedTestData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EarningsScreen(
            db: db,
            audioService: audioService,
            locale: 'mr',
            ledgerRepository: ledgerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pending dues banner
      expect(find.byKey(const Key('pending_dues_section')), findsOneWidget);
      expect(find.textContaining('रक्कम येणे बाकी'), findsOneWidget);
      expect(find.text('₹2400'), findsWidgets);

      // Contact button exists on the pending transaction
      expect(find.byKey(const Key('contact_recycler_button')), findsOneWidget);
    });

    testWidgets('4. One-tap "Mark as Cash Received" updates Drift and enqueues to sync queue', (tester) async {
      configureViewport(tester);
      await seedTestData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EarningsScreen(
            db: db,
            audioService: audioService,
            locale: 'mr',
            ledgerRepository: ledgerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Mark as Cash Received on ENTRY-002
      final markCashBtn = find.byKey(const Key('mark_cash_button_ENTRY-002'));
      expect(markCashBtn, findsOneWidget);

      await tester.tap(markCashBtn);
      await tester.pumpAndSettle();

      // 1. Check Drift table was updated to cash_received
      final entry = await (db.select(db.localLedger)..where((l) => l.id.equals('ENTRY-002'))).getSingle();
      expect(entry.paymentMode, 'cash_received');

      // 2. Check LocalTransactions was updated to cash_received
      final tx = await (db.select(db.localTransactions)..where((t) => t.lotId.equals('LOT-BATT-02'))).getSingle();
      expect(tx.paymentStatus, 'cash_received');

      // 3. Check SyncQueueEntries has record_cash_payment operation
      final queue = await db.select(db.syncQueueEntries).get();
      expect(queue.any((q) => q.action == 'record_cash_payment'), isTrue);

      // 4. In UI, pending button should be gone
      expect(find.byKey(const Key('mark_cash_button_ENTRY-002')), findsNothing);
    });

    testWidgets('5. Optional UPI payment QR is hidden by default and only shows on tap', (tester) async {
      configureViewport(tester);
      await seedTestData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EarningsScreen(
            db: db,
            audioService: audioService,
            locale: 'mr',
            ledgerRepository: ledgerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By default, UPI QR card should NOT be visible (Cash-first!)
      expect(find.byKey(const Key('upi_payment_card')), findsNothing);

      // Tap "UPI पेमेंट" button
      final toggleUpiBtn = find.byKey(const Key('toggle_upi_button'));
      expect(toggleUpiBtn, findsOneWidget);
      await tester.tap(toggleUpiBtn);
      await tester.pumpAndSettle();

      // Now UPI payment card and QR code must be visible
      expect(find.byKey(const Key('upi_payment_card')), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.textContaining('collector.kabadiwala@upi'), findsOneWidget);
    });

    test('6. Pure-Dart PDF statement generator produces valid PDF bytes and file', () async {
      final now = DateTime.now();
      final items = [
        LedgerItemDetail(
          entryId: 'E-01',
          lotId: 'LOT-01',
          category: 'PCB',
          weightKg: 12.5,
          amount: 5250.0,
          paymentStatus: 'cash_received',
          recyclerName: 'EcoRecycle Solutions',
          recordedAt: now,
        ),
      ];

      final file = await PdfStatementGenerator.generateEarningsStatementPdf(
        collectorId: 'KC-C-TEST01',
        statementRefNo: 'STMT-TEST-001',
        fromDate: now.subtract(const Duration(days: 30)),
        toDate: now,
        totalEarned: 5250.0,
        cashReceived: 5250.0,
        pendingAmount: 0.0,
        items: items,
        targetDirectory: Directory.systemTemp,
      );

      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      final header = ascii.decode(bytes.sublist(0, 8));
      expect(header, startsWith('%PDF-1.4'));
      expect(bytes.length, greaterThan(200));

      // Clean up test file
      await file.delete();
    });
  });
}
