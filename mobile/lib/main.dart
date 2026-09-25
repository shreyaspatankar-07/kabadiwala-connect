import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'ui/screens/language_selection_screen.dart';

// Riverpod provider for active application locale (Marathi by default)
final appLocaleProvider = StateProvider<Locale>((ref) => const Locale('mr'));

// Riverpod provider for audio feedback service
final audioServiceProvider = Provider<AudioFeedbackService>((ref) {
  final service = AudioFeedbackService();
  ref.onDispose(() => service.dispose());
  return service;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: KabadiwalaCollectorApp(),
    ),
  );
}

class KabadiwalaCollectorApp extends ConsumerWidget {
  const KabadiwalaCollectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(appLocaleProvider);
    final audioService = ref.watch(audioServiceProvider);

    return MaterialApp(
      title: 'कबाडीवाला कनेक्ट',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: activeLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('mr'), // Marathi (Default)
        Locale('hi'), // Hindi
        Locale('en'), // English (Optional)
      ],
      home: LanguageSelectionScreen(
        audioService: audioService,
        onLanguageSelected: (newLocale) {
          ref.read(appLocaleProvider.notifier).state = Locale(newLocale);
          audioService.setLocale(newLocale);
        },
      ),
    );
  }
}
