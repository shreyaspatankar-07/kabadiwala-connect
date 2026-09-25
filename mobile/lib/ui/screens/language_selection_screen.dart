import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/big_tile.dart';
import '../widgets/speaker_button.dart';
import 'pin_setup_screen.dart';

/// First-run Onboarding: Language Selection Screen.
/// Auto-plays audio prompt in vernacular on load.
/// Displays large, high-contrast tiles for Marathi, Hindi, and English.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({
    super.key,
    required this.audioService,
    this.onLanguageSelected,
  });

  final AudioFeedbackService audioService;
  final ValueChanged<String>? onLanguageSelected;

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLocale = 'mr'; // Marathi default per AGENTS.md

  @override
  void initState() {
    super.initState();
    // Auto-play spoken prompt on initial screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioService.speakPrompt('languagePrompt', localeOverride: 'mr');
    });
  }

  void _chooseLanguage(String locale) {
    setState(() {
      _selectedLocale = locale;
    });
    widget.audioService.setLocale(locale);
    widget.audioService.speakPrompt('languagePrompt', localeOverride: locale);
    widget.onLanguageSelected?.call(locale);

    // Proceed to PIN setup screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          audioService: widget.audioService,
          locale: locale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'कबाडीवाला कनेक्ट',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          SpeakerButton(
            promptKey: 'languagePrompt',
            audioService: widget.audioService,
            tooltip: 'भाषा निवडण्यासाठी सूचना ऐका',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual header banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.greenGoEarnLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.greenGoEarn.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 32,
                      color: AppTheme.greenGoEarn,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'आपली भाषा निवडा\nअपनी भाषा चुनें\nChoose Language',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.greenGoEarn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Marathi Big Tile (Default, recommended)
              BigTile(
                title: 'मराठी',
                subtitle: 'महाराष्ट्र (Default)',
                icon: Icons.record_voice_over_rounded,
                isSelected: _selectedLocale == 'mr',
                primaryColor: AppTheme.greenGoEarn,
                minHeight: 88,
                onTap: () => _chooseLanguage('mr'),
              ),
              const SizedBox(height: 14),

              // Hindi Big Tile
              BigTile(
                title: 'हिंदी',
                subtitle: 'भारत',
                icon: Icons.chat_rounded,
                isSelected: _selectedLocale == 'hi',
                primaryColor: const Color(0xFF0284C7),
                minHeight: 88,
                onTap: () => _chooseLanguage('hi'),
              ),
              const SizedBox(height: 14),

              // English Big Tile
              BigTile(
                title: 'English',
                subtitle: 'Optional',
                icon: Icons.language_rounded,
                isSelected: _selectedLocale == 'en',
                primaryColor: const Color(0xFF64748B),
                minHeight: 88,
                onTap: () => _chooseLanguage('en'),
              ),

              const SizedBox(height: 24),

              // Pictorial reminder
              Center(
                child: Text(
                  'स्पीकर बटण दाबून सूचना ऐका 🔊',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
