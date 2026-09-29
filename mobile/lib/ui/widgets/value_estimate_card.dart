import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

class ValueEstimateCard extends StatelessWidget {
  const ValueEstimateCard({
    super.key,
    required this.estimatedPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.weightKg,
    required this.audioService,
    this.locale = 'mr',
  });

  final double estimatedPrice;
  final double minPrice;
  final double maxPrice;
  final double weightKg;
  final AudioFeedbackService audioService;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final int roundedEst = estimatedPrice.round();
    final int roundedMin = minPrice.round();
    final int roundedMax = maxPrice.round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.greenGoEarnLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.greenGoEarn, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'hi'
                    ? 'अनुमानित सरकारी भाव:'
                    : (locale == 'en' ? 'Estimated Govt Rate:' : 'अंदाजे सरकारी भाव:'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.greenGoEarn,
                ),
              ),
              // Speaker button to speak estimate aloud
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticService.mediumImpact();
                    audioService.speakEstimate(roundedEst, localeOverride: locale);
                  },
                  child: Container(
                    width: AppTheme.minTouchTargetSize,
                    height: AppTheme.minTouchTargetSize,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppTheme.greenGoEarn,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹ $roundedEst',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Color(0xFF064E3B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Min-Max visual range bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'en' ? 'Min: ₹ $roundedMin' : (locale == 'hi' ? 'न्यूनतम: ₹ $roundedMin' : 'किमान: ₹ $roundedMin'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      locale == 'en' ? 'Max: ₹ $roundedMax' : (locale == 'hi' ? 'अधिकतम: ₹ $roundedMax' : 'कमाल: ₹ $roundedMax'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: maxPrice > minPrice
                        ? ((estimatedPrice - minPrice) / (maxPrice - minPrice)).clamp(0.0, 1.0)
                        : 0.5,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.greenGoEarn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
