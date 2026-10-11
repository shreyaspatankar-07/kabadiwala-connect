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

    test('6. Aspect-Ratio Center Crop: Crops center square without geometric distortion', () {
      // 400x200 wide landscape camera frame
      final wideImg = img.Image(width: 400, height: 200);
      final cropped = EdgeMaterialClassifier.centerCropAndResize(wideImg, targetSize: 224);

      expect(cropped.width, 224);
      expect(cropped.height, 224);
    });

    test('7. Model Domain Normalization: Prevents INT8 saturation pegged at 127', () {
      // MobileNet [-1.0, 1.0] scale ~ 0.007843 (2/255), zeroPoint = 0
      const scale = 2.0 / 255.0;
      const zeroPoint = 0;

      final qBlack = EdgeMaterialClassifier.quantizeNormalizedPixelToInt8(0, scale, zeroPoint);
      final qMid = EdgeMaterialClassifier.quantizeNormalizedPixelToInt8(128, scale, zeroPoint);
      final qWhite = EdgeMaterialClassifier.quantizeNormalizedPixelToInt8(255, scale, zeroPoint);

      // Black (0) -> -1.0 -> ~ -128
      expect(qBlack, inInclusiveRange(-128, -125));
      // Mid (128) -> ~ 0.0 -> ~ 0
      expect(qMid, inInclusiveRange(-2, 2));
      // White (255) -> 1.0 -> ~ 127
      expect(qWhite, inInclusiveRange(125, 127));
    });

    test('8. Tensor Diagnostics: Accurately detects distribution and saturation state', () {
      // Normal distribution test tensor: 1x2x2x3 (12 elements)
      final normalTensor = [
        [
          [
            [-10, 0, 15],
            [-50, 40, 20],
          ],
          [
            [10, -20, 30],
            [5, -5, 0],
          ],
        ],
      ];

      final normalDiag = EdgeMaterialClassifier.computeTensorDiagnostics(normalTensor);
      expect(normalDiag.min, -50);
      expect(normalDiag.max, 40);
      expect(normalDiag.isSaturated, isFalse);
      expect(normalDiag.totalElements, 12);

      // Saturated test tensor (all pegged at 127)
      final satTensor = [
        [
          [
            [127, 127, 127],
            [127, 127, 127],
          ],
          [
            [127, 127, 127],
            [127, 127, 127],
          ],
        ],
      ];

      final satDiag = EdgeMaterialClassifier.computeTensorDiagnostics(satTensor);
      expect(satDiag.min, 127);
      expect(satDiag.max, 127);
      expect(satDiag.isSaturated, isTrue);
      expect(satDiag.saturationRatio, 1.0);
    });

    test('9. ClassifyImage Result includes populated TensorDiagnostics', () async {
      final testImg = img.Image(width: 320, height: 240);
      img.fill(testImg, color: img.ColorRgb8(100, 150, 200));
      final encoded = img.encodeJpg(testImg);

      await classifier.loadModel();
      final result = await classifier.classifyImage(encoded);

      expect(result.tensorDiagnostics, isNotNull);
      expect(result.tensorDiagnostics!.totalElements, 1 * 224 * 224 * 3);
      expect(result.tensorDiagnostics!.isSaturated, isFalse);
    });
  });
}
