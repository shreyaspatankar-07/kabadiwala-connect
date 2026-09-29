import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/safety_repository.dart';
import '../widgets/speaker_button.dart';

/// Full illustrated detail screen for a Safety Guidance Card.
class SafetyCardDetailScreen extends StatefulWidget {
  final SafetyCard card;
  final String locale;
  final VoidCallback? onAcknowledged;

  const SafetyCardDetailScreen({
    super.key,
    required this.card,
    this.locale = 'mr',
    this.onAcknowledged,
  });

  @override
  State<SafetyCardDetailScreen> createState() => _SafetyCardDetailScreenState();
}

class _SafetyCardDetailScreenState extends State<SafetyCardDetailScreen> {
  late bool _isAcknowledged;

  @override
  void initState() {
    super.initState();
    _isAcknowledged = widget.card.isAcknowledged;

    // Autoplay spoken safety audio guidance on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playVoiceNarration();
    });
  }

  void _playVoiceNarration() {
    final prefix = widget.locale == 'mr'
        ? 'सुरक्षा इशारा: '
        : (widget.locale == 'hi' ? 'सुरक्षा चेतावनी: ' : 'Safety Alert: ');
    AudioFeedbackService().speak('$prefix${widget.card.title}. ${widget.card.summary}');
  }

  Color get _hazardColor {
    switch (widget.card.hazardLevel) {
      case 'danger':
        return AppTheme.dangerRed;
      case 'warning':
        return const Color(0xFFD97706); // Amber
      case 'info':
      default:
        return const Color(0xFF2563EB); // Blue
    }
  }

  Color get _hazardBgColor {
    switch (widget.card.hazardLevel) {
      case 'danger':
        return AppTheme.dangerRedLight;
      case 'warning':
        return AppTheme.yellowPendingLight;
      case 'info':
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData get _hazardIcon {
    switch (widget.card.topicId) {
      case 'cables_burn':
        return Icons.local_fire_department_rounded;
      case 'crt_monitor':
        return Icons.tv_off_rounded;
      case 'battery_crush':
        return Icons.battery_alert_rounded;
      case 'pcb_acid':
        return Icons.science_rounded;
      case 'safe_storage':
        return Icons.warehouse_rounded;
      case 'battery_smoke':
        return Icons.warning_rounded;
      case 'ppe_gloves':
        return Icons.health_and_safety_rounded;
      case 'first_aid':
        return Icons.medical_services_rounded;
      case 'burnt_condition':
        return Icons.fire_extinguisher_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    final dosLabel = isMr ? 'काय करावे (योग्य पद्धत)' : (isHi ? 'क्या करें (सही तरीका)' : 'DOs (Recommended)');
    final dontsLabel = isMr ? 'काय करू नये (धोकादायक)' : (isHi ? 'क्या न करें (खतरनाक)' : 'DONTs (Hazardous)');
    final instructionsLabel = isMr ? 'सुरक्षित पायऱ्या' : (isHi ? 'सुरक्षित चरण' : 'Step-by-Step Guidance');
    final understoodLabel = isMr ? 'मला नियम समजला' : (isHi ? 'मुझे नियम समझ आ गया' : 'I Understood');
    final acknowledgedLabel = isMr ? 'नियम समजला आहे' : (isHi ? 'नियम स्वीकृत है' : 'Understood & Acknowledged');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.card.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textHighContrast,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          SpeakerButton(
            key: const Key('btn_replay_safety_audio'),
            onPressed: _playVoiceNarration,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Comic-Style Hazard Hero Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _hazardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _hazardColor.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _hazardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _hazardColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _hazardIcon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.card.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _hazardColor,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.card.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textHighContrast,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Step-by-Step Illustrated Instructions
              Text(
                instructionsLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHighContrast,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.card.instructions.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final text = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _hazardColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$idx',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _hazardColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textHighContrast,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // 3. Green DOs Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenGoEarnLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.greenGoEarn.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.greenGoEarn, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          dosLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.greenGoEarn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...widget.card.dos.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("  ✔  ", style: TextStyle(color: AppTheme.greenGoEarn, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textHighContrast,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Red DONTs Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRedLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppTheme.dangerRed, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          dontsLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.dangerRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...widget.card.donts.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("  ✖  ", style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textHighContrast,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. "I Understood" Action Button (Min 56dp Touch Target)
              SizedBox(
                key: const Key('btn_understood'),
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('btn_i_understood'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAcknowledged ? Colors.grey.shade700 : AppTheme.greenGoEarn,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  icon: Icon(
                    _isAcknowledged ? Icons.check_circle_rounded : Icons.thumb_up_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _isAcknowledged ? acknowledgedLabel : understoodLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await SafetyRepository().acknowledgeCard(widget.card.topicId);
                    if (!mounted) return;
                    setState(() {
                      _isAcknowledged = true;
                    });
                    final msg = isMr
                        ? 'नियम समजला आहे'
                        : (isHi ? 'नियम स्वीकृत हो गया' : 'Safety rule understood');
                    unawaited(AudioFeedbackService().speak(msg));
                    widget.onAcknowledged?.call();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: AppTheme.greenGoEarn,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });
                  },
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
