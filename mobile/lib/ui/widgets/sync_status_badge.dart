import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Visual status badge showing online/offline connectivity and sync queue state.
/// Pictorial cues (Cloud with check or sync arrow) ensure zero-literacy comprehension.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.isOnline,
    required this.pendingCount,
    this.onTapSync,
  });

  final bool isOnline;
  final int pendingCount;
  final VoidCallback? onTapSync;

  @override
  Widget build(BuildContext context) {
    final bool hasPending = pendingCount > 0;
    final Color badgeColor = !isOnline || hasPending
        ? AppTheme.yellowPending
        : AppTheme.greenGoEarn;
    final Color badgeBackground = !isOnline || hasPending
        ? AppTheme.yellowPendingLight
        : AppTheme.greenGoEarnLight;

    final IconData icon = !isOnline
        ? Icons.cloud_off_rounded
        : (hasPending ? Icons.sync_problem_rounded : Icons.cloud_done_rounded);

    final String statusText = !isOnline
        ? 'ऑफलाइन - $pendingCount व्यवहार सुरक्षित'
        : (hasPending
            ? '$pendingCount व्यवहार सिंक होत आहेत...'
            : 'ऑनलाइन - सर्व डेटा सरकारी सर्व्हरवर सुरक्षित');

    return Semantics(
      button: onTapSync != null,
      label: statusText,
      child: Material(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapSync != null
              ? () async {
                  await HapticService.selectionClick();
                  onTapSync!();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(icon, size: 28, color: badgeColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: badgeColor.withValues(alpha: 0.95),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasPending && onTapSync != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
