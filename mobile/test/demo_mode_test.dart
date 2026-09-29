import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/demo/demo_mode_service.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/ui/screens/main_navigation_shell.dart';
import 'package:kabadiwala_mobile/ui/screens/privacy_screen.dart';

void main() {
  group('In-App Demo Mode & Offline Simulation Tests', () {
    late AppDatabase db;
    late AudioFeedbackService audioService;

    setUp(() async {
      db = AppDatabase.inMemory();
      audioService = AudioFeedbackService();
      await DemoModeService.instance.setDemoMode(false);
      DemoModeService.instance.setSimulatedOffline(false);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('1. Demo Mode toggle in PrivacyScreen pre-seeds Drift database', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScreen(
            audioService: audioService,
            db: db,
            locale: 'mr',
          ),
        ),
      );

      // Verify Demo Mode card is rendered
      expect(find.byKey(const Key('demo_mode_settings_card')), findsOneWidget);
      expect(DemoModeService.instance.isDemoMode, isFalse);

      // Toggle Demo Mode Switch ON
      await tester.ensureVisible(find.byKey(const Key('switch_demo_mode')));
      await tester.tap(find.byKey(const Key('switch_demo_mode')));
      await tester.pumpAndSettle();

      expect(DemoModeService.instance.isDemoMode, isTrue);

      // Verify Drift database received seeded demo recyclers, prices, transactions, and ledger
      final recyclers = await db.select(db.cachedRecyclers).get();
      expect(recyclers.length, greaterThanOrEqualTo(3));

      final prices = await db.select(db.cachedPrices).get();
      expect(prices.length, greaterThanOrEqualTo(4));

      final txs = await db.select(db.localTransactions).get();
      expect(txs.length, greaterThanOrEqualTo(4));

      final ledger = await db.select(db.localLedger).get();
      expect(ledger.length, greaterThanOrEqualTo(3));

      // Verify offline simulation button is visible when demo mode is ON
      await tester.ensureVisible(find.byKey(const Key('btn_simulate_offline_toggle')));
      expect(find.byKey(const Key('btn_simulate_offline_toggle')), findsOneWidget);

      // Toggle offline simulation ON
      await tester.tap(find.byKey(const Key('btn_simulate_offline_toggle')));
      await tester.pumpAndSettle();
      expect(DemoModeService.instance.isSimulatedOffline, isTrue);
    });

    testWidgets('2. MainNavigationShell displays persistent yellow DEMO banner when active', (tester) async {
      await DemoModeService.instance.setDemoMode(true, db);

      await tester.pumpWidget(
        MaterialApp(
          home: MainNavigationShell(
            audioService: audioService,
            db: db,
            initialLocale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify yellow DEMO banner is visible
      expect(find.byKey(const Key('banner_demo_mode')), findsOneWidget);
      expect(find.text('DEMO'), findsOneWidget);
      expect(find.byKey(const Key('btn_toggle_simulated_offline')), findsOneWidget);

      // Tap simulated offline button in banner
      await tester.tap(find.byKey(const Key('btn_toggle_simulated_offline')));
      await tester.pumpAndSettle();
      expect(DemoModeService.instance.isSimulatedOffline, isTrue);
    });
  });
}
