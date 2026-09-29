import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/handover/offline_handover_service.dart';
import 'package:kabadiwala_mobile/core/haptics/haptic_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/ui/screens/handover_initiate_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/recycler_confirm_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/verify_handover_screen.dart';
import 'package:kabadiwala_mobile/ui/widgets/downstream_timeline_widget.dart';
import 'package:kabadiwala_mobile/ui/widgets/handover_receipt_card.dart';

void main() {
  late AppDatabase db;
  late AudioFeedbackService audioService;
  late OfflineHandoverService handoverService;

  setUp(() {
    HapticService.enableHaptics = false;
    db = AppDatabase.inMemory();
    audioService = AudioFeedbackService(enableAudio: false);
    handoverService = OfflineHandoverService(db);
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

  group('Handover & QR Flow Widget Tests', () {
    test('Offline QR generation & cryptographic HMAC-SHA256 signature verification', () async {
      const lotId = 'LOT-TEST-001';
      const weight = 15.5;
      final hashes = ['hash_front_123', 'hash_back_456'];

      final result = await handoverService.initiateHandover(
        lotId: lotId,
        weightKg: weight,
        photoHashes: hashes,
        gpsLat: 19.0760,
        gpsLng: 72.8777,
      );

      // Check 6-character alphanumeric uppercase code
      expect(result.handoverRefNo.length, 6);
      expect(RegExp(r'^[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{6}$').hasMatch(result.handoverRefNo), isTrue);

      // Check JSON payload structure
      final payloadMap = jsonDecode(result.qrPayload) as Map<String, dynamic>;
      expect(payloadMap['lot_id'], lotId);
      expect(payloadMap['weight_kg'], weight);
      expect(payloadMap['handover_ref_no'], result.handoverRefNo);
      expect(payloadMap['signature'], isNotEmpty);

      // Verify authentic signature
      final isValid = OfflineHandoverService.verifyPayloadSignature(result.qrPayload);
      expect(isValid, isTrue);

      // Verify tampered weight detection
      payloadMap['weight_kg'] = 99.0;
      final tamperedPayload = jsonEncode(payloadMap);
      final isTamperedValid = OfflineHandoverService.verifyPayloadSignature(tamperedPayload);
      expect(isTamperedValid, isFalse);
    });

    testWidgets('QR display & 6-character short code rendering in HandoverInitiateScreen', (tester) async {
      configureViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HandoverInitiateScreen(
            lotId: 'LOT-9988',
            initialWeightKg: 12.0,
            category: 'PCB',
            recyclerName: 'EcoRecycle Solutions',
            quotedPrice: 3500.0,
            db: db,
            audioService: audioService,
            locale: 'mr',
            handoverService: handoverService,
            autoGenerateQr: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check summary card elements
      expect(find.textContaining('LOT-9988'), findsOneWidget);
      expect(find.textContaining('EcoRecycle Solutions'), findsOneWidget);
      expect(find.textContaining('12'), findsWidgets);

      // Tap generate QR button via Key
      final generateBtn = find.byKey(const Key('generate_qr_button'));
      expect(generateBtn, findsOneWidget);
      await tester.tap(generateBtn);
      await tester.pumpAndSettle();

      // Verify primary QR Code image is rendered
      expect(find.byKey(const Key('handover_qr_image')), findsOneWidget);

      // Verify 6-character code badge is displayed
      expect(find.byKey(const Key('handover_short_code_badge')), findsOneWidget);
      expect(find.textContaining('किंवा खालील ६-अक्षरी कोड सांगा:'), findsOneWidget);
    });

    testWidgets('Recycler confirmation flow & live weight mismatch warning (>10%)', (tester) async {
      configureViewport(tester);

      // 1. Pre-seed handover record in local database
      final init = await handoverService.initiateHandover(
        lotId: 'LOT-DISPUTE-01',
        weightKg: 10.0,
        photoHashes: ['hash_123'],
        gpsLat: 19.0760,
        gpsLng: 72.8777,
      );

      // Collector weight is 10.0 kg
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: RecyclerConfirmScreen(
            handoverRefNo: init.handoverRefNo,
            collectorWeightKg: 10.0,
            lotId: 'LOT-DISPUTE-01',
            db: db,
            audioService: audioService,
            locale: 'mr',
            handoverService: handoverService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially weight is 10.0 kg, delta is 0%, no warning
      expect(find.byKey(const Key('weight_mismatch_warning')), findsNothing);

      // Backspace to clear weight (currently "10")
      final backspaceBtn = find.byIcon(Icons.backspace_rounded);
      await tester.tap(backspaceBtn);
      await tester.pumpAndSettle();
      await tester.tap(backspaceBtn);
      await tester.pumpAndSettle();

      // Enter 15 kg (50% mismatch > 10% tolerance)
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // Warning banner should now be visible
      expect(find.byKey(const Key('weight_mismatch_warning')), findsOneWidget);
      expect(find.textContaining('१०% मर्यादेपेक्षा जास्त'), findsOneWidget);
      expect(find.textContaining('विवादित नोंदवा (Confirm Disputed)'), findsOneWidget);

      // Tap confirm with dispute
      final confirmBtn = find.byKey(const Key('confirm_handover_button'));
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Status should transition to dispute success screen
      expect(find.textContaining('हस्तांतरण विवादित (Disputed)'), findsOneWidget);
    });

    testWidgets('Handover receipt card rendering and share callback execution', (tester) async {
      configureViewport(tester);
      bool shareCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: HandoverReceiptCard(
                lotId: 'LOT-RCP-01',
                handoverRefNo: 'X9K2PQ',
                qrPayload: '{"lot_id":"LOT-RCP-01","handover_ref_no":"X9K2PQ"}',
                category: 'Batteries',
                weightKg: 24.5,
                recyclerName: 'Maha Green Recyclers',
                timestamp: DateTime(2026, 9, 25, 14, 30),
                locale: 'en',
                onShareClicked: () {
                  shareCallbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify card contents (code is spaced for readability)
      expect(find.text('X 9 K 2 P Q'), findsOneWidget);
      expect(find.text('LOT-RCP-01'), findsOneWidget);
      expect(find.text('Maha Green Recyclers'), findsOneWidget);
      expect(find.text('24.5 kg'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);

      // Tap share button
      final shareBtn = find.byKey(const Key('share_receipt_button'));
      expect(shareBtn, findsOneWidget);
      await tester.tap(shareBtn);
      await tester.pumpAndSettle();

      expect(shareCallbackCalled, isTrue);
    });

    testWidgets('Downstream 4-step timeline rendering and progression', (tester) async {
      configureViewport(tester);

      // Test with 'processed' (step 3 of 4 active)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownstreamTimelineWidget(
              currentStatus: 'processed',
              locale: 'mr',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 4 steps are rendered
      expect(find.text('माल मिळाला'), findsOneWidget); // received
      expect(find.text('विघटन पूर्ण'), findsOneWidget); // dismantled
      expect(find.text('प्रक्रिया सुरू'), findsOneWidget); // processed
      expect(find.text('प्रमाणपत्र जारी'), findsOneWidget); // certificate_issued

      // Verify icons are present
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.build_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.recycling_rounded), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      // Verify keys for timeline steps
      expect(find.byKey(const Key('timeline_step_received')), findsOneWidget);
      expect(find.byKey(const Key('timeline_step_dismantled')), findsOneWidget);
      expect(find.byKey(const Key('timeline_step_processed')), findsOneWidget);
      expect(find.byKey(const Key('timeline_step_certificate_issued')), findsOneWidget);
    });

    testWidgets('Public in-app VerifyHandoverScreen verification flow', (tester) async {
      configureViewport(tester);

      // Pre-seed a verified traceability record in the database
      final initResult = await handoverService.initiateHandover(
        lotId: 'LOT-VERIFY-01',
        weightKg: 8.5,
        photoHashes: ['photo_hash_abc'],
        gpsLat: 19.0760,
        gpsLng: 72.8777,
      );

      // Recycler confirms it
      await handoverService.confirmHandover(
        handoverRefNo: initResult.handoverRefNo,
        measuredWeightKg: 8.5,
        finalPrice: 1200.0,
        recyclerId: 'REC-ECO-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VerifyHandoverScreen(
            db: db,
            audioService: audioService,
            initialRefNo: initResult.handoverRefNo,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify verification result badge is displayed
      expect(find.byKey(const Key('verify_result_card')), findsOneWidget);
      expect(find.byKey(const Key('integrity_status_badge')), findsOneWidget);
      expect(find.textContaining('प्रमाणित व सुरक्षित (Tamper-Free & Verified)'), findsOneWidget);
      expect(find.textContaining('8.5 kg'), findsOneWidget);
      expect(find.textContaining('होय (Confirmed)'), findsOneWidget);

      // Downstream timeline should be embedded
      expect(find.byType(DownstreamTimelineWidget), findsOneWidget);
    });
  });
}
