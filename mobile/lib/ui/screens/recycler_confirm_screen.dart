import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/handover/offline_handover_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../widgets/big_keypad.dart';
import '../widgets/downstream_timeline_widget.dart';

class RecyclerConfirmScreen extends StatefulWidget {
  const RecyclerConfirmScreen({
    super.key,
    required this.handoverRefNo,
    required this.collectorWeightKg,
    required this.lotId,
    required this.db,
    required this.audioService,
    this.qrPayload,
    this.locale = 'mr',
    this.handoverService,
  });

  final String handoverRefNo;
  final double collectorWeightKg;
  final String lotId;
  final AppDatabase db;
  final AudioFeedbackService audioService;
  final String? qrPayload;
  final String locale;
  final OfflineHandoverService? handoverService;

  @override
  State<RecyclerConfirmScreen> createState() => _RecyclerConfirmScreenState();
}

class _RecyclerConfirmScreenState extends State<RecyclerConfirmScreen> {
  late final OfflineHandoverService _handoverService;
  late String _measuredWeightString;
  String _finalPriceString = '5000';
  bool _isWeightMode = true; // true = entering weight, false = entering price
  bool _isConfirmed = false;
  HandoverConfirmResult? _confirmResult;

  @override
  void initState() {
    super.initState();
    _handoverService = widget.handoverService ?? OfflineHandoverService(widget.db);
    _measuredWeightString = widget.collectorWeightKg.toStringAsFixed(
        widget.collectorWeightKg.truncateToDouble() == widget.collectorWeightKg ? 0 : 1);
  }

  double get _measuredWeight => double.tryParse(_measuredWeightString) ?? widget.collectorWeightKg;
  double get _finalPrice => double.tryParse(_finalPriceString) ?? 0.0;

  double get _weightDelta {
    if (widget.collectorWeightKg <= 0) return 0.0;
    return (_measuredWeight - widget.collectorWeightKg).abs() / widget.collectorWeightKg;
  }

  bool get _isMismatched => _weightDelta > 0.10;

  void _onDigitPressed(String digit) {
    HapticService.lightImpact();
    setState(() {
      if (_isWeightMode) {
        if (_measuredWeightString == '0' && digit != '.') {
          _measuredWeightString = digit;
        } else if (digit == '.' && _measuredWeightString.contains('.')) {
          return;
        } else {
          _measuredWeightString += digit;
        }
      } else {
        if (_finalPriceString == '0') {
          _finalPriceString = digit;
        } else {
          _finalPriceString += digit;
        }
      }
    });
  }

  void _onBackspacePressed() {
    HapticService.lightImpact();
    setState(() {
      if (_isWeightMode) {
        if (_measuredWeightString.isNotEmpty) {
          _measuredWeightString = _measuredWeightString.substring(0, _measuredWeightString.length - 1);
          if (_measuredWeightString.isEmpty) _measuredWeightString = '0';
        }
      } else {
        if (_finalPriceString.isNotEmpty) {
          _finalPriceString = _finalPriceString.substring(0, _finalPriceString.length - 1);
          if (_finalPriceString.isEmpty) _finalPriceString = '0';
        }
      }
    });
  }

