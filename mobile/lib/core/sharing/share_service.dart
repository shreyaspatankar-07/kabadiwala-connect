import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  /// Shares content directly via WhatsApp if possible, or falls back to system share sheet.
  static Future<void> shareToWhatsApp({
    String? text,
    String? filePath,
  }) async {
    try {
      if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
        // Sharing file + caption via share_plus invokes Android native share sheet targeting WhatsApp
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text,
        );
        return;
      }

      if (text != null && text.isNotEmpty) {
        final encodedText = Uri.encodeComponent(text);
        final whatsappUri = Uri.parse('whatsapp://send?text=$encodedText');
        final webWhatsappUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedText');

        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          return;
        } else if (await canLaunchUrl(webWhatsappUri)) {
          await launchUrl(webWhatsappUri, mode: LaunchMode.externalApplication);
          return;
        } else {
          await Share.share(text);
          return;
        }
      }
    } catch (e) {
      debugPrint('[ShareService] Error sharing to WhatsApp: $e');
      if (filePath != null && filePath.isNotEmpty) {
        try {
          await Share.shareXFiles([XFile(filePath)], text: text);
        } catch (_) {}
      } else if (text != null) {
        try {
          await Share.share(text);
        } catch (_) {}
      }
    }
  }

  /// General share sheet for any application
  static Future<void> shareGeneral({
    String? text,
    String? filePath,
    String? subject,
  }) async {
    try {
      if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text,
          subject: subject,
        );
      } else if (text != null) {
        await Share.share(text, subject: subject);
      }
    } catch (e) {
      debugPrint('[ShareService] General share error: $e');
    }
  }
}
