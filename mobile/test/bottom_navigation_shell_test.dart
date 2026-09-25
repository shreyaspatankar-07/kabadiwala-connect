import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/core/theme/app_theme.dart';
import 'package:kabadiwala_mobile/ui/screens/main_navigation_shell.dart';
import 'package:kabadiwala_mobile/ui/widgets/speaker_button.dart';
import 'package:kabadiwala_mobile/ui/widgets/sync_status_badge.dart';

void main() {
  group('Main Navigation Shell Widget Tests', () {
    late AudioFeedbackService audioService;

    setUp(() {
      audioService = AudioFeedbackService(enableAudio: false);
    });

    testWidgets('Renders all 4 icon tabs, speaker button, and sync badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MainNavigationShell(
            audioService: audioService,
            initialLocale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify persistent speaker button
      expect(find.byType(SpeakerButton), findsOneWidget);

      // Verify sync badge
      expect(find.byType(SyncStatusBadge), findsOneWidget);

      // Verify 4 tabs are present in bottom bar
      expect(find.text('माल जोडा'), findsNWidgets(2)); // AppBar title + BottomNav item
      expect(find.text('दर फलक'), findsOneWidget);
      expect(find.text('कमाई'), findsOneWidget);
      expect(find.text('सुरक्षा'), findsOneWidget);

      // Verify Initial Tab (Add Lot) contents
      expect(find.text('मालाचा फोटो काढा'), findsOneWidget);
      expect(find.text('माल सुरक्षित जतन करा'), findsOneWidget);
    });

    testWidgets('Switching to Price Board tab displays market prices',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MainNavigationShell(
            audioService: audioService,
            initialLocale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'दर फलक' tab
      await tester.tap(find.text('दर फलक'));
      await tester.pumpAndSettle();

      // Verify price board items appear
      expect(find.text('तांब्याची वायर (Cables)'), findsOneWidget);
      expect(find.text('₹ 680 / kg'), findsOneWidget);
      expect(find.text('सर्किट बोर्ड (PCB)'), findsOneWidget);
    });

    testWidgets('Switching to Earnings tab displays cash balance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MainNavigationShell(
            audioService: audioService,
            initialLocale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'कमाई' tab
      await tester.tap(find.text('कमाई'));
      await tester.pumpAndSettle();

      // Verify real earnings overview screen elements
      expect(find.byKey(const Key('tile_today')), findsOneWidget);
      expect(find.byKey(const Key('tile_week')), findsOneWidget);
      expect(find.byKey(const Key('tile_month')), findsOneWidget);
      expect(find.byKey(const Key('earnings_split_bar')), findsOneWidget);
      expect(find.byKey(const Key('export_pdf_button')), findsOneWidget);
    });

    testWidgets('Switching to Safety tab displays pictorial hazard cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MainNavigationShell(
            audioService: audioService,
            initialLocale: 'mr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'सुरक्षा' tab
      await tester.tap(find.text('सुरक्षा'));
      await tester.pumpAndSettle();

      // Verify hazard warnings
      expect(find.text('तांब्यासाठी केबल कधीही जाळू नका'), findsOneWidget);
      expect(find.text('CRT मॉनिटर किंवा टीव्ही कधीही फोडू नका'), findsOneWidget);
      expect(find.text('लिथियम बॅटरी कधीही कापू किंवा चेपू नका'), findsOneWidget);
    });
  });
}
