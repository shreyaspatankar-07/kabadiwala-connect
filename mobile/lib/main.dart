import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/audio_service.dart';
import 'core/auth/session_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local_database.dart';
import 'l10n/app_localizations.dart';
import 'ui/screens/language_selection_screen.dart';
import 'ui/screens/pin_login_screen.dart';

// Riverpod provider for active application locale (Marathi by default)
final appLocaleProvider = StateProvider<Locale>((ref) => const Locale('mr'));

// Riverpod provider for singleton persistent SQLite database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

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

class KabadiwalaCollectorApp extends ConsumerStatefulWidget {
  const KabadiwalaCollectorApp({super.key});

  @override
  ConsumerState<KabadiwalaCollectorApp> createState() => _KabadiwalaCollectorAppState();
}

class _KabadiwalaCollectorAppState extends ConsumerState<KabadiwalaCollectorApp> {
  CollectorProfileData? _existingProfile;
  bool _isCheckingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    // 1. Fast cold-start check via SharedPreferences
    String? cachedLocale;
    String? cachedCollectorId;
    bool hasPrefSession = false;
    try {
      hasPrefSession = await SessionService.isLoggedIn();
      cachedLocale = await SessionService.getPreferredLocale();
      cachedCollectorId = await SessionService.getCollectorId();
      if (hasPrefSession && cachedLocale != null && mounted) {
        ref.read(appLocaleProvider.notifier).state = Locale(cachedLocale);
        ref.read(audioServiceProvider).setLocale(cachedLocale);
      }
    } catch (_) {}

    // 2. Load relational profile from SQLite
    final db = ref.read(databaseProvider);
    try {
      final profiles = await db.select(db.collectorProfile).get();
      if (profiles.isNotEmpty) {
        final profile = profiles.first;
        if (mounted) {
          setState(() {
            _existingProfile = profile;
            _isCheckingProfile = false;
          });
          ref.read(appLocaleProvider.notifier).state = Locale(profile.preferredLanguage);
          ref.read(audioServiceProvider).setLocale(profile.preferredLanguage);
        }
        return;
      } else if (hasPrefSession && cachedCollectorId != null) {
        final profile = CollectorProfileData(
          collectorId: cachedCollectorId,
          preferredLanguage: cachedLocale ?? 'mr',
          operatingArea: 'Palghar',
          quickPinHash: null,
          createdAt: DateTime.now(),
        );
        if (mounted) {
          setState(() {
            _existingProfile = profile;
            _isCheckingProfile = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('[Main] Error reading collector profile: $e');
    }

    if (mounted) {
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(appLocaleProvider);
    final audioService = ref.watch(audioServiceProvider);
    final db = ref.watch(databaseProvider);

    final appTitle = activeLocale.languageCode == 'en'
        ? 'Kabadiwala Connect'
        : 'कबाडीवाला कनेक्ट';

    Widget homeWidget;
    if (_isCheckingProfile) {
      homeWidget = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.greenGoEarn),
        ),
      );
    } else if (_existingProfile != null) {
      homeWidget = PinLoginScreen(
        db: db,
        audioService: audioService,
        profile: _existingProfile!,
        initialLocale: activeLocale.languageCode,
      );
    } else {
      homeWidget = LanguageSelectionScreen(
        db: db,
        audioService: audioService,
        onLanguageSelected: (newLocale) {
          ref.read(appLocaleProvider.notifier).state = Locale(newLocale);
          audioService.setLocale(newLocale);
        },
      );
    }

    return MaterialApp(
      title: appTitle,
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
      home: homeWidget,
    );
  }
}
