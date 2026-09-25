import 'package:flutter/material.dart';
import '../../core/hardware/image_processor.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

class CameraCaptureCard extends StatelessWidget {
  const CameraCaptureCard({
    super.key,
    required this.photos,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    this.locale = 'mr',
  });

  final List<ProcessedPhoto> photos;
  final VoidCallback onCapturePhoto;
  final ValueChanged<int> onRemovePhoto;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = photos.length < 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'hi'
                    ? 'सामान का फोटो (${photos.length}/4)'
                    : (locale == 'en' ? 'Item Photos (${photos.length}/4)' : 'मालाचा फोटो (${photos.length}/4)'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              if (photos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.greenGoEarnLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '≤ 200 KB ✓ SHA-256',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greenGoEarn,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Photos Row or Empty State
          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final shortHash = photo.sha256Hash.substring(0, 8);
                  return Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_rounded, size: 36, color: AppTheme.greenGoEarn),
                            const SizedBox(height: 4),
                            Text(
                              '${photo.sizeInKb.toStringAsFixed(0)} KB',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.greenGoEarn,
                              ),
                            ),
                            Text(
                              '#$shortHash',
                              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        top: 2,
                        end: 2,
                        child: GestureDetector(
                          onTap: () {
                            HapticService.selectionClick();
                            onRemovePhoto(index);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppTheme.dangerRed,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Camera Action Button
          if (canAddMore)
            SizedBox(
              height: 58,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.greenGoEarn, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppTheme.greenGoEarnLight.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  HapticService.mediumImpact();
                  onCapturePhoto();
                },
                icon: const Icon(Icons.camera_alt_rounded, color: AppTheme.greenGoEarn, size: 28),
                label: Text(
                  photos.isEmpty
                      ? (locale == 'hi'
                          ? 'कॅमेरा सुरू करा (फोटो लें)'
                          : (locale == 'en' ? 'Open Camera (Take Photo)' : 'कॅमेरा सुरू करा (फोटो काढा)'))
                      : (locale == 'hi'
                          ? 'अतिरिक्त फोटो जोड़ें (${photos.length}/4)'
                          : (locale == 'en' ? 'Add Another Photo' : 'अजून फोटो जोडा (${photos.length}/4)')),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.greenGoEarn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
