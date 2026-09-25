import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DownstreamTimelineWidget extends StatelessWidget {
  const DownstreamTimelineWidget({
    super.key,
    required this.currentStatus,
    this.locale = 'mr',
  });

  /// Status can be 'received', 'dismantled', 'processed', or 'certificate_issued'.
  final String currentStatus;
  final String locale;

  static const List<Map<String, dynamic>> _steps = [
    {
      'key': 'received',
      'icon': Icons.inventory_2_rounded,
      'mr': 'माल मिळाला',
      'hi': 'माल प्राप्त',
      'en': 'Received',
    },
    {
      'key': 'dismantled',
      'icon': Icons.build_circle_rounded,
      'mr': 'विघटन पूर्ण',
      'hi': 'विघटन पूर्ण',
      'en': 'Dismantled',
    },
    {
      'key': 'processed',
      'icon': Icons.recycling_rounded,
      'mr': 'प्रक्रिया सुरू',
      'hi': 'प्रसंस्करण',
      'en': 'Processed',
    },
    {
      'key': 'certificate_issued',
      'icon': Icons.verified_rounded,
      'mr': 'प्रमाणपत्र जारी',
      'hi': 'प्रमाणपत्र जारी',
      'en': 'EPR Certified',
    },
  ];

  int _getStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'dismantled':
        return 1;
      case 'processed':
        return 2;
      case 'certificate_issued':
        return 3;
      case 'received':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getStatusIndex(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppTheme.greenGoEarn, size: 22),
              const SizedBox(width: 8),
              Text(
                locale == 'hi'
                    ? 'पुनर्चक्रण प्रगति (EPR Traceability)'
                    : (locale == 'en' ? 'Downstream Processing Progress' : 'पुनर्प्रक्रिया प्रगती (EPR Traceability)'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textHighContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isDone = index <= currentIndex;
              final isCurrent = index == currentIndex;

              final label = (locale == 'hi'
                  ? step['hi']
                  : (locale == 'en' ? step['en'] : step['mr'])) as String;

              return Expanded(
                child: Column(
                  children: [
                    // Step Icon Circle
                    Container(
                      key: Key('timeline_step_${step['key']}'),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.greenGoEarn
                              : (isDone ? const Color(0xFF22C55E) : Colors.grey.shade300),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isDone ? AppTheme.greenGoEarn : Colors.grey.shade400,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w900 : (isDone ? FontWeight.bold : FontWeight.w500),
                        color: isCurrent
                            ? AppTheme.greenGoEarn
                            : (isDone ? AppTheme.textHighContrast : AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
