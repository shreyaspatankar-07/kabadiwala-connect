import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/ml/material_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Material Classifier Unit & Threshold Tests', () {
    late MaterialClassifier classifier;

    setUp(() {
      classifier = MaterialClassifier();
    });

    test('1. Categories catalog contains 8 distinct standard categories', () {
      expect(MaterialClassifier.categories.length, 8);
      final ids = MaterialClassifier.categories.map((c) => c['id']).toList();
      expect(ids, containsAll([
        'PCB',
        'Cables',
        'Batteries',
        'LCD',
        'Motors_Magnets',
        'CRT',
        'Mixed_Plastics',
        'Other',
      ]));
    });

    test('2. Predict top 3 returns 3 ranked categories with valid probabilities', () async {
      await classifier.initialize();
      final predictions = await classifier.predictTop3(
        hintCategory: 'PCB',
      );

      expect(predictions.length, 3);
      expect(predictions.first.categoryId, 'PCB');
      expect(predictions.first.confidence, greaterThanOrEqualTo(0.55));
      expect(predictions.first.isConfident, isTrue);

      final totalConf = predictions.fold<double>(0.0, (sum, p) => sum + p.confidence);
      expect(totalConf, closeTo(1.0, 0.05));
    });

    test('3. Confidence below 0.55 threshold flags requiresManualSelection = true', () async {
      final lowConfOutput = await classifier.classify(
        hintCategory: 'CRT',
        forceTopConfidence: 0.42, // Below 0.55 threshold
      );

      expect(lowConfOutput.requiresManualSelection, isTrue);
      expect(lowConfOutput.topCategory, isNull);
      expect(MaterialClassifier.requiresManualSelection(lowConfOutput.predictions), isTrue);
    });

    test('4. Confidence at or above 0.55 threshold accepts top category', () async {
      final highConfOutput = await classifier.classify(
        hintCategory: 'Batteries',
        forceTopConfidence: 0.88, // Above 0.55 threshold
      );

      expect(highConfOutput.requiresManualSelection, isFalse);
      expect(highConfOutput.topCategory, isNotNull);
      expect(highConfOutput.topCategory!.categoryId, 'Batteries');
      expect(highConfOutput.topCategory!.confidence, 0.88);
      expect(MaterialClassifier.requiresManualSelection(highConfOutput.predictions), isFalse);
    });

    test('5. Image bytes trigger deterministic categorization', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final output = await classifier.classify(imageBytes: dummyBytes);

      expect(output.predictions.length, 3);
      expect(output.predictions.first.confidence, greaterThan(0.0));
    });
  });
}
