import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/audio/audio_service.dart';
import '../../core/handover/offline_handover_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../widgets/big_keypad.dart';
import '../widgets/handover_receipt_card.dart';
import '../widgets/speaker_button.dart';
import 'recycler_confirm_screen.dart';

class HandoverInitiateScreen extends StatefulWidget {
  const HandoverInitiateScreen({
    super.key,
    required this.lotId,
    required this.initialWeightKg,
    required this.category,
    required this.recyclerName,
    required this.quotedPrice,
    required this.db,
    required this.audioService,
    this.locale = 'mr',
    this.initialGpsLat = 19.0760,
    this.initialGpsLng = 72.8777,
    this.handoverService,
  });

  final String lotId;
  final double initialWeightKg;
  final String category;
  final String recyclerName;
  final double quotedPrice;
  final AppDatabase db;
  final AudioFeedbackService audioService;
  final String locale;
  final double initialGpsLat;
  final double initialGpsLng;
  final OfflineHandoverService? handoverService;

  @override
  State<HandoverInitiateScreen> createState() => _HandoverInitiateScreenState();
}

class _HandoverInitiateScreenState extends State<HandoverInitiateScreen> {
  late final OfflineHandoverService _handoverService;
  late String _weightInputString;
  bool _isQrGenerated = false;
  HandoverInitiateResult? _handoverResult;

  @override
  void initState() {
    super.initState();
    _handoverService = widget.handoverService ?? OfflineHandoverService(widget.db);
    _weightInputString = widget.initialWeightKg.toStringAsFixed(
        widget.initialWeightKg.truncateToDouble() == widget.initialWeightKg ? 0 : 1);
  }

  double get _currentWeight => double.tryParse(_weightInputString) ?? widget.initialWeightKg;

  void _onDigitPressed(String digit) {
    HapticService.lightImpact();
    setState(() {
      if (_weightInputString == '0' && digit != '.') {
        _weightInputString = digit;
      } else if (digit == '.' && _weightInputString.contains('.')) {
        return;
      } else {
        _weightInputString += digit;
      }
    });
  }

  void _onBackspacePressed() {
    HapticService.lightImpact();
    setState(() {
      if (_weightInputString.isNotEmpty) {
        _weightInputString = _weightInputString.substring(0, _weightInputString.length - 1);
        if (_weightInputString.isEmpty) _weightInputString = '0';
      }
    });
  }

