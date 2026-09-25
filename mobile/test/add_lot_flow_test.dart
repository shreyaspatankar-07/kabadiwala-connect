import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/hardware/scale_service.dart';
import 'package:kabadiwala_mobile/core/ml/material_classifier.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/lot_repository.dart';
import 'package:kabadiwala_mobile/data/repositories/price_repository.dart';
import 'package:kabadiwala_mobile/ui/screens/add_lot_screen.dart';
import 'package:kabadiwala_mobile/ui/widgets/camera_capture_card.dart';
import 'package:kabadiwala_mobile/ui/widgets/condition_chips.dart';
import 'package:kabadiwala_mobile/ui/widgets/reference_weight_helper.dart';
import 'package:kabadiwala_mobile/ui/widgets/value_estimate_card.dart';

void main() {
  group('Add Lot Offline Flow Tests', () {
    late AppDatabase db;
    late LotRepository lotRepo;
    late PriceRepository priceRepo;
    late AudioFeedbackService audioService;
    late MaterialClassifier classifier;

    setUp(() {
      db = AppDatabase.inMemory();
      lotRepo = LotRepository(db);
      priceRepo = PriceRepository(db);
      audioService = AudioFeedbackService(enableAudio: false);
      classifier = MaterialClassifier();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('1. Photo capture flow: captures photo, computes SHA-256, and displays badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            materialClassifier: classifier,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Camera card is present
      expect(find.byType(CameraCaptureCard), findsOneWidget);
      expect(find.text('मालाचा फोटो (0/4)'), findsOneWidget);

      // Tap capture button
      await tester.tap(find.text('कॅमेरा सुरू करा (फोटो काढा)'));
      await tester.pumpAndSettle();

      // Verify photo count increased and hash badge appeared
      expect(find.text('मालाचा फोटो (1/4)'), findsOneWidget);
      expect(find.text('≤ 200 KB ✓ SHA-256'), findsOneWidget);
      expect(find.textContaining('KB'), findsWidgets);
    });

    testWidgets('2. Category selection: shows TFLite top-3 suggestions and condition chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            materialClassifier: classifier,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AI suggestions heading
      expect(find.text('कॅमेरा सुचवलेले प्रकार (Top 3):'), findsOneWidget);

      // Verify condition chips are present
      expect(find.byType(ConditionChips), findsOneWidget);
      expect(find.text('चालू स्थिति'), findsOneWidget);
      expect(find.text('फुटलेला'), findsOneWidget);

      // Scroll and tap on 'चालू स्थिति' (Working) condition
      await tester.ensureVisible(find.text('चालू स्थिति'));
      await tester.tap(find.text('चालू स्थिति'));
      await tester.pumpAndSettle();

      // Scroll and tap "सर्व पहा" to expand manual category selection
      await tester.ensureVisible(find.text('सर्व पहा'));
      await tester.tap(find.text('सर्व पहा'));
      await tester.pumpAndSettle();

      // Verify all categories are available
      expect(find.text('इतर सर्व प्रकार:'), findsOneWidget);
      expect(find.text('Cables'), findsWidgets);
      expect(find.text('Batteries'), findsWidgets);
    });

    testWidgets('3. Weight entry: keypad input, unit toggle, and reference helper',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            materialClassifier: classifier,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to weight section
      await tester.ensureVisible(find.text('gram'));

      // Verify weight box has default weight
      expect(find.text('5 kg'), findsWidgets);

      // Toggle to gram unit
      await tester.tap(find.text('gram'));
      await tester.pumpAndSettle();
      expect(find.text('5 gram'), findsOneWidget);

      // Toggle back to kg
      await tester.tap(find.text('kg'));
      await tester.pumpAndSettle();

      // Reference weight helper is visible
      expect(find.byType(ReferenceWeightHelper), findsOneWidget);
      expect(find.text('अंदाजे वजन संदर्भ चित्र:'), findsOneWidget);
    });

    testWidgets('4. Value estimate display: displays calculated rupees, min-max bar, and voice trigger',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            materialClassifier: classifier,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to value estimate card
      final estimateCardFinder = find.byType(ValueEstimateCard);
      await tester.ensureVisible(estimateCardFinder);

      expect(find.text('अंदाजे सरकारी भाव:'), findsOneWidget);
      expect(find.textContaining('₹'), findsWidgets);
      expect(find.textContaining('किमान: ₹'), findsOneWidget);
      expect(find.textContaining('कमाल: ₹'), findsOneWidget);

      // Tap speaker button on estimate card
      final estimateSpeaker = find.descendant(
        of: estimateCardFinder,
        matching: find.byIcon(Icons.volume_up_rounded),
      );
      expect(estimateSpeaker, findsOneWidget);
      await tester.ensureVisible(estimateSpeaker);
      await tester.tap(estimateSpeaker);
      await tester.pumpAndSettle();

      // Verify voice estimate was spoken
      expect(audioService.lastSpokenText, isNotNull);
      expect(audioService.lastSpokenText, contains('अंदाजे सरकारी भाव'));
    });

    testWidgets('5. Offline save: enqueues to sync queue and generates local lot ID',
        (WidgetTester tester) async {
      LocalTransaction? savedLot;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddLotScreen(
            audioService: audioService,
            lotRepository: lotRepo,
            priceRepository: priceRepo,
            materialClassifier: classifier,
            scaleService: StubBluetoothScaleService(simulatedWeight: 12.5),
            locale: 'mr',
            onLotSaved: (lot) => savedLot = lot,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll and tap "Save Lot Offline" button
      final saveBtnFinder = find.byKey(const Key('save_offline_lot_button'));
      await tester.ensureVisible(saveBtnFinder);
      await tester.tap(saveBtnFinder);
      await tester.pumpAndSettle();

      // Verify lot was saved with human friendly lotId
      expect(savedLot, isNotNull);
      expect(savedLot!.lotId, startsWith('KC-MH-'));
      expect(savedLot!.isSynced, isFalse);
      expect(savedLot!.weightKg, greaterThan(0));

      // Verify entry in SyncQueueEntries table
      final queuedEntries = await db.select(db.syncQueueEntries).get();
      expect(queuedEntries.isNotEmpty, isTrue);
      expect(queuedEntries.first.action, equals('create_lot'));
      expect(queuedEntries.first.status, equals('pending'));
      expect(queuedEntries.first.collectorId, equals('KC-C-7821'));
    });
  });
}
