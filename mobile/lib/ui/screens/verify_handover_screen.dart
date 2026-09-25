import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/handover/offline_handover_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../widgets/big_keypad.dart';
import '../widgets/downstream_timeline_widget.dart';

class VerifyHandoverScreen extends StatefulWidget {
  const VerifyHandoverScreen({
    super.key,
    required this.db,
    required this.audioService,
    this.initialRefNo,
    this.locale = 'mr',
  });

  final AppDatabase db;
  final AudioFeedbackService audioService;
  final String? initialRefNo;
  final String locale;

  @override
  State<VerifyHandoverScreen> createState() => _VerifyHandoverScreenState();
}

class _VerifyHandoverScreenState extends State<VerifyHandoverScreen> {
  late String _refInput;
  bool _hasSearched = false;
  LocalTraceabilityData? _traceData;
  LocalTransaction? _txData;
  bool _isSignatureValid = false;

  @override
  void initState() {
    super.initState();
    _refInput = widget.initialRefNo ?? '';
    if (_refInput.isNotEmpty) {
      _verifyCode();
    }
  }

  void _onCharPressed(String char) {
    if (_refInput.length < 6) {
      HapticService.lightImpact();
      setState(() {
        _refInput += char.toUpperCase();
      });
    }
  }

  void _onBackspacePressed() {
    if (_refInput.isNotEmpty) {
      HapticService.lightImpact();
      setState(() {
        _refInput = _refInput.substring(0, _refInput.length - 1);
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_refInput.isEmpty) return;
    await HapticService.mediumImpact();

    final cleanRef = _refInput.trim().toUpperCase();
    final traceQuery = widget.db.select(widget.db.localTraceability)
      ..where((t) => t.handoverRefNo.equals(cleanRef));
    final traceRow = await traceQuery.getSingleOrNull();

    LocalTransaction? txRow;
    bool isValid = false;

    if (traceRow != null) {
      final txQuery = widget.db.select(widget.db.localTransactions)
        ..where((t) => t.lotId.equals(traceRow.lotId));
      txRow = await txQuery.getSingleOrNull();
      isValid = OfflineHandoverService.verifyPayloadSignature(traceRow.qrPayload);
    }

    if (mounted) {
      setState(() {
        _hasSearched = true;
        _traceData = traceRow;
        _txData = txRow;
        _isSignatureValid = isValid;
      });

      if (traceRow != null && isValid) {
        unawaited(widget.audioService.speakCustomText(
          widget.locale == 'hi'
              ? 'हस्तांतरण कोड सत्यापित है। रिकॉर्ड सुरक्षित है।'
              : 'हस्तांतरण कोड प्रमाणित आहे. सर्व नोंदी सुरक्षित आहेत.',
        ));
      } else {
        unawaited(widget.audioService.speakCustomText(
          widget.locale == 'hi'
              ? 'यह संदर्भ कोड अमान्य है।'
              : 'हा संदर्भ क्रमांक अमान्य आहे.',
        ));
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
              ? 'हस्तांतरण सत्यापन (Verify Handover)'
              : (locale == 'en' ? 'Verify Handover' : 'हस्तांतरण पडताळणी (Verify Handover)'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Code Display & Input box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      locale == 'hi'
                          ? '6-अक्षरी संदर्भ कोड दर्ज करें'
                          : '६-अक्षरी संदर्भ क्रमांक टाका',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      key: const Key('verify_ref_input_display'),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Text(
                        _refInput.isEmpty ? '------' : _refInput.split('').join(' '),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        key: const Key('verify_ref_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenGoEarn,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _verifyCode,
                        icon: const Icon(Icons.search_rounded, size: 24),
                        label: Text(
                          locale == 'hi' ? 'सत्यापित करें (Verify)' : 'पडताळणी करा (Verify)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alphanumeric Keypad Helper if empty
              if (!_hasSearched)
                BigKeypad(
                  onDigitPressed: _onCharPressed,
                  onBackspacePressed: _onBackspacePressed,
                  onSubmitPressed: _verifyCode,
                ),

              // Verification Results
              if (_hasSearched) ...[
                if (_traceData == null)
                  _buildNotFoundCard(locale)
                else
                  _buildResultCard(locale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundCard(String locale) {
    return Container(
      key: const Key('verify_not_found_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 48),
          const SizedBox(height: 10),
          Text(
            locale == 'hi'
                ? 'संदर्भ कोड सापडला नाही / अमान्य'
                : 'संदर्भ क्रमांक सापडला नाही / अमान्य',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
          ),
          const SizedBox(height: 6),
          Text(
            locale == 'hi'
                ? 'कृपया संदर्भ कोड तपासा आणि पुन्हा प्रयत्न करा.'
                : 'कृपया संदर्भ कोड तपासून पुन्हा प्रयत्न करा.',
            style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String locale) {
    final t = _traceData!;
    final tx = _txData;
    final isDisputed = tx?.anomalyFlag ?? false;

    return Column(
      children: [
        Container(
          key: const Key('verify_result_card'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDisputed
                  ? const Color(0xFFF59E0B)
                  : (_isSignatureValid ? AppTheme.greenGoEarn : const Color(0xFFDC2626)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Integrity status badge
              Container(
                key: const Key('integrity_status_badge'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDisputed
                      ? const Color(0xFFFEF3C7)
                      : (_isSignatureValid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDisputed
                          ? Icons.warning_amber_rounded
                          : (_isSignatureValid ? Icons.verified_rounded : Icons.gpp_bad_rounded),
                      color: isDisputed
                          ? const Color(0xFFD97706)
                          : (_isSignatureValid ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDisputed
                          ? 'विवादित व्यवहार (Disputed Weight)'
                          : (_isSignatureValid
                              ? 'प्रमाणित व सुरक्षित (Tamper-Free & Verified)'
                              : 'अवैध सही / छेडछाड झालेला कोड'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDisputed
                            ? const Color(0xFF92400E)
                            : (_isSignatureValid ? const Color(0xFF166534) : const Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildInfoRow('संदर्भ कोड (Ref)', t.handoverRefNo),
              const SizedBox(height: 6),
              _buildInfoRow('लॉट आयडी (Lot)', t.lotId),
              const SizedBox(height: 6),
              _buildInfoRow('कलेक्टर वजन', '${t.weightKg.toStringAsFixed(1)} kg'),
              if (tx?.finalPrice != null) ...[
                const SizedBox(height: 6),
                _buildInfoRow('अंतिम किंमत', '₹${tx!.finalPrice!.toStringAsFixed(0)}'),
              ],
              const SizedBox(height: 6),
              _buildInfoRow('रीसायकलर पुष्टी', t.recyclerConfirmation ? 'होय (Confirmed)' : 'प्रलंबित (Pending)'),
              const SizedBox(height: 6),
              _buildInfoRow('हॅश कोड', '${t.recordHash.substring(0, 16)}...'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Downstream Timeline
        DownstreamTimelineWidget(
          currentStatus: t.downstreamStatus,
          locale: locale,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
