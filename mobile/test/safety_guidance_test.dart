import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/lot_repository.dart';
import 'package:kabadiwala_mobile/data/repositories/price_repository.dart';
import 'package:kabadiwala_mobile/data/safety_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/add_lot_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/safety_card_detail_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/safety_screen.dart';

void main() {
  late AppDatabase db;
  late LotRepository lotRepo;
  late PriceRepository priceRepo;
  late AudioFeedbackService audioService;
  late SafetyRepository safetyRepo;

  setUp(() {
    db = AppDatabase.inMemory();
    lotRepo = LotRepository(db);
    priceRepo = PriceRepository(db);
    audioService = AudioFeedbackService();
    safetyRepo = SafetyRepository();
    safetyRepo.resetAcknowledgements();
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Safety Guidance Module Tests', () {
    testWidgets('1. Safety card list renders topics with comic-style cards', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const SafetyScreen(locale: 'mr')),
      );
      await tester.pumpAndSettle();

      // Verify list is visible
      expect(find.byKey(const Key('safety_card_list')), findsOneWidget);

      // Verify initial visible topics are present
      expect(find.byKey(const Key('safety_card_cables_burn')), findsOneWidget);
      expect(find.byKey(const Key('safety_card_crt_monitor')), findsOneWidget);
      expect(find.text('तांब्यासाठी केबल कधीही जाळू नका'), findsOneWidget);

      // Scroll and find remaining topics
      await tester.drag(find.byKey(const Key('safety_card_list')), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('safety_card_battery_crush')), findsOneWidget);
    });

    testWidgets('2. Card detail view displays 3-5 steps, DOs, DONTs and audio trigger', (tester) async {
      final card = safetyRepo.getCardByTopic('crt_monitor', locale: 'mr')!;

      await tester.pumpWidget(
        buildTestableWidget(SafetyCardDetailScreen(card: card, locale: 'mr')),
      );
      await tester.pumpAndSettle();

      // Check header title & summary
      expect(find.text('CRT मॉनिटर किंवा टीव्ही कधीही फोडू नका'), findsAtLeastNWidgets(1));
      expect(find.text('काय करावे (योग्य पद्धत)'), findsOneWidget);
      expect(find.text('काय करू नये (धोकादायक)'), findsOneWidget);

      // Replay speaker button
      expect(find.byKey(const Key('btn_replay_safety_audio')), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_replay_safety_audio')));
      await tester.pump();
    });

    testWidgets('3. "I Understood" action records acknowledgment locally and updates badge', (tester) async {
      final card = safetyRepo.getCardByTopic('cables_burn', locale: 'mr')!;
      expect(safetyRepo.isCardAcknowledged('cables_burn'), isFalse);

      await tester.pumpWidget(
        buildTestableWidget(SafetyCardDetailScreen(card: card, locale: 'mr')),
      );
      await tester.pumpAndSettle();

      // Tap "मला नियम समजला" button with ensureVisible
      final understandBtn = find.byKey(const Key('btn_i_understood'));
      expect(understandBtn, findsOneWidget);
      await tester.ensureVisible(understandBtn);
      await tester.tap(understandBtn);
      await tester.pumpAndSettle();

      // Verify repository updated
      expect(safetyRepo.isCardAcknowledged('cables_burn'), isTrue);

      // Now verify in list view, acknowledged badge is displayed
      await tester.pumpWidget(
        buildTestableWidget(const SafetyScreen(locale: 'mr')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('acknowledged_badge_cables_burn')), findsOneWidget);
    });

    testWidgets('4. Contextual CRT nudge in Add Lot flow displays banner and dialog', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "सर्व पहा" to expand all categories
      final seeAllBtn = find.text('सर्व पहा');
      await tester.ensureVisible(seeAllBtn);
      await tester.tap(seeAllBtn);
      await tester.pumpAndSettle();

      // Switch category to CRT
      final crtTile = find.byKey(const Key('category_tile_CRT'));
      expect(crtTile, findsOneWidget);
      await tester.ensureVisible(crtTile);
      await tester.tap(crtTile);
      await tester.pumpAndSettle();

      // Verify contextual warning banner appears
      expect(find.byKey(const Key('contextual_crt_warning_banner')), findsOneWidget);
      expect(find.text('CRT मॉनिटर किंवा टीव्ही कधीही फोडू नका'), findsOneWidget);

      // Enter weight and tap save lot -> triggers contextual modal
      final saveBtn = find.byKey(const Key('save_offline_lot_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify AlertDialog is shown
      expect(find.byKey(const Key('contextual_safety_dialog_crt_monitor')), findsOneWidget);

      // Acknowledge and proceed
      final proceedBtn = find.byKey(const Key('btn_acknowledge_nudge_proceed'));
      expect(proceedBtn, findsOneWidget);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      // Verify CRT card acknowledged
      expect(safetyRepo.isCardAcknowledged('crt_monitor'), isTrue);
    });

    testWidgets('5. Contextual burnt condition warning banner displays on burnt selection', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select 'जळालेला' (Burnt) condition chip
      final burntChip = find.byKey(const Key('condition_chip_burnt'));
      expect(burntChip, findsOneWidget);
      await tester.ensureVisible(burntChip);
      await tester.tap(burntChip);
      await tester.pumpAndSettle();

      // Verify burnt condition warning banner is displayed
      expect(find.byKey(const Key('contextual_burnt_warning_banner')), findsOneWidget);
      expect(find.text('जळालेला ई-कचरा: अधिकृत मार्गानेच विल्हेवाट लावा'), findsOneWidget);
    });
  });
}
