import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Large interactive tile for low-literacy users.
/// Displays large pictograms + 1-2 word labels, >= 56dp touch targets,
/// high contrast outlines and tactile feedback.
class BigTile extends StatelessWidget {
  const BigTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.isSelected = false,
    this.primaryColor = AppTheme.greenGoEarn,
    this.minHeight = AppTheme.actionCardMinHeight,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color primaryColor;
  final double minHeight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: subtitle != null ? '$title, $subtitle' : title,
      child: Material(
        color: isSelected ? primaryColor.withValues(alpha: 0.12) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticService.mediumImpact();
            onTap();
          },
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryColor : AppTheme.borderColor,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: AppTheme.iconSizeMedium,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? primaryColor : AppTheme.textHighContrast,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (trailing == null && isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 32,
                    color: primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
