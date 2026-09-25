import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/safety_repository.dart';
import '../widgets/speaker_button.dart';
import 'language_selection_screen.dart';

/// Plain-language, low-literacy privacy card and data deletion screen.
/// Implements data minimization and right-to-be-forgotten principles.
class PrivacyScreen extends StatelessWidget {
  final AudioFeedbackService audioService;
  final AppDatabase db;
  final String locale;
  final String collectorId;
  final VoidCallback? onDataDeleted;

  const PrivacyScreen({
    super.key,
    required this.audioService,
    required this.db,
    this.locale = 'mr',
    this.collectorId = 'KC-C-7821',
    this.onDataDeleted,
  });

  void _playPrivacyAudio() {
    audioService.speakPrompt('privacyNotice', localeOverride: locale);
  }

  Future<void> _handleDeleteMyData(BuildContext context) async {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('dialog_confirm_delete_data'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppTheme.dangerRed, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isMr ? 'खात्री करा: सर्व डेटा नष्ट करायचा?' : (isHi ? 'पुष्टि करें: क्या सारा डेटा हटाना है?' : 'Confirm Data Deletion'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: Text(
          isMr
              ? 'फोनमधील व सर्व्हरवरील सर्व जुन्या नोंदी कायमच्या पुसल्या जातील. ही क्रिया मागे घेता येणार नाही.'
              : (isHi
                  ? 'फोन और सर्वर से सभी पुराने रिकॉर्ड स्थायी रूप से हटा दिए जाएंगे। यह क्रिया वापस नहीं होगी।'
                  : 'All local and server records will be permanently removed. This action cannot be undone.'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancel_delete'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isMr ? 'रद्द करा' : (isHi ? 'रद्द करें' : 'Cancel')),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_delete_data'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isMr ? 'हो, डेटा नष्ट करा' : (isHi ? 'हां, डेटा हटाएं' : 'Yes, Delete'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 1. Purge all local Drift database tables
      await db.delete(db.localTransactions).go();
      await db.delete(db.localTraceability).go();
      await db.delete(db.localLedger).go();
      await db.delete(db.syncQueueEntries).go();
      SafetyRepository().clearAcknowledgements();

      // 2. Play audio feedback and haptics
      unawaited(HapticService.heavyImpact());
      await audioService.speakPrompt('dataDeletedNotice', localeOverride: locale);

      // 3. Show confirmation snackbar
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isMr ? 'सर्व डेटा यशस्वीरीत्या नष्ट करण्यात आला' : (isHi ? 'सारा डेटा सफलतापूर्वक हटा दिया गया' : 'All data erased successfully'),
          ),
          backgroundColor: AppTheme.dangerRed,
        ),
      );

      // 4. Navigate back to onboarding language selection or trigger callback
      if (onDataDeleted != null) {
        onDataDeleted!();
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => LanguageSelectionScreen(audioService: audioService),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          isMr ? 'गोपनीयता व डेटा सुरक्षा' : (isHi ? 'गोपनीयता और डेटा सुरक्षा' : 'Privacy & Data Security'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          SpeakerButton(
            key: const Key('btn_privacy_audio'),
            promptKey: 'privacyNotice',
            audioService: audioService,
            onPressed: _playPrivacyAudio,
            tooltip: 'गोपनीयता नियम ऐका',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Graphic Shield Card
              Container(
                key: const Key('privacy_overview_card'),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.greenGoEarn.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.security_rounded,
                          color: AppTheme.greenGoEarn,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isMr ? 'तुमची माहिती १००% सुरक्षित आहे' : (isHi ? 'आपकी जानकारी १००% सुरक्षित है' : 'Your Data is 100% Protected'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textHighContrast),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMr
                          ? 'आम्ही आधार कार्ड, पूर्ण नाव किंवा घरचा पत्ता कधीही मागत नाही. फक्त ई-कचऱ्याचे वजन आणि मिळालेले पैसे नोंदवले जातात.'
                          : (isHi
                              ? 'हम आधार कार्ड, पूरा नाम या घर का पता कभी नहीं मांगते। केवल वजन और भाव दर्ज होता है।'
                              : 'We never collect Aadhaar numbers, real names or home addresses. Only scrap weight and transaction rates are stored.'),
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Pictorial 4-Point Guarantee List
              _buildGuaranteeItem(
                icon: Icons.credit_card_off_rounded,
                title: isMr ? '१. आधार किंवा ओळखपत्राची गरज नाही' : (isHi ? '१. आधार या पहचान पत्र की कोई आवश्यकता नहीं' : '1. No Aadhaar Card Required'),
                subtitle: isMr ? 'कोणतेही सरकारी ओळखपत्र अपलोड करावे लागत नाही.' : (isHi ? 'कोई भी सरकारी आईडी अपलोड नहीं करनी होगी।' : 'Zero personal identity documents collected.'),
              ),
              const SizedBox(height: 10),
              _buildGuaranteeItem(
                icon: Icons.pin_outlined,
                title: isMr ? '२. गुप्त पिन किंवा मोबाईल ओटीपी' : (isHi ? '२. गुप्त पिन या मोबाइल ओटीपी' : '2. PIN or Phone OTP Only'),
                subtitle: isMr ? 'फक्त ४ अंकांचा सोपा पिन टाकून अ‍ॅप चालते.' : (isHi ? 'सिर्फ ४ अंकों का पिन डालकर ऐप काम करता है।' : 'Anonymous generated ID linked to 4-digit PIN.'),
              ),
              const SizedBox(height: 10),
              _buildGuaranteeItem(
                icon: Icons.cloud_off_rounded,
                title: isMr ? '३. सर्व माहिती आधी फोनमध्ये ऑफलाइन' : (isHi ? '३. सारा डेटा पहले फोन में ऑफलाइन' : '3. Offline-First Local Storage'),
                subtitle: isMr ? 'इंटरनेट नसतानाही तुमचा हिशोब पूर्णपणे सुरक्षित राहतो.' : (isHi ? 'बिना इंटरनेट के भी आपका हिसाब पूरी तरह सुरक्षित रहता है।' : 'Stored locally in encrypted SQLite on device.'),
              ),
              const SizedBox(height: 10),
              _buildGuaranteeItem(
                icon: Icons.delete_outline_rounded,
                title: isMr ? '४. तुम्ही कधीही डेटा नष्ट करू शकता' : (isHi ? '४. कभी भी डेटा मिटाने का अधिकार' : '4. Complete Right to be Forgotten'),
                subtitle: isMr ? 'एका दाबात फोन व सर्व्हरवरून सर्व नोंदी पुसल्या जातात.' : (isHi ? 'एक टैप में फोन और सर्वर से रिकॉर्ड हटा सकते हैं।' : 'One-tap total data purge anytime.'),
              ),
              const SizedBox(height: 28),

              // 3. One-Tap Delete My Data Button
              ElevatedButton.icon(
                key: const Key('btn_delete_my_data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _handleDeleteMyData(context),
                icon: const Icon(Icons.delete_forever_rounded, size: 28),
                label: Text(
                  isMr ? 'माझा सर्व डेटा नष्ट करा (Delete)' : (isHi ? 'मेरा सारा डेटा हटाएं (Delete Data)' : 'Delete My Data Permanently'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuaranteeItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(icon, color: AppTheme.greenGoEarn, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textHighContrast),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            ),
        ],
      ),
    );
  }
}