  Future<void> _generateHandoverQR() async {
    await HapticService.heavyImpact();
    final result = await _handoverService.initiateHandover(
      lotId: widget.lotId,
      weightKg: _currentWeight,
      photoHashes: ['photo_hash_fresh_01'],
      gpsLat: widget.initialGpsLat,
      gpsLng: widget.initialGpsLng,
    );

    if (mounted) {
      setState(() {
        _handoverResult = result;
        _isQrGenerated = true;
      });

      unawaited(widget.audioService.speakCustomText(
        widget.locale == 'hi'
            ? 'हस्तांतरण क्यूआर कोड तैयार है। रीसायकलर को स्कैन करने दें।'
            : 'हस्तांतरण क्यूआर कोड तयार आहे. रीसायकलरला स्कॅन करू द्या.',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'hi'
              ? 'माल हस्तांतरण (Handover)'
              : (locale == 'en' ? 'Lot Handover' : 'माल हस्तांतरण (Handover)'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          SpeakerButton(
            promptKey: 'tabAddLot',
            audioService: widget.audioService,
            tooltip: 'सूचना ऐका',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: _isQrGenerated && _handoverResult != null
              ? _buildQrDisplayView(locale)
              : _buildPreparationView(locale),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Verification, Weight Confirm & Summary
  // ---------------------------------------------------------------------------
  Widget _buildPreparationView(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'लॉट: ${widget.lotId}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'जुळलेला (Matched)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildSummaryRow(locale == 'hi' ? 'सामग्री प्रकार' : 'मालाचा प्रकार', widget.category),
              const SizedBox(height: 6),
              _buildSummaryRow(locale == 'hi' ? 'खरीदार रीसायकलर' : 'खरेदीदार रीसायकलर', widget.recyclerName),
              const SizedBox(height: 6),
              _buildSummaryRow(locale == 'hi' ? 'अनुमानित मूल्य' : 'अंदाजे किंमत', '₹${widget.quotedPrice.toStringAsFixed(0)}'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Final Weight Entry
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                locale == 'hi' ? 'अंतिम वजन दर्ज करें' : 'हस्तांतरण वजन तपासा',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weightInputString,
                    key: const Key('final_weight_display'),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.greenGoEarn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('kg', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Keypad
        BigKeypad(
          onDigitPressed: _onDigitPressed,
          onBackspacePressed: _onBackspacePressed,
          onSubmitPressed: _generateHandoverQR,
          showSubmit: false,
        ),
        const SizedBox(height: 18),

        // Button: Generate Handover QR
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            key: const Key('generate_qr_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greenGoEarn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _generateHandoverQR,
            icon: const Icon(Icons.qr_code_2_rounded, size: 30),
            label: Text(
              locale == 'hi'
                  ? 'हस्तांतरण क्यूआर कोड बनाएं (Generate QR)'
                  : (locale == 'en' ? 'Generate Handover QR' : 'हस्तांतरण QR कोड तयार करा'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: QR Code Full-Screen Display & 6-Char Code
  // ---------------------------------------------------------------------------
  Widget _buildQrDisplayView(String locale) {
    final result = _handoverResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-screen card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.greenGoEarn, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                locale == 'hi'
                    ? 'रीसायकलर को यह कोड स्कैन करने दें'
                    : 'रीसायकलरला हा कोड स्कॅन करू द्या',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // QR Code
              Container(
                key: const Key('handover_qr_image'),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: QrImageView(
                  data: result.qrPayload,
                  version: QrVersions.auto,
                  size: 220.0,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                locale == 'hi'
                    ? 'या 6-अंकों का संदर्भ कोड बताएं:'
                    : 'किंवा खालील ६-अक्षरी कोड सांगा:',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // 6-Character Short Reference Code
              Container(
                key: const Key('handover_short_code_badge'),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
                ),
                child: Text(
                  result.handoverRefNo.split('').join(' '),
                  key: const Key('handover_short_code_text'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Offline Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_rounded, color: AppTheme.greenGoEarn, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    locale == 'hi'
                        ? 'ऑफलाइन सुरक्षित (HMAC-SHA256 डिजिटल स्वाक्षरी)'
                        : 'ऑफलाइन सुरक्षित (HMAC-SHA256 डिजिटल सही)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.greenGoEarn),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Handover Receipt Card
        HandoverReceiptCard(
          lotId: widget.lotId,
          handoverRefNo: result.handoverRefNo,
          qrPayload: result.qrPayload,
          category: widget.category,
          weightKg: result.weightKg,
          recyclerName: widget.recyclerName,
          timestamp: result.timestamp,
          locale: locale,
        ),
        const SizedBox(height: 18),

        // Recycler Confirmation Flow Simulation Button
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            key: const Key('simulate_recycler_confirm_button'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF047857), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              HapticService.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecyclerConfirmScreen(
                    handoverRefNo: result.handoverRefNo,
                    qrPayload: result.qrPayload,
                    collectorWeightKg: result.weightKg,
                    lotId: widget.lotId,
                    db: widget.db,
                    audioService: widget.audioService,
                    locale: locale,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.storefront_rounded, color: AppTheme.greenGoEarn, size: 26),
            label: Text(
              locale == 'hi'
                  ? 'रीसायकलर पुष्टि स्क्रीन (Recycler Confirm)'
                  : 'रीसायकलर पावती पुष्टी (Recycler Confirm)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.greenGoEarn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
