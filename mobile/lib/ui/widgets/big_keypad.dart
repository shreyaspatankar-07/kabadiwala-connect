import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Big-key numeric keypad specifically designed for low-literacy users.
/// Keys have large touch targets (min 72dp height), high contrast digits,
/// and clear tactile haptic feedback.
class BigKeypad extends StatelessWidget {
  const BigKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onSubmitPressed,
    this.showSubmit = true,
    this.showDecimal = true,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onSubmitPressed;
  final bool showSubmit;
  final bool showDecimal;

  Widget _buildKey(
    BuildContext context, {
    Key? key,
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          key: key,
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticService.lightImpact();
              onTap();
            },
            child: Container(
              height: AppTheme.keypadButtonHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ?? AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitKey(BuildContext context, String digit) {
    return _buildKey(
      context,
      key: Key('keypad_$digit'),
      onTap: () => onDigitPressed(digit),
      child: Text(
        digit,
        key: Key('keypad_digit_$digit'),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppTheme.textHighContrast,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildDigitKey(context, '1'),
            _buildDigitKey(context, '2'),
            _buildDigitKey(context, '3'),
          ],
        ),
        Row(
          children: [
            _buildDigitKey(context, '4'),
            _buildDigitKey(context, '5'),
            _buildDigitKey(context, '6'),
          ],
        ),
        Row(
          children: [
            _buildDigitKey(context, '7'),
            _buildDigitKey(context, '8'),
            _buildDigitKey(context, '9'),
          ],
        ),
        Row(
          children: [
            // Backspace / Clear
            _buildKey(
              context,
              backgroundColor: AppTheme.dangerRedLight,
              borderColor: AppTheme.dangerRed.withValues(alpha: 0.4),
              onTap: onBackspacePressed,
              child: const Icon(
                Icons.backspace_rounded,
                size: 32,
                color: AppTheme.dangerRed,
              ),
            ),
            // Digit 0
            _buildDigitKey(context, '0'),
            // Decimal point or Submit / Check
            if (showSubmit)
              _buildKey(
                context,
                backgroundColor: AppTheme.greenGoEarnLight,
                borderColor: AppTheme.greenGoEarn.withValues(alpha: 0.5),
                onTap: onSubmitPressed,
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: AppTheme.greenGoEarn,
                ),
              )
            else if (showDecimal)
              _buildKey(
                context,
                backgroundColor: Colors.white,
                borderColor: AppTheme.borderColor,
                onTap: () => onDigitPressed('.'),
                child: const Text(
                  '•',
                  key: Key('keypad_digit_dot'),
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textHighContrast,
                  ),
                ),
              )
            else
              _buildKey(
                context,
                backgroundColor: Colors.grey.shade100,
                borderColor: Colors.grey.shade300,
                onTap: onSubmitPressed,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
