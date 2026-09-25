import 'package:flutter/material.dart';
import '../../core/demo/demo_mode_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Persistent yellow DEMO banner displaying mode status and offline simulation controls.
class DemoBannerWidget extends StatelessWidget {
  final String locale;

  const DemoBannerWidget({
    super.key,
    this.locale = 'mr',
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DemoModeService.instance,
      builder: (context, _) {
        if (!DemoModeService.instance.isDemoMode) {
          return const SizedBox.shrink();
        }

        final isMr = locale == 'mr';
        final isHi = locale == 'hi';
        final isSimOffline = DemoModeService.instance.isSimulatedOffline;

        return Container(
          key: const Key('banner_demo_mode'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMr
                      ? 'डेमो मोड: सर्व डेटा फोनमध्ये सुरक्षित आहे'
                      : (isHi
                          ? 'डेमो मोड: सारा डेटा फोन में सुरक्षित है'
                          : 'DEMO MODE: Synthetic Data Loaded'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                key: const Key('btn_toggle_simulated_offline'),
                onTap: () {
                  HapticService.mediumImpact();
                  DemoModeService.instance.toggleSimulatedOffline();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSimOffline ? AppTheme.dangerRed : AppTheme.greenGoEarn,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSimOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSimOffline
                            ? (isMr ? 'ऑफलाइन' : (isHi ? 'ऑफलाइन' : 'Offline'))
                            : (isMr ? 'ऑनलाइन' : (isHi ? 'ऑनलाइन' : 'Online')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
