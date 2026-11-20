import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/audio/audio_service.dart';
import '../../core/hardware/navigation_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pickup_request_model.dart';
import 'speaker_button.dart';

/// Low-literacy modal dialog alerting collector of a nearby citizen pickup request.
/// Features 56dp+ touch targets, big pictorial category cues, and spoken audio prompt.
class PickupAlertDialog extends StatelessWidget {
  final PickupRequestDto pickup;
  final AudioFeedbackService audioService;
  final NavigationService? navigationService;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onArrived;
  final String locale;

  const PickupAlertDialog({
    super.key,
    required this.pickup,
    required this.audioService,
    this.navigationService,
    required this.onAccept,
    required this.onDecline,
    this.onArrived,
    this.locale = 'mr',
  });

  String _getSpokenPrompt() {
    final dist = (pickup.estimatedDistanceKm ?? 1.5).toStringAsFixed(1);
    final cats = pickup.categories.join(', ');
    if (locale == 'hi') {
      return 'नया पिकअप उपलब्ध है — $dist किलोमीटर दूर, $cats.';
    } else if (locale == 'en') {
      return 'New pickup request available — $dist km away, $cats.';
    }
    return 'नवीन पिकअप विनंती उपलब्ध आहे — $dist किलोमीटर दूर, $cats.';
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = pickup.status == 'ACCEPTED' || pickup.status == 'ARRIVED';
    final distStr = (pickup.estimatedDistanceKm ?? 1.5).toStringAsFixed(1);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header with Audio Read-Out
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.greenGoEarn.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.greenGoEarn, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAccepted
                                  ? (locale == 'mr' ? 'सक्रिय पिकअप' : 'Active Pickup')
                                  : (locale == 'mr' ? 'नवीन पिकअप विनंती' : 'New Pickup Request'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textHighContrast,
                              ),
                            ),
                            Text(
                              pickup.publicCode,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SpeakerButton(
                  audioService: audioService,
                  onPressed: () => audioService.speak(_getSpokenPrompt(), localeOverride: locale),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Citizen Scrap Photo (Prominent Display with Tap to Zoom)
            if (pickup.photoUrls.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          Center(
                            child: InteractiveViewer(
                              child: Image.network(
                                pickup.photoUrls.first,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 28),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        pickup.photoUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.inventory_2, color: Colors.grey.shade500, size: 40),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                locale == 'mr' ? 'फोटो मोठा करा' : 'Tap to Zoom',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Distance & Location Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.greenGoEarn,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$distStr km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup.addressText ?? (locale == 'mr' ? 'जवळचे ठिकाण' : 'Nearby Location'),
                          style: const TextStyle(fontSize: 13, color: AppTheme.textHighContrast),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pickup.preferredTimeSlot != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pickup.preferredTimeSlot!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Call Citizen Button (Direct Dial)
            if (pickup.citizenPhone != null && pickup.citizenPhone!.isNotEmpty) ...[
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  key: const Key('btn_call_citizen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade800,
                    side: BorderSide(color: Colors.blue.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final cleanPhone = pickup.citizenPhone!.replaceAll(RegExp(r'[^0-9+]'), '');
                    final telUri = Uri.parse('tel:$cleanPhone');
                    if (await canLaunchUrl(telUri)) {
                      await launchUrl(telUri);
                    }
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text(
                    locale == 'mr'
                        ? 'नागरिकाला कॉल करा (${pickup.citizenPhone})'
                        : 'Call Citizen (${pickup.citizenPhone})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Categories Chips (if any categorized)
            if (pickup.categories.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pickup.categories.map((cat) {
                  return Chip(
                    backgroundColor: AppTheme.greenGoEarn.withValues(alpha: 0.08),
                    side: BorderSide(color: AppTheme.greenGoEarn.withValues(alpha: 0.3)),
                    label: Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.greenGoEarn,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // ACTION BUTTONS (Min 56dp height)
            if (!isAccepted) ...[
              Row(
                children: [
                  // Decline Button (Red Cross)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        key: const Key('btn_decline_pickup'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: onDecline,
                        icon: const Icon(Icons.close, size: 24),
                        label: Text(
                          locale == 'mr' ? 'नाकारा' : 'Decline',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Accept Button (Green Checkmark)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        key: const Key('btn_accept_pickup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenGoEarn,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: onAccept,
                        icon: const Icon(Icons.check_circle, size: 24),
                        label: Text(
                          locale == 'mr' ? 'स्वीकारा (Accept)' : 'Accept Pickup',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Accepted Flow: Turn-by-turn Navigation & Arrived / Start Weighing Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('btn_start_navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final nav = navigationService ?? NavigationService();
                    final launched = await nav.launchTurnByTurnNavigation(
                      latitude: pickup.latitude,
                      longitude: pickup.longitude,
                    );
                    if (!launched) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            locale == 'mr'
                                ? 'थेट नेव्हिगेशनसाठी इंटरनेट आवश्यक आहे.'
                                : (locale == 'hi'
                                    ? 'नेविगेशन के लिए इंटरनेट आवश्यक है।'
                                    : 'Turn-by-turn navigation needs an internet connection.'),
                          ),
                          backgroundColor: Colors.orange.shade800,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.navigation, size: 24),
                  label: Text(
                    locale == 'mr' ? 'नॅव्हिगेशन सुरू करा (Maps)' : 'Start Navigation',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('btn_arrived_destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenGoEarn,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onArrived,
                  icon: const Icon(Icons.scale, size: 24),
                  label: Text(
                    locale == 'mr' ? 'पोहोचलो व वजन करा (Arrived & Start Weighing)' : 'Arrived & Start Weighing',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
