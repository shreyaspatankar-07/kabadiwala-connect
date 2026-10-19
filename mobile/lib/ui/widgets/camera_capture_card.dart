import 'package:flutter/material.dart';
import '../../core/hardware/image_processor.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import 'image_preview_dialog.dart';

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
                    : (locale == 'en'
                        ? 'Item Photos (${photos.length}/4)'
                        : 'मालाचा फोटो (${photos.length}/4)'),
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
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final shortHash = photo.sha256Hash.substring(0, 8);
                  return Stack(
                    children: [
                      InkWell(
                        key: Key('btn_preview_photo_$index'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticService.selectionClick();
                          ImagePreviewDialog.show(
                            context: context,
                            imageBytes: photo.bytes,
                            title: locale == 'hi'
                                ? 'फोटो #${index + 1} पूर्वावलोकन'
                                : (locale == 'en'
                                    ? 'Photo #${index + 1} Preview'
                                    : 'फोटो #${index + 1} पूर्वावलोकन'),
                            sizeInKb: photo.sizeInKb,
                            sha256Hash: photo.sha256Hash,
                            latitude: photo.latitude,
                            longitude: photo.longitude,
                            locationString: photo.locationString,
                            locale: locale,
                          );
                        },
                        child: Container(
                          width: 94,
                          height: 118,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderColor, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image icon / thumbnail preview with zoom indicator
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      photo.bytes,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppTheme.greenGoEarnLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.image_rounded,
                                          size: 32,
                                          color: AppTheme.greenGoEarn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
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
                      ),
                      PositionedDirectional(
                        top: 2,
                        end: 2,
                        child: GestureDetector(
                          key: Key('btn_remove_photo_$index'),
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
                          : (locale == 'en'
                              ? 'Open Camera (Take Photo)'
                              : 'कॅमेरा सुरू करा (फोटो काढा)'))
                      : (locale == 'hi'
                          ? 'अतिरिक्त फोटो जोड़ें (${photos.length}/4)'
                          : (locale == 'en'
                              ? 'Add Another Photo'
                              : 'अजून फोटो जोडा (${photos.length}/4)')),
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
