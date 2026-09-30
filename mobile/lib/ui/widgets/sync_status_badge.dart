import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import 'system_status_dialog.dart';

/// Visual status badge showing online/offline connectivity and sync queue state.
/// Pictorial cues (Cloud with check or sync arrow) ensure zero-literacy comprehension.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.isOnline,
    required this.pendingCount,
    this.locale = 'mr',
    this.audioService,
    this.onTapSync,
  });

  final bool isOnline;
  final int pendingCount;
  final String locale;
  final AudioFeedbackService? audioService;
  final Future<void> Function()? onTapSync;

  void _handleTap(BuildContext context) async {
    await HapticService.selectionClick();
    if (context.mounted) {
      await SystemStatusDialog.show(
        context,
        isOnline: isOnline,
        pendingCount: pendingCount,
        locale: locale,
        audioService: audioService,
        onTriggerSync: onTapSync,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPending = pendingCount > 0;
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    final Color badgeColor = !isOnline
        ? AppTheme.yellowPending
        : (hasPending ? const Color(0xFF0284C7) : AppTheme.greenGoEarn);

    final Color badgeBackground = !isOnline
        ? AppTheme.yellowPendingLight
        : (hasPending ? const Color(0xFFE0F2FE) : AppTheme.greenGoEarnLight);

    final IconData icon = !isOnline
        ? Icons.cloud_off_rounded
        : (hasPending ? Icons.sync_rounded : Icons.cloud_done_rounded);

    final String statusText = !isOnline
        ? (isMr
            ? 'ऑफलाइन मोड - $pendingCount व्यवहार फोनमध्ये सुरक्षित'
            : (isHi
                ? 'ऑफलाइन मोड - $pendingCount लेन-देन फोन में सुरक्षित'
                : 'Offline Mode - $pendingCount records saved'))
        : (hasPending
            ? (isMr
                ? '$pendingCount व्यवहार सिंक होत आहेत...'
                : (isHi
                    ? '$pendingCount लेन-देन सिंक हो रहे हैं...'
                    : 'Syncing $pendingCount records...'))
            : (isMr
                ? 'ऑनलाइन - सरकारी JNARDDC सर्व्हरशी जोडले आहे'
                : (isHi
                    ? 'ऑनलाइन - सरकारी JNARDDC सर्वर से कनेक्टेड'
                    : 'Online - Connected to JNARDDC Server')));

    return Semantics(
      button: true,
      label: statusText,
      child: Material(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: const Key('badge_sync_status'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleTap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                // Pulsing dot indicator
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.greenGoEarn : AppTheme.yellowPending,
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(icon, size: 24, color: badgeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: badgeColor.withValues(alpha: 0.95),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMr ? 'तपासा' : (isHi ? 'देखें' : 'Status'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: badgeColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 16, color: badgeColor),
                    ],
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
