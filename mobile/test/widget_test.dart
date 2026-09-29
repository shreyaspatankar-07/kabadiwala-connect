import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/audio/audio_service.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/main.dart';
import 'package:kabadiwala_mobile/ui/widgets/speaker_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App root initializes in Marathi with speaker button and language tiles',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.inMemory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioServiceProvider.overrideWithValue(
            AudioFeedbackService(enableAudio: false),
          ),
        ],
        child: const KabadiwalaCollectorApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Marathi App Title
    expect(find.text('कबाडीवाला कनेक्ट'), findsOneWidget);

    // Verify Speaker Button
    expect(find.byType(SpeakerButton), findsOneWidget);

    // Verify Language selection choices
    expect(find.text('मराठी'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
