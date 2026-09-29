import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../widgets/big_keypad.dart';
import '../widgets/speaker_button.dart';
import 'main_navigation_shell.dart';
import 'pin_setup_screen.dart';

/// Returning User PIN Login Screen:
/// - Fast 4-digit PIN unlock for informal collectors
/// - Zero PII displayed (only collector ID e.g. KC-C-7821)
/// - Multilingual: switch language on the fly (MR, HI, EN)
/// - Big keypad with 72dp high touch targets
/// - Persistent audio speaker prompt on top right
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({
    super.key,
    required this.db,
    required this.audioService,
    required this.profile,
    this.initialLocale,
  });

  final AppDatabase db;
  final AudioFeedbackService audioService;
  final CollectorProfileData profile;
  final String? initialLocale;

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  late String _currentLocale;
  String _enteredPin = '';
  String? _errorMessage;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.initialLocale ?? widget.profile.preferredLanguage;
    widget.audioService.setLocale(_currentLocale);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playLoginPrompt();
    });
  }

  void _playLoginPrompt() {
    final text = _currentLocale == 'mr'
        ? 'कृपया आपला ४-अंकी गुप्त पिन टाका.'
        : (_currentLocale == 'hi'
            ? 'कृपया अपना ४-अंकों का गुप्त पिन दर्ज करें.'
            : 'Please enter your 4-digit security PIN to unlock.');
    unawaited(widget.audioService.speakCustomText(text));
  }

  void _switchLanguage(String newLocale) {
    HapticService.selectionClick();
    setState(() {
      _currentLocale = newLocale;
      _errorMessage = null;
    });
    widget.audioService.setLocale(newLocale);
    _playLoginPrompt();

    // Persist language preference
    widget.db.update(widget.db.collectorProfile)
      ..where((p) => p.collectorId.equals(widget.profile.collectorId))
      ..write(CollectorProfileCompanion(
        preferredLanguage: drift.Value(newLocale),
      ));
  }

  void _onDigitPressed(String digit) {
    if (_isAuthenticating) return;
    HapticService.lightImpact();

    setState(() {
      _errorMessage = null;
      if (_enteredPin.length < 4) {
        _enteredPin += digit;
        if (_enteredPin.length == 4) {
          _verifyPin(_enteredPin);
        }
      }
    });
  }

  void _onBackspacePressed() {
    if (_isAuthenticating) return;
    HapticService.lightImpact();

    setState(() {
      _errorMessage = null;
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  Future<void> _verifyPin(String pin) async {
    setState(() {
      _isAuthenticating = true;
    });

    final enteredHash = sha256.convert(utf8.encode(pin)).toString();
    final storedHash = widget.profile.quickPinHash;

    // If stored hash matches or if bypass/default
    final isMatch = storedHash == null || storedHash.isEmpty || storedHash == enteredHash;

    if (isMatch) {
      await HapticService.heavyImpact();
      final successMsg = _currentLocale == 'mr'
          ? 'स्वागत आहे! पिन अचूक आहे.'
          : (_currentLocale == 'hi'
              ? 'स्वागत है! पिन सही है.'
              : 'Welcome! PIN verified successfully.');
      unawaited(widget.audioService.speakCustomText(successMsg));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainNavigationShell(
              db: widget.db,
              audioService: widget.audioService,
              initialLocale: _currentLocale,
            ),
          ),
          (route) => false,
        );
      }
    } else {
      await HapticService.errorAlert();
      final errorSpoken = _currentLocale == 'mr'
          ? 'चुकीचा पिन! कृपया पुन्हा प्रयत्न करा.'
          : (_currentLocale == 'hi'
              ? 'गलत पिन! कृपया पुनः प्रयास करें.'
              : 'Incorrect PIN! Please try again.');
      unawaited(widget.audioService.speakCustomText(errorSpoken));

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _enteredPin = '';
          _errorMessage = _currentLocale == 'mr'
              ? 'चुकीचा पिन! कृपया पुन्हा प्रयत्न करा.'
              : (_currentLocale == 'hi'
                  ? 'गलत पिन! कृपया पुनः प्रयास करें.'
                  : 'Incorrect PIN. Please try again.');
        });
      }
    }
  }

  void _resetPin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          db: widget.db,
          audioService: widget.audioService,
          locale: _currentLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMr = _currentLocale == 'mr';
    final isHi = _currentLocale == 'hi';

    final title = isMr ? 'कबाडीवाला कनेक्ट' : (isHi ? 'कबाडीवाला कनेक्ट' : 'Kabadiwala Connect');
    final enterPinText = isMr
        ? 'आपला ४-अंकी पिन टाका'
        : (isHi ? 'अपना ४-अंकीय पिन दर्ज करें' : 'Enter 4-Digit PIN');
    final collectorBadgeText = isMr
        ? 'नोंदणीकृत कबाडीवाला'
        : (isHi ? 'पंजीकृत कबाड़ीवाला' : 'Registered Collector');
    final resetPinText = isMr
        ? 'पिन विसरलात का? नवीन पिन बनवा'
        : (isHi ? 'पिन भूल गए? नया पिन बनाएं' : 'Forgot PIN? Reset PIN');

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          // Language Switcher Chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangButton('mr', 'मराठी'),
                const SizedBox(width: 4),
                _buildLangButton('hi', 'हिंदी'),
                const SizedBox(width: 4),
                _buildLangButton('en', 'EN'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SpeakerButton(
            promptKey: 'enterPinPrompt',
            audioService: widget.audioService,
            tooltip: isMr ? 'सूचना ऐका' : (isHi ? 'सूचना सुनें' : 'Listen Instructions'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Collector ID Badge (Data minimization)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.greenGoEarn.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppTheme.greenGoEarn, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$collectorBadgeText: ${widget.profile.collectorId}',
                            style: const TextStyle(
                              color: AppTheme.greenGoEarn,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Key icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.greenGoEarn, width: 2),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.greenGoEarn,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      enterPinText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textHighContrast,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4-Dot PIN Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final bool isFilled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? AppTheme.greenGoEarn : Colors.transparent,
                            border: Border.all(
                              color: _errorMessage != null
                                  ? AppTheme.dangerRed
                                  : (isFilled ? AppTheme.greenGoEarn : Colors.grey.shade400),
                              width: 2.5,
                            ),
                          ),
                        );
                      }),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.dangerRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resetPin,
                      child: Text(
                        resetPinText,
                        style: const TextStyle(
                          color: AppTheme.greenGoEarn,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Big Tactile Keypad
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: BigKeypad(
                onDigitPressed: _onDigitPressed,
                onBackspacePressed: _onBackspacePressed,
                onSubmitPressed: () {},
                showSubmit: false,
                showDecimal: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String localeCode, String label) {
    final isSelected = _currentLocale == localeCode;
    return InkWell(
      onTap: () => _switchLanguage(localeCode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.greenGoEarn : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
