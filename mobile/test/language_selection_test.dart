import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/ui/screens/language_selection_screen.dart';
import 'package:kabadiwala_mobile/ui/widgets/speaker_button.dart';

void main() {
  group('Language Selection Screen Widget Tests', () {
    late AudioFeedbackService audioService;

    setUp(() {
      audioService = AudioFeedbackService(enableAudio: false);
    });

    testWidgets('Renders all language big tiles and persistent speaker button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LanguageSelectionScreen(
            audioService: audioService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify persistent speaker button is present in AppBar
      expect(find.byType(SpeakerButton), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

      // Verify Big Tiles for Marathi, Hindi, and English
      expect(find.text('मराठी'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Check Marathi subtitle
      expect(find.text('महाराष्ट्र (Default)'), findsOneWidget);
    });

    testWidgets('Tapping speaker button triggers audio feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LanguageSelectionScreen(
            audioService: audioService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap speaker button
      await tester.tap(find.byType(SpeakerButton));
      await tester.pumpAndSettle();

      // Verify audio service registered speech
      expect(audioService.lastSpokenText, isNotNull);
      expect(audioService.lastSpokenText, contains('भाषा निवडा'));
    });

    testWidgets('Selecting language updates locale callback',
        (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LanguageSelectionScreen(
            audioService: audioService,
            onLanguageSelected: (loc) => selected = loc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Hindi tile
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();

      expect(selected, equals('hi'));
      expect(audioService.currentLocale, equals('hi'));
    });
  });
}
