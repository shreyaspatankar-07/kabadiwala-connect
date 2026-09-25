import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/big_keypad.dart';
import '../widgets/speaker_button.dart';
import 'main_navigation_shell.dart';

enum PinStep { enterInitial, confirmPin, phoneOptional }

/// PIN Setup Screen following low-literacy principles:
/// - Max 1 field per screen.
/// - Big keypad with 72dp high touch targets.
/// - Persistent speaker button on top right.
/// - Tactile haptic feedback and audio read-aloud.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({
    super.key,
    required this.audioService,
    required this.locale,
    this.onPinCompleted,
  });

  final AudioFeedbackService audioService;
  final String locale;
  final VoidCallback? onPinCompleted;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  PinStep _currentStep = PinStep.enterInitial;
  String _firstPin = '';
  String _confirmPin = '';
  String _phoneNumber = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioService.speakPrompt('enterPinPrompt', localeOverride: widget.locale);
    });
  }

  void _onDigitPressed(String digit) {
    setState(() {
      _errorMessage = null;
      if (_currentStep == PinStep.enterInitial) {
        if (_firstPin.length < 4) {
          _firstPin += digit;
          if (_firstPin.length == 4) {
            // Move immediately to confirmation step (no complex forms)
            _currentStep = PinStep.confirmPin;
            widget.audioService.speakPrompt('confirmPinPrompt', localeOverride: widget.locale);
          }
        }
      } else if (_currentStep == PinStep.confirmPin) {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
          if (_confirmPin.length == 4) {
            _validatePins();
          }
        }
      } else if (_currentStep == PinStep.phoneOptional) {
        if (_phoneNumber.length < 10) {
          _phoneNumber += digit;
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      _errorMessage = null;
      if (_currentStep == PinStep.enterInitial) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else if (_currentStep == PinStep.confirmPin) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Go back to initial entry
          _currentStep = PinStep.enterInitial;
          _firstPin = '';
          widget.audioService.speakPrompt('enterPinPrompt', localeOverride: widget.locale);
        }
      } else if (_currentStep == PinStep.phoneOptional) {
        if (_phoneNumber.isNotEmpty) {
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
        }
      }
    });
  }

  void _validatePins() {
    if (_firstPin == _confirmPin) {
      HapticService.heavyImpact();
      widget.audioService.speakPrompt('pinSuccess', localeOverride: widget.locale);
      setState(() {
        _currentStep = PinStep.phoneOptional;
      });
    } else {
      HapticService.errorAlert();
      widget.audioService.speakPrompt('pinMismatch', localeOverride: widget.locale);
      setState(() {
        _errorMessage = widget.locale == 'mr'
            ? 'दोन्ही पिन जुळत नाहीत'
            : (widget.locale == 'hi' ? 'पिन मेल नहीं खा रहे' : 'PINs do not match');
        _firstPin = '';
        _confirmPin = '';
        _currentStep = PinStep.enterInitial;
      });
    }
  }

  void _finishSetup() {
    widget.onPinCompleted?.call();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigationShell(
          audioService: widget.audioService,
          initialLocale: widget.locale,
        ),
      ),
      (route) => false,
    );
  }

  Widget _buildPinDots(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFilled = index < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppTheme.greenGoEarn : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppTheme.greenGoEarn : AppTheme.borderColor,
              width: 3,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titleText;
    final String subtitleText;
    final String promptKey;

    if (_currentStep == PinStep.enterInitial) {
      promptKey = 'enterPinPrompt';
      titleText = widget.locale == 'mr'
          ? '४ अंकी पिन टाका'
          : (widget.locale == 'hi' ? '४ अंकों का पिन दर्ज करें' : 'Enter 4-digit PIN');
      subtitleText = widget.locale == 'mr'
          ? 'अ‍ॅप सुरक्षित ठेवण्यासाठी'
          : (widget.locale == 'hi' ? 'ऐप सुरक्षित रखने के लिए' : 'To keep your account secure');
    } else if (_currentStep == PinStep.confirmPin) {
      promptKey = 'confirmPinPrompt';
      titleText = widget.locale == 'mr'
          ? 'तोच पिन पुन्हा टाका'
          : (widget.locale == 'hi' ? 'वही पिन दोबारा दर्ज करें' : 'Confirm your PIN');
      subtitleText = widget.locale == 'mr'
          ? 'खात्री करा'
          : (widget.locale == 'hi' ? 'पुष्टि करें' : 'Verify matching PIN');
    } else {
      promptKey = 'pinSuccess';
      titleText = widget.locale == 'mr'
          ? 'मोबाईल नंबर (ऐच्छिक)'
          : (widget.locale == 'hi' ? 'मोबाइल नंबर (वैकल्पिक)' : 'Mobile Number (Optional)');
      subtitleText = widget.locale == 'mr'
          ? 'नाही टाकला तरी चालेल'
          : (widget.locale == 'hi' ? 'छोड़ भी सकते हैं' : 'Can skip this step');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.locale == 'mr' ? 'पिन सेटअप' : (widget.locale == 'hi' ? 'पिन सेटअप' : 'PIN Setup'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          SpeakerButton(
            promptKey: promptKey,
            audioService: widget.audioService,
            tooltip: 'सूचना ऐका',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title and single field
              const SizedBox(height: 12),
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textHighContrast,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Single visual input area
              if (_currentStep == PinStep.enterInitial)
                _buildPinDots(_firstPin)
              else if (_currentStep == PinStep.confirmPin)
                _buildPinDots(_confirmPin)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor, width: 2),
                  ),
                  child: Text(
                    _phoneNumber.isEmpty ? '१० अंकी मोबाईल नंबर' : _phoneNumber,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _phoneNumber.isEmpty ? AppTheme.textMuted : AppTheme.textHighContrast,
                      letterSpacing: 2,
                    ),
                  ),
                ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRedLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.dangerRed,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // For optional phone step, provide skip & continue buttons
              if (_currentStep == PinStep.phoneOptional) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _finishSetup,
                        child: Text(
                          widget.locale == 'mr' ? 'सोडून द्या (Skip)' : 'छोड़ें (Skip)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenGoEarn,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _finishSetup,
                        child: Text(
                          widget.locale == 'mr' ? 'सुरू करा' : (widget.locale == 'hi' ? 'शुरू करें' : 'Start'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Big Keypad
              BigKeypad(
                onDigitPressed: _onDigitPressed,
                onBackspacePressed: _onBackspacePressed,
                onSubmitPressed: () {
                  if (_currentStep == PinStep.phoneOptional) {
                    _finishSetup();
                  } else if (_currentStep == PinStep.confirmPin && _confirmPin.length == 4) {
                    _validatePins();
                  }
                },
                showSubmit: _currentStep == PinStep.phoneOptional ||
                    (_currentStep == PinStep.confirmPin && _confirmPin.length == 4),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
