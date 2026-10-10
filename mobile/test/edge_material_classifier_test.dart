import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kabadiwala_mobile/core/ml/edge_material_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EdgeMaterialClassifier Unit & Tensor Tests', () {
    late EdgeMaterialClassifier classifier;

    setUp(() {
      classifier = EdgeMaterialClassifier();
    });

    tearDown(() {
      classifier.dispose();
    });

    test('1. Alphabetical Categories: Exactly 10 sorted categories', () {
      const expected = [
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

      expect(EdgeMaterialClassifier.categories.length, 10);
      expect(EdgeMaterialClassifier.categories, orderedEquals(expected));

      // Verify each category has rich UI metadata
      for (final cat in expected) {
        expect(EdgeMaterialClassifier.categoryMetadata.containsKey(cat), isTrue);
        final meta = EdgeMaterialClassifier.categoryMetadata[cat]!;
        expect(meta.displayNameEn, isNotEmpty);
        expect(meta.displayNameMr, isNotEmpty);
        expect(meta.displayNameHi, isNotEmpty);
        expect(meta.icon, isNotNull);
      }
    });

    test('2. INT8 Quantization Formula: ((pixel_value / scale) + zero_point) cast to Int8', () {
      // Test 1: Standard scale=1.0, zeroPoint=0
      expect(EdgeMaterialClassifier.quantizePixelToInt8(0, 1.0, 0), 0);
      expect(EdgeMaterialClassifier.quantizePixelToInt8(127, 1.0, 0), 127);
      expect(EdgeMaterialClassifier.quantizePixelToInt8(255, 1.0, 0), 127); // Clamped to Int8 max

      // Test 2: Quantization with scale=0.0078125 (~1/128) and zeroPoint=-128
      // pixel=0 -> (0 / 0.0078125) + (-128) = -128
      final q0 = EdgeMaterialClassifier.quantizePixelToInt8(0, 0.0078125, -128);
      expect(q0, -128);

      // pixel=128 -> (128 / 0.0078125) is clamped to 127
      final qHigh = EdgeMaterialClassifier.quantizePixelToInt8(128, 0.0078125, -128);
      expect(qHigh, 127);

      // Test 3: Scale=0 edge case fallback (avoid divide by zero)
      final qZeroScale = EdgeMaterialClassifier.quantizePixelToInt8(100, 0.0, 0);
      expect(qZeroScale, 100);

      // Test 4: Fractional rounding to nearest integer
      final qRound = EdgeMaterialClassifier.quantizePixelToInt8(50.4, 1.0, 0);
      expect(qRound, 50);
      final qRoundUp = EdgeMaterialClassifier.quantizePixelToInt8(50.6, 1.0, 0);
      expect(qRoundUp, 51);
    });

    test('3. Preprocessing: Resizes frame to 224x224 and extracts RGB pixels', () async {
      // Create a test 400x300 image
      final testImg = img.Image(width: 400, height: 300);
      // Fill with blue
      img.fill(testImg, color: img.ColorRgb8(0, 50, 200));
      final encodedBytes = img.encodeJpg(testImg);

      await classifier.loadModel();
      expect(classifier.isModelLoaded, isTrue);

      final result = await classifier.classifyImage(encodedBytes);
      expect(result, isNotNull);
      expect(result.confidences.length, 10);
      expect(EdgeMaterialClassifier.categories.contains(result.category), isTrue);
    });

    test('4. Threshold Fallback Logic: < 0.55 flags isLowConfidence = true', () {
      const lowResult = MaterialClassificationResult(
        category: 'PCB',
        confidence: 0.42,
        isLowConfidence: true,
        confidences: {'PCB': 0.42, 'Battery': 0.20},
      );

      expect(lowResult.isLowConfidence, isTrue);
      expect(lowResult.confidence, lessThan(0.55));
      expect(lowResult.confidencePercent, 42);
    });

    test('5. Confident Prediction Logic: >= 0.55 flags isLowConfidence = false', () {
      const highResult = MaterialClassificationResult(
        category: 'Battery',
        confidence: 0.88,
        isLowConfidence: false,
        confidences: {'Battery': 0.88, 'PCB': 0.05},
      );

      expect(highResult.isLowConfidence, isFalse);
      expect(highResult.confidence, greaterThanOrEqualTo(0.55));
      expect(highResult.confidencePercent, 88);
    });
  });
}
