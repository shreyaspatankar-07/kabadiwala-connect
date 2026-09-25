import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/ui/screens/pin_setup_screen.dart';
import 'package:kabadiwala_mobile/ui/widgets/big_keypad.dart';
import 'package:kabadiwala_mobile/ui/widgets/speaker_button.dart';

void main() {
  group('PIN Setup Screen Widget Tests', () {
    late AudioFeedbackService audioService;

    setUp(() {
      audioService = AudioFeedbackService(enableAudio: false);
    });

    testWidgets('Renders single-field PIN entry with BigKeypad and SpeakerButton',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PinSetupScreen(
            audioService: audioService,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Speaker button is present
      expect(find.byType(SpeakerButton), findsOneWidget);

      // Verify title is Marathi and single instruction
      expect(find.text('४ अंकी पिन टाका'), findsOneWidget);

      // Verify BigKeypad is present with digits
      expect(find.byType(BigKeypad), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_rounded), findsOneWidget);
    });

    testWidgets('Entering 4 digits moves to confirmation step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PinSetupScreen(
            audioService: audioService,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Now should ask for confirmation
      expect(find.text('तोच पिन पुन्हा टाका'), findsOneWidget);
    });

    testWidgets('Mismatching confirmation shows error and resets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PinSetupScreen(
            audioService: audioService,
            locale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial PIN: 1, 2, 3, 4
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.text(d));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Confirmation PIN: 1, 2, 3, 5 (different!)
      for (final d in ['1', '2', '3', '5']) {
        await tester.tap(find.text(d));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Verify error prompt appears
      expect(find.text('दोन्ही पिन जुळत नाहीत'), findsOneWidget);
    });
  });
}
