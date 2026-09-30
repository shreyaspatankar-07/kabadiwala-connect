import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/haptics/haptic_service.dart';
import '../../core/sharing/share_service.dart';
import '../../core/theme/app_theme.dart';

class HandoverReceiptCard extends StatefulWidget {
  const HandoverReceiptCard({
    super.key,
    required this.lotId,
    required this.handoverRefNo,
    required this.qrPayload,
    required this.category,
    required this.weightKg,
    required this.recyclerName,
    required this.timestamp,
    this.locale = 'mr',
    this.onShareClicked,
  });

  final String lotId;
  final String handoverRefNo;
  final String qrPayload;
  final String category;
  final double weightKg;
  final String recyclerName;
  final DateTime timestamp;
  final String locale;
  final VoidCallback? onShareClicked;

  @override
  State<HandoverReceiptCard> createState() => _HandoverReceiptCardState();
}

class _HandoverReceiptCardState extends State<HandoverReceiptCard> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _handleShare() async {
    await HapticService.selectionClick();
    if (widget.onShareClicked != null) {
      widget.onShareClicked!();
    }

    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/handover_${widget.handoverRefNo}.png';
          final file = File(filePath);
          await file.writeAsBytes(byteData.buffer.asUint8List());

          final shareText = widget.locale == 'hi'
              ? 'हस्तांतरण डिजिटल पावती (Ref: ${widget.handoverRefNo}) - वजन: ${widget.weightKg}kg | कबाडीवाला कनेक्ट'
              : (widget.locale == 'en'
                  ? 'Digital Handover Certificate (Ref: ${widget.handoverRefNo}) - Weight: ${widget.weightKg}kg | Kabadiwala Connect'
                  : 'डिजिटल हस्तांतरण पावती (Ref: ${widget.handoverRefNo}) - वजन: ${widget.weightKg}kg | कबाडीवाला कनेक्ट');

          await ShareService.shareToWhatsApp(
            filePath: file.path,
            text: shareText,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.locale == 'hi'
                      ? 'पावती WhatsApp वर पाठवण्यासाठी तयार आहे'
                      : 'पावती WhatsApp वर पाठवण्यासाठी तयार आहे (Ready to Share)',
                ),
                backgroundColor: const Color(0xFF25D366),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[HandoverReceiptCard] Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Column(
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF047857), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'JNARDDC / E-Waste EPR Certified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  locale == 'hi'
                      ? 'हस्तांतरण डिजिटल पावती'
                      : (locale == 'en' ? 'Digital Handover Certificate' : 'डिजिटल हस्तांतरण पावती'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),

                // QR Code
                Container(
                  key: const Key('receipt_qr_code'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: QrImageView(
                    data: widget.qrPayload,
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ),
                const SizedBox(height: 12),

                // 6-Character Short Reference Number
                Text(
                  locale == 'hi' ? 'संदर्भ कोड (Ref Code)' : 'संदर्भ क्रमांक (Ref Code)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  key: const Key('receipt_ref_no_badge'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    widget.handoverRefNo.split('').join(' '),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Divider(height: 28),

                // Metadata Details
                _buildInfoRow(
                  locale == 'hi' ? 'लॉट आयडी' : 'लॉट आयडी',
                  widget.lotId,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  locale == 'hi' ? 'सामग्री प्रकार' : 'मालाचा प्रकार',
                  widget.category,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  locale == 'hi' ? 'वजन' : 'वजन',
                  '${widget.weightKg.toStringAsFixed(1)} kg',
                  isBold: true,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  locale == 'hi' ? 'अधिकृत खरीदार' : 'अधिकृत खरेदीदार',
                  widget.recyclerName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  locale == 'hi' ? 'तारीख व वेळ' : 'दिनांक व वेळ',
                  '${widget.timestamp.day}/${widget.timestamp.month}/${widget.timestamp.year} ${widget.timestamp.hour}:${widget.timestamp.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Share Receipt Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              key: const Key('share_receipt_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _handleShare,
              icon: const Icon(Icons.share_rounded, size: 26),
              label: Text(
                locale == 'hi'
                    ? 'पावती साझा करें (WhatsApp / Share)'
                    : (locale == 'en' ? 'Share Receipt' : 'पावती शेअर करा (WhatsApp)'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: isBold ? AppTheme.greenGoEarn : AppTheme.textHighContrast,
          ),
        ),
      ],
    );
  }
}
