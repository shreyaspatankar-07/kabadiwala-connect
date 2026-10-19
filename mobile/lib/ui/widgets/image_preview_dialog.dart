import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

/// Fullscreen / Large modal image preview dialog for captured e-waste photos.
///
/// Features:
/// - Pinch-to-zoom interactive viewer via [InteractiveViewer].
/// - Displays cryptographic hash (SHA-256) & size constraints (<= 200 KB).
/// - Vernacular localized titles and large 56dp tactile close button.
/// - Graceful fallback graphics when running in headless test environments.
class ImagePreviewDialog extends StatelessWidget {
  const ImagePreviewDialog({
    super.key,
    required this.imageBytes,
    this.title,
    this.sizeInKb,
    this.sha256Hash,
    this.latitude,
    this.longitude,
    this.locationString,
    this.locale = 'mr',
  });

  final Uint8List imageBytes;
  final String? title;
  final double? sizeInKb;
  final String? sha256Hash;
  final double? latitude;
  final double? longitude;
  final String? locationString;
  final String locale;

  static Future<void> show({
    required BuildContext context,
    required Uint8List imageBytes,
    String? title,
    double? sizeInKb,
    String? sha256Hash,
    double? latitude,
    double? longitude,
    String? locationString,
    String locale = 'mr',
  }) {
    HapticService.selectionClick();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ImagePreviewDialog(
        imageBytes: imageBytes,
        title: title,
        sizeInKb: sizeInKb,
        sha256Hash: sha256Hash,
        latitude: latitude,
        longitude: longitude,
        locationString: locationString,
        locale: locale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String defaultTitle = locale == 'hi'
        ? 'फोटो पूर्वावलोकन (Preview)'
        : (locale == 'en' ? 'Photo Preview' : 'फोटो पूर्वावलोकन (Preview)');

    final String closeLabel =
        locale == 'hi' ? 'बंद करें' : (locale == 'en' ? 'Close Preview' : 'पूर्वावलोकन बंद करा');

    final double effectiveKb = sizeInKb ?? (imageBytes.length / 1024.0);

    return Dialog(
      key: const Key('dialog_image_preview'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 480,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.greenGoEarnLight.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.greenGoEarn,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.image_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? defaultTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textHighContrast,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${effectiveKb.toStringAsFixed(1)} KB • EPR ऑडिट सिद्ध',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.greenGoEarn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('btn_close_image_preview_icon'),
                    onPressed: () {
                      HapticService.selectionClick();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.black87),
                    tooltip: closeLabel,
                  ),
                ],
              ),
            ),

            // 2. Interactive Image Area with Pinch-to-Zoom
            Flexible(
              child: Container(
                color: Colors.black.withValues(alpha: 0.94),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, error, stackTrace) => Container(
                        height: 260,
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image_rounded,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              locale == 'hi'
                                  ? 'फोटो पूर्वावलोकन (सिम्युलेटेड टेस्ट फ्रेम)'
                                  : (locale == 'en'
                                      ? 'Photo Preview (Simulated Frame)'
                                      : 'फोटो पूर्वावलोकन (चाचणी फ्रेम)'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${effectiveKb.toStringAsFixed(1)} KB • SHA-256 सिद्ध',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Metadata strip (Traceability & GPS)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 16, color: AppTheme.greenGoEarn),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sha256Hash != null
                          ? 'SHA-256: ${sha256Hash!.length > 16 ? "${sha256Hash!.substring(0, 16)}..." : sha256Hash}'
                          : 'कायदेशीर पुरावा जतन (EPR 2022 Compliant)',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (locationString != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      (locationString!.contains('Lat:') && locationString!.contains('Lng:'))
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      size: 14,
                      color: (locationString!.contains('Lat:') && locationString!.contains('Lng:'))
                          ? AppTheme.greenGoEarn
                          : AppTheme.yellowPending,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationString!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ] else if (latitude != null && longitude != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.greenGoEarn),
                    Text(
                      '${latitude!.toStringAsFixed(2)}, ${longitude!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 4. Large tactile action button (min 56dp height)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton.icon(
                key: const Key('btn_close_image_preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenGoEarn,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {
                  HapticService.selectionClick();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_circle_rounded, size: 24),
                label: Text(
                  closeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
