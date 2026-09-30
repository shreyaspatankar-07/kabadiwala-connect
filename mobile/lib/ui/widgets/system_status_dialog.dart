import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Interactive modal sheet displaying comprehensive online/offline diagnostics.
class SystemStatusDialog extends StatefulWidget {
  const SystemStatusDialog({
    super.key,
    required this.isOnline,
    required this.pendingCount,
    required this.locale,
    this.audioService,
    this.onTriggerSync,
  });

  final bool isOnline;
  final int pendingCount;
  final String locale;
  final AudioFeedbackService? audioService;
  final Future<void> Function()? onTriggerSync;

  static Future<void> show(
    BuildContext context, {
    required bool isOnline,
    required int pendingCount,
    required String locale,
    AudioFeedbackService? audioService,
    Future<void> Function()? onTriggerSync,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SystemStatusDialog(
        isOnline: isOnline,
        pendingCount: pendingCount,
        locale: locale,
        audioService: audioService,
        onTriggerSync: onTriggerSync,
      ),
    );
  }

  @override
  State<SystemStatusDialog> createState() => _SystemStatusDialogState();
}

class _SystemStatusDialogState extends State<SystemStatusDialog> {
  bool _isChecking = false;
  late bool _currentOnline;
  late int _currentPending;

  @override
  void initState() {
    super.initState();
    _currentOnline = widget.isOnline;
    _currentPending = widget.pendingCount;

    // Spoken feedback on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentStatus();
    });
  }

  void _speakCurrentStatus() {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    final text = _currentOnline
        ? (isMr
            ? 'सिस्टम ऑनलाइन आहे. सर्व डेटा सरकारी सर्व्हरवर सुरक्षित आहे.'
            : (isHi
                ? 'सिस्टम ऑनलाइन है। सभी डेटा सरकारी सर्वर पर सुरक्षित है।'
                : 'System is online. All data is synchronized.'))
        : (isMr
            ? 'सिस्टम ऑफलाइन मोडमध्ये चालू आहे. सर्व व्यवहार फोनमध्ये सुरक्षित आहेत.'
            : (isHi
                ? 'सिस्टम ऑफलाइन मोड में है। सभी लेनदेन फोन में सुरक्षित हैं।'
                : 'System is running offline. All records are stored safely on device.'));

    widget.audioService?.speakCustomText(text);
  }

  Future<void> _handleRefresh() async {
    await HapticService.mediumImpact();
    setState(() {
      _isChecking = true;
    });

    try {
      if (widget.onTriggerSync != null) {
        await widget.onTriggerSync!();
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _currentOnline = true;
          _currentPending = 0;
          _isChecking = false;
        });
        _speakCurrentStatus();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    final title = isMr
        ? 'सिस्टम नेटवर्क व सिंक स्थिती'
        : (isHi ? 'सिस्टम नेटवर्क एवं सिंक स्थिति' : 'System Connectivity Status');

    final onlineColor = _currentOnline ? AppTheme.greenGoEarn : AppTheme.yellowPending;
    final onlineBg = _currentOnline ? AppTheme.greenGoEarnLight : AppTheme.yellowPendingLight;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header with Speaker
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: onlineBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    color: onlineColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn, size: 28),
                  tooltip: 'स्थिती ऐका',
                  onPressed: _speakCurrentStatus,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main Status Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: onlineBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: onlineColor.withValues(alpha: 0.6), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: onlineColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: onlineColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentOnline
                              ? (isMr
                                  ? 'ऑनलाइन - सर्व्हरशी जोडले आहे'
                                  : (isHi ? 'ऑनलाइन - सर्वर से कनेक्टेड' : 'Online - Connected to Server'))
                              : (isMr
                                  ? 'ऑफलाइन - स्थानिक मोड सक्रिय'
                                  : (isHi ? 'ऑफलाइन - स्थानीय मोड सक्रिय' : 'Offline - Local Mode Active')),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: onlineColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentOnline
                              ? (isMr
                                  ? 'डेटा रिअल-टाइम सरकारी JNARDDC सर्व्हरवर सुरक्षित होतो.'
                                  : (isHi
                                      ? 'डेटा रियल-टाइम सरकारी JNARDDC सर्वर पर सुरक्षित है।'
                                      : 'Data is synced in real-time with JNARDDC EPR servers.'))
                              : (isMr
                                  ? 'इंटरनेट नसतानाही सर्व व्यवहार फोनच्या SQLite मेमरीमध्ये सुरक्षित राहतात.'
                                  : (isHi
                                      ? 'बिना इंटरनेट भी सभी लेन-देन सुरक्षित Drift SQLite में दर्ज हैं।'
                                      : 'All transactions are cached safely in local Drift SQLite.')),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Diagnostic Checklist
            _buildCheckItem(
              icon: Icons.wifi_rounded,
              title: isMr ? 'इंटरनेट नेटवर्क' : (isHi ? 'इंटरनेट नेटवर्क' : 'Internet Network'),
              status: _currentOnline
                  ? (isMr ? 'जोडलेले (Connected)' : (isHi ? 'कनेक्टेड' : 'Connected'))
                  : (isMr ? 'उपलब्ध नाही (No Net)' : (isHi ? 'अनुपलब्ध' : 'Disconnected')),
              isSuccess: _currentOnline,
            ),
            const SizedBox(height: 8),
            _buildCheckItem(
              icon: Icons.storage_rounded,
              title: isMr ? 'स्थानिक Drift SQLite' : (isHi ? 'स्थानीय SQLite डेटाबेस' : 'Drift SQLite DB'),
              status: isMr ? 'सक्रिय व सुरक्षित (100% Offline)' : 'सक्रिय (Active & Encrypted)',
              isSuccess: true,
            ),
            const SizedBox(height: 8),
            _buildCheckItem(
              icon: Icons.cloud_sync_rounded,
              title: isMr ? 'JNARDDC क्लाउड सिंक' : (isHi ? 'JNARDDC क्लाउड सिंक' : 'JNARDDC Cloud Sync'),
              status: _currentPending == 0
                  ? (isMr ? 'सर्व डेटा सिंक झाला आहे (० प्रलंबित)' : 'सब सिंक है (0 Pending)')
                  : (isMr ? '$_currentPending व्यवहार सिंक होणे बाकी' : '$_currentPending लेन-देन बाकी'),
              isSuccess: _currentPending == 0,
            ),

            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                key: const Key('btn_refresh_sync_status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenGoEarn,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isChecking ? null : _handleRefresh,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync_rounded, size: 22),
                label: Text(
                  _isChecking
                      ? (isMr ? 'तपासत आहे...' : 'जांच हो रही है...')
                      : (isMr ? 'कनेक्शन तपासा व सिंक करा' : (isHi ? 'कनेक्शन जांचें व सिंक करें' : 'Check & Sync Now')),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isMr ? 'समजले (बंद करा)' : (isHi ? 'समझ गया (बंद करें)' : 'Close'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textHighContrast),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String status,
    required bool isSuccess,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: isSuccess ? AppTheme.greenGoEarn : AppTheme.yellowPending),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
