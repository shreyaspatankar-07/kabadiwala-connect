import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/haptics/haptic_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/price_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/price_board_screen.dart';
import 'package:kabadiwala_mobile/ui/widgets/sparkline_chart.dart';

void main() {
  late AppDatabase db;
  late PriceRepository priceRepo;
  late AudioFeedbackService audioService;

  setUp(() {
    HapticService.enableHaptics = false;
    db = AppDatabase.inMemory();
    priceRepo = PriceRepository(db);
    audioService = AudioFeedbackService(enableAudio: false);
  });

  tearDown(() async {
    HapticService.enableHaptics = true;
    audioService.dispose();
    await db.close();
  });

  Widget buildTestableWidget({
    String locale = 'mr',
    DateTime? forcedRecordedAt,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: PriceBoardScreen(
        audioService: audioService,
        priceRepository: priceRepo,
        district: 'Palghar',
        locale: locale,
        forcedRecordedAt: forcedRecordedAt,
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Price Board Widget Tests', () {
    testWidgets('1. Category grid: renders all 7 material category cards with rates and trends',
        (WidgetTester tester) async {
      configureViewport(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify grid exists
      expect(find.byKey(const Key('price_board_category_grid')), findsOneWidget);

      // Verify all 7 categories are present
      expect(find.byKey(const Key('category_tile_PCB')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_Cables')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_Batteries')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_LCD')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_Motors_Magnets')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_CRT')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_Mixed_Plastics')), findsOneWidget);

      // Verify rates displayed
      expect(find.text('₹ 420 / kg'), findsOneWidget);
      expect(find.text('₹ 680 / kg'), findsOneWidget);
      expect(find.text('₹ 140 / kg'), findsOneWidget);
    });

    testWidgets('2. Detail view: displays large price, 30-day sparkline, range bar, and plays spoken price',
        (WidgetTester tester) async {
      configureViewport(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap on PCB category tile
      await tester.tap(find.byKey(const Key('category_tile_PCB')));
      await tester.pumpAndSettle();

      // 1. Verify detail view opened
      expect(find.byKey(const Key('large_price_digits')), findsOneWidget);
      expect(find.text('₹ 420'), findsOneWidget);
      expect(find.text('/ किलो (per kg)'), findsOneWidget);

      // 2. Verify 30-day sparkline chart
      expect(find.byType(SparklineChart), findsOneWidget);

      // 3. Verify range bar and recycler quote
      expect(find.text('किमान: ₹ 390'), findsOneWidget);
      expect(find.text('रीसायकलर: ₹ 435'), findsOneWidget);
      expect(find.text('कमाल: ₹ 450'), findsOneWidget);

      // 4. Verify detail speaker button reads aloud
      await tester.tap(find.byKey(const Key('detail_speaker_button')));
      await tester.pumpAndSettle();

      expect(audioService.lastSpokenText, contains('सर्किट बोर्ड (PCB)'));
      expect(audioService.lastSpokenText, contains('420 रुपये प्रति किलो'));
      expect(audioService.lastSpokenText, contains('भाव वाढला आहे'));

      // Back to grid button
      await tester.tap(find.byKey(const Key('back_to_grid_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('price_board_category_grid')), findsOneWidget);
    });

    testWidgets('3. Staleness warning: shows amber banner when cache is older than 3 days',
        (WidgetTester tester) async {
      configureViewport(tester);

      // 1. Fresh cache: banner should NOT appear
      await tester.pumpWidget(buildTestableWidget(forcedRecordedAt: DateTime.now()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('amber_staleness_banner')), findsNothing);

      // 2. Stale cache (4 days old): banner MUST appear with prominent warning
      final staleDate = DateTime.now().subtract(const Duration(days: 4));
      await tester.pumpWidget(buildTestableWidget(forcedRecordedAt: staleDate));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('amber_staleness_banner')), findsOneWidget);
      expect(find.textContaining('दर ३ दिवसांपेक्षा जुने आहेत'), findsOneWidget);
    });

    testWidgets('4. Offline price report submission: opens number pad and enqueues to sync queue',
        (WidgetTester tester) async {
      configureViewport(tester);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Open PCB detail view
      await tester.tap(find.byKey(const Key('category_tile_PCB')));
      await tester.pumpAndSettle();

      // Scroll to ensure the report button is visible
      await tester.ensureVisible(find.byKey(const Key('report_price_button')));
      await tester.pumpAndSettle();

      // Tap "अन्य भाव नोंदवा"
      await tester.tap(find.byKey(const Key('report_price_button')));
      await tester.pumpAndSettle();

      // Verify bottom sheet number pad is displayed
      expect(find.byKey(const Key('report_price_display')), findsOneWidget);
      expect(find.text('₹ ० / kg'), findsOneWidget);

      // Tap digits uniquely using Key
      await tester.tap(find.byKey(const Key('keypad_digit_4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_digit_3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_digit_5')));
      await tester.pumpAndSettle();

      expect(find.text('₹ 435 / kg'), findsOneWidget);

      // Ensure submit button visible and tap it
      await tester.ensureVisible(find.byKey(const Key('submit_price_report_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_price_report_button')));
      await tester.pumpAndSettle();

      // Verify local database SyncQueueEntries has the queued offline report
      final syncEntries = await db.select(db.syncQueueEntries).get();
      expect(syncEntries.length, 1);
      final entry = syncEntries.first;
      expect(entry.action, 'report_price');
      expect(entry.status, 'pending');
      expect(entry.payloadJson, contains('435.0'));
      expect(entry.payloadJson, contains('PCB'));
      expect(entry.payloadJson, contains('collector_report'));

      // Verify audio feedback for report submission
      expect(audioService.lastSpokenText, contains('भाव नोंदवला गेला आहे'));
    });
  });
}