  Future<void> _handleConfirm() async {
    await HapticService.heavyImpact();
    try {
      final res = await _handoverService.confirmHandover(
        handoverRefNo: widget.handoverRefNo,
        qrPayload: widget.qrPayload,
        measuredWeightKg: _measuredWeight,
        finalPrice: _finalPrice,
      );

      if (mounted) {
        setState(() {
          _confirmResult = res;
          _isConfirmed = true;
        });

        if (res.isDisputed) {
          unawaited(widget.audioService.speakCustomText(
            widget.locale == 'hi'
                ? 'चेतावनी: वजन में 10% से अधिक अंतर है। लेनदेन विवादित दर्ज किया गया।'
                : 'सावधान: वजनात १०% पेक्षा जास्त फरक आहे. व्यवहार विवादित म्हणून नोंदवला गेला.',
          ));
        } else {
          unawaited(widget.audioService.speakCustomText(
            widget.locale == 'hi'
                ? 'हस्तांतरण सफलतापूर्वक पूरा हुआ।'
                : 'हस्तांतरण यशस्वीरीत्या पूर्ण झाले.',
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'hi'
              ? 'रीसायकलर पुष्टि (Recycler Confirm)'
              : (locale == 'en' ? 'Recycler Confirmation' : 'रीसायकलर पुष्टी (Recycler Confirm)'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: _isConfirmed && _confirmResult != null
              ? _buildConfirmedSuccessView(locale)
              : _buildConfirmForm(locale),
        ),
      ),
    );
  }

  Widget _buildConfirmForm(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reference Code Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'hi' ? 'संदर्भ कोड (Ref):' : 'संदर्भ कोड (Ref):',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              Text(
                widget.handoverRefNo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Collector Claimed Weight vs Recycler Measured Weight
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    locale == 'hi' ? 'कलेक्टर वजन' : 'कलेक्टर वजन',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.collectorWeightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted),
              Column(
                children: [
                  Text(
                    locale == 'hi' ? 'रीसायकलर माप' : 'रीसायकलर वजन',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_measuredWeightString kg',
                    key: const Key('recycler_measured_weight_display'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _isMismatched ? AppTheme.yellowPending : AppTheme.greenGoEarn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Weight Mismatch Warning Banner (> 10% tolerance)
        if (_isMismatched)
          Container(
            key: const Key('weight_mismatch_warning'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locale == 'hi'
                        ? 'चेतावनी: वजन में ${(_weightDelta * 100).toStringAsFixed(1)}% का अंतर है (10% सीमा से अधिक)। यह लेनदेन विवादित (Disputed) के रूप में दर्ज होगा।'
                        : 'सावधान: वजनात ${(_weightDelta * 100).toStringAsFixed(1)}% फरक आहे (१०% मर्यादेपेक्षा जास्त). हा व्यवहार विवादित (Disputed) म्हणून नोंदवला जाईल.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),

        // Toggle: Enter Weight vs Enter Final Price
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                key: const Key('chip_weight_mode'),
                label: Text(
                  locale == 'hi' ? 'वजन (Weight)' : 'वजन (Weight)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: _isWeightMode,
                onSelected: (val) {
                  if (val) setState(() => _isWeightMode = true);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                key: const Key('chip_price_mode'),
                label: Text(
                  'रक्कम: ₹$_finalPriceString',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: !_isWeightMode,
                onSelected: (val) {
                  if (val) setState(() => _isWeightMode = false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // BigKeypad
        BigKeypad(
          onDigitPressed: _onDigitPressed,
          onBackspacePressed: _onBackspacePressed,
          onSubmitPressed: _handleConfirm,
          showSubmit: false,
        ),
        const SizedBox(height: 16),

        // Confirm Button
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            key: const Key('confirm_handover_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isMismatched ? const Color(0xFFD97706) : AppTheme.greenGoEarn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleConfirm,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 28),
            label: Text(
              _isMismatched
                  ? (locale == 'hi' ? 'विवादित दर्ज करें (Confirm Disputed)' : 'विवादित नोंदवा (Confirm Disputed)')
                  : (locale == 'hi' ? 'पुष्टि करें (Confirm Handover)' : 'हस्तांतरण पूर्ण करा (Confirm Handover)'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedSuccessView(String locale) {
    final res = _confirmResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: res.isDisputed ? const Color(0xFFF59E0B) : AppTheme.greenGoEarn,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                res.isDisputed ? Icons.report_problem_rounded : Icons.check_circle_rounded,
                color: res.isDisputed ? const Color(0xFFD97706) : AppTheme.greenGoEarn,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                res.isDisputed
                    ? (locale == 'hi' ? 'हस्तांतरण विवादित (Disputed)' : 'हस्तांतरण विवादित (Disputed)')
                    : (locale == 'hi' ? 'हस्तांतरण सत्यापित व पूर्ण!' : 'हस्तांतरण यशस्वीरीत्या पूर्ण!'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              if (res.disputeReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  res.disputeReason!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFFB45309), fontWeight: FontWeight.bold),
                ),
              ],
              const Divider(height: 24),
              _buildDetailRow('लॉट आयडी', res.lotId),
              const SizedBox(height: 6),
              _buildDetailRow('अंतिम वजन', '${res.measuredWeightKg.toStringAsFixed(1)} kg'),
              const SizedBox(height: 6),
              _buildDetailRow('अंतिम किंमत', '₹${res.finalPrice.toStringAsFixed(0)}'),
              const SizedBox(height: 6),
              _buildDetailRow('हॅश कोड', '${res.recordHash.substring(0, 16)}...'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Downstream Timeline
        DownstreamTimelineWidget(
          currentStatus: 'received',
          locale: locale,
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            key: const Key('done_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greenGoEarn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('पूर्ण (Done)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
