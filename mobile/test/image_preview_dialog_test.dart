import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/hardware/image_processor.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/ui/widgets/camera_capture_card.dart';
import 'package:kabadiwala_mobile/ui/widgets/image_preview_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImagePreviewDialog & Photo Preview Feature Tests', () {
    testWidgets('1. ImagePreviewDialog renders header, interactive image, metadata, and closes',
        (WidgetTester tester) async {
      final dummyBytes = Uint8List.fromList(List.generate(1024 * 40, (i) => (i % 256)));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('btn_open_preview'),
                onPressed: () {
                  ImagePreviewDialog.show(
                    context: context,
                    imageBytes: dummyBytes,
                    title: 'चाचणी फोटो',
                    sizeInKb: 40.0,
                    sha256Hash: 'a1b2c3d4e5f6789012345678',
                    latitude: 19.69,
                    longitude: 72.76,
                    locale: 'mr',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Tap open
      await tester.tap(find.byKey(const Key('btn_open_preview')));
      await tester.pumpAndSettle();

      // Dialog is displayed
      expect(find.byType(ImagePreviewDialog), findsOneWidget);
      expect(find.byKey(const Key('dialog_image_preview')), findsOneWidget);
      expect(find.text('चाचणी फोटो'), findsOneWidget);
      expect(find.textContaining('40.0 KB'), findsWidgets);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Close button is present (56dp min touch target)
      expect(find.byKey(const Key('btn_close_image_preview')), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_close_image_preview')));
      await tester.pumpAndSettle();

      // Dialog closed
      expect(find.byType(ImagePreviewDialog), findsNothing);
    });

    testWidgets('2. CameraCaptureCard: Clicking photo card or image icon opens ImagePreviewDialog',
        (WidgetTester tester) async {
      final mockPhoto = ImageProcessor.createMockPhoto(
        photoId: 'TEST_PHOTO_1',
        latitude: 19.0760,
        longitude: 72.8777,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CameraCaptureCard(
              photos: [mockPhoto],
              onCapturePhoto: () {},
              onRemovePhoto: (_) {},
              locale: 'mr',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Photo thumbnail is displayed
      expect(find.byKey(const Key('btn_preview_photo_0')), findsOneWidget);
      expect(find.byIcon(Icons.zoom_in_rounded), findsOneWidget);

      // Tap the photo preview icon / card
      await tester.tap(find.byKey(const Key('btn_preview_photo_0')));
      await tester.pumpAndSettle();

      // Verify ImagePreviewDialog is opened
      expect(find.byType(ImagePreviewDialog), findsOneWidget);
      expect(find.text('फोटो #1 पूर्वावलोकन'), findsOneWidget);

      // Close dialog via icon button
      await tester.tap(find.byKey(const Key('btn_close_image_preview_icon')));
      await tester.pumpAndSettle();
      expect(find.byType(ImagePreviewDialog), findsNothing);
    });
  });
}
