import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Persistent speaker button on every screen for low-literacy audio guidance.
/// Guaranteed >= 56dp touch target with high contrast and haptic feedback.
class SpeakerButton extends StatefulWidget {
  const SpeakerButton({
    super.key,
    required this.promptKey,
    required this.audioService,
    this.size = AppTheme.minTouchTargetSize,
    this.iconSize = AppTheme.iconSizeMedium,
    this.color = AppTheme.greenGoEarn,
    this.tooltip = 'ऐका (Listen)',
  });

  final String promptKey;
  final AudioFeedbackService audioService;
  final double size;
  final double iconSize;
  final Color color;
  final String tooltip;

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.85,
      upperBound: 1.15,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await HapticService.mediumImpact();
    unawaited(_animController.forward().then((_) => _animController.reverse()));
    await widget.audioService.speakPrompt(widget.promptKey);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.size / 2),
          onTap: _handleTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.12),
              border: Border.all(color: widget.color.withValues(alpha: 0.4), width: 2),
            ),
            child: ScaleTransition(
              scale: _animController,
              child: Icon(
                Icons.volume_up_rounded,
                size: widget.iconSize,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
