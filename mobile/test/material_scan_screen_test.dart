import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/haptics/haptic_service.dart';
import 'package:kabadiwala_mobile/core/ml/edge_material_classifier.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/ui/screens/material_scan_screen.dart';

/// Test mock classifier allowing controlled threshold injection (<0.55 vs >=0.55)
class MockEdgeMaterialClassifier extends EdgeMaterialClassifier {
  MockEdgeMaterialClassifier({
    this.mockResult,
  });

  MaterialClassificationResult? mockResult;

  @override
  Future<void> loadModel() async {
    // Instant mock load
  }

  @override
  bool get isModelLoaded => true;

  @override
  Future<MaterialClassificationResult> classifyImage(Uint8List imageBytes) async {
    if (mockResult != null) return mockResult!;
    return const MaterialClassificationResult(
      category: 'PCB',
      confidence: 0.85,
      isLowConfidence: false,
      confidences: {'PCB': 0.85},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MaterialScanScreen Live Camera & Fallback UI Tests', () {
    late AudioFeedbackService audioService;

    setUp(() {
      HapticService.enableHaptics = false;
      audioService = AudioFeedbackService(enableAudio: false);
    });

    tearDown(() {
      HapticService.enableHaptics = true;
    });

    testWidgets('1. Live Camera Screen: Renders viewfinder, target guides, and capture controls',
        (WidgetTester tester) async {
      final mockClassifier = MockEdgeMaterialClassifier();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MaterialScanScreen(
            classifier: mockClassifier,
            audioService: audioService,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top action buttons exist
      expect(find.byKey(const Key('btn_scan_back')), findsOneWidget);

      // Viewfinder target text
      expect(find.text('ई-कचरा चौकटीत ठेवा (224x224)'), findsOneWidget);

      // Shutter capture button
      expect(find.byKey(const Key('btn_scan_capture')), findsOneWidget);
      expect(find.text('स्कॅन करण्यासाठी दाबा'), findsOneWidget);
    });

    testWidgets('2. Low Confidence (< 0.55): Displays exact warning text and 10 categories manual grid',
        (WidgetTester tester) async {
      // Mock classifier returning 0.42 confidence (< 0.55 threshold)
      final lowConfMock = MockEdgeMaterialClassifier(
        mockResult: const MaterialClassificationResult(
          category: 'PCB',
          confidence: 0.42,
          isLowConfidence: true,
          confidences: {'PCB': 0.42, 'Mobile': 0.25},
        ),
      );

      String? confirmedCategory;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MaterialScanScreen(
            classifier: lowConfMock,
            audioService: audioService,
            locale: 'mr',
            onCategoryConfirmed: (cat) => confirmedCategory = cat,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap capture button to trigger classification
      await tester.tap(find.byKey(const Key('btn_scan_capture')));
      await tester.pumpAndSettle();

      // Verification of Fallback Requirement:
      // "Low Confidence: Please select item manually from the grid."
      expect(
        find.text('Low Confidence: Please select item manually from the grid.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('warning_low_confidence_banner')), findsOneWidget);

      // Verify all 10 categories exist in the manual selection grid
      const expected10 = [
        'Battery',
        'Keyboard',
        'Microwave',
        'Mobile',
        'Mouse',
        'PCB',
        'Player',
        'Printer',
        'Television',
        'Washing Machine',
      ];

      for (final cat in expected10) {
        expect(find.byKey(Key('grid_category_$cat')), findsOneWidget);
      }

      // Tap on 'Battery' category tile in the grid
      await tester.tap(find.byKey(const Key('grid_category_Battery')));
      await tester.pumpAndSettle();

      // Scroll to make confirm button visible in the bottom sheet
      await tester.ensureVisible(find.byKey(const Key('btn_scan_confirm')));
      await tester.pumpAndSettle();

      // Confirm button is now active, tap confirm
      await tester.tap(find.byKey(const Key('btn_scan_confirm')));
      await tester.pumpAndSettle();

      expect(confirmedCategory, 'Battery');
    });

    testWidgets('3. High Confidence (>= 0.55): Displays predicted category and confidence percentage',
        (WidgetTester tester) async {
      // Mock classifier returning 0.89 confidence (>= 0.55 threshold)
      final highConfMock = MockEdgeMaterialClassifier(
        mockResult: const MaterialClassificationResult(
          category: 'Mobile',
          confidence: 0.89,
          isLowConfidence: false,
          confidences: {'Mobile': 0.89, 'Keyboard': 0.05},
        ),
      );

      String? confirmedCategory;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MaterialScanScreen(
            classifier: highConfMock,
            audioService: audioService,
            locale: 'mr',
            onCategoryConfirmed: (cat) => confirmedCategory = cat,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap capture button
      await tester.tap(find.byKey(const Key('btn_scan_capture')));
      await tester.pumpAndSettle();

      // Verification of Confident UI Requirement:
      // Display the predicted category and confidence percentage
      expect(find.byKey(const Key('card_confident_prediction')), findsOneWidget);
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('89%'), findsOneWidget);
      expect(find.text('अचूक ओळख'), findsOneWidget);

      // Confirm button is immediately ready with predicted category
      await tester.tap(find.byKey(const Key('btn_scan_confirm')));
      await tester.pumpAndSettle();

      expect(confirmedCategory, 'Mobile');
    });

    testWidgets('4. Scanned Image Preview: Clicking image icon opens ImagePreviewDialog',
        (WidgetTester tester) async {
      final highConfMock = MockEdgeMaterialClassifier(
        mockResult: const MaterialClassificationResult(
          category: 'Mobile',
          confidence: 0.89,
          isLowConfidence: false,
          confidences: {'Mobile': 0.89},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MaterialScanScreen(
            classifier: highConfMock,
            audioService: audioService,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Capture frame
      await tester.tap(find.byKey(const Key('btn_scan_capture')));
      await tester.pumpAndSettle();

      // Scanned photo thumbnail and image icon are displayed
      expect(find.byKey(const Key('btn_preview_scanned_image')), findsOneWidget);
      expect(find.byKey(const Key('btn_preview_scanned_image_icon')), findsOneWidget);

      // Tap preview image icon button
      await tester.tap(find.byKey(const Key('btn_preview_scanned_image_icon')));
      await tester.pumpAndSettle();

      // ImagePreviewDialog is displayed
      expect(find.byKey(const Key('dialog_image_preview')), findsOneWidget);

      // Close dialog
      await tester.tap(find.byKey(const Key('btn_close_image_preview')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dialog_image_preview')), findsNothing);
    });
  });
}
