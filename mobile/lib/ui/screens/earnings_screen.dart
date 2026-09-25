import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/pdf/pdf_statement_generator.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/repositories/ledger_repository.dart';
import '../widgets/speaker_button.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({
    super.key,
    required this.db,
    required this.audioService,
    this.collectorId = 'KC-C-TEST01',
    this.locale = 'mr',
    this.ledgerRepository,
    this.onPdfExported,
  });

  final AppDatabase db;
  final AudioFeedbackService audioService;
  final String collectorId;
  final String locale;
  final LedgerRepository? ledgerRepository;
  final ValueChanged<String>? onPdfExported;

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late final LedgerRepository _ledgerRepo;
  bool _isLoading = true;
  EarningsOverviewData? _overview;
  bool _showUpiModal = false;
  double _selectedUpiAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _ledgerRepo = widget.ledgerRepository ?? LedgerRepository(widget.db);
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    final data = await _ledgerRepo.getDetailedOverview(widget.collectorId);
    if (mounted) {
      setState(() {
        _overview = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMarkCashReceived(LedgerItemDetail item) async {
    await HapticService.heavyImpact();
    await _ledgerRepo.markCashReceivedOffline(
      entryId: item.entryId,
      collectorId: widget.collectorId,
      lotId: item.lotId,
    );

    unawaited(widget.audioService.speakCustomText(
      widget.locale == 'hi' ? 'पैसे मिल गए' : 'पैसे मिळाले',
    ));

    await _loadOverview();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.locale == 'hi'
                ? 'नकद भुगतान दर्ज किया गया (पैसे मिल गए)'
                : 'रोख रक्कम मिळाली म्हणून नोंदवली गेली (पैसे मिळाले)',
          ),
          backgroundColor: AppTheme.greenGoEarn,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportPdfStatement() async {
    await HapticService.selectionClick();
    if (_overview == null) return;

    final now = DateTime.now();
    final fromDate = now.subtract(const Duration(days: 30));
    final refNo = 'STMT-KC-${now.month}${now.day}-${_overview!.transactions.length}';

    try {
      final file = await PdfStatementGenerator.generateEarningsStatementPdf(
        collectorId: widget.collectorId,
        statementRefNo: refNo,
        fromDate: fromDate,
        toDate: now,
        totalEarned: _overview!.allTimeTotal,
        cashReceived: _overview!.receivedAmount,
        pendingAmount: _overview!.pendingAmount,
        items: _overview!.transactions,
        locale: widget.locale,
      );

      widget.onPdfExported?.call(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.locale == 'hi'
                  ? 'कमाई विवरण PDF तैयार हो गया!'
                  : 'कमाई पावती PDF तयार झाली!',
            ),
            backgroundColor: AppTheme.greenGoEarn,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _speakTransaction(LedgerItemDetail item) {
    final statusText = item.paymentStatus == 'cash_received'
        ? (widget.locale == 'hi' ? 'नकद प्राप्त' : 'रोख मिळाली')
        : (item.paymentStatus == 'disputed'
            ? (widget.locale == 'hi' ? 'विवादित' : 'विवादित')
            : (widget.locale == 'hi' ? 'भुगतान बाकी' : 'रक्कम येणे बाकी'));

    final speech = widget.locale == 'hi'
        ? '${item.category}: ${item.weightKg} किलो, ${item.recyclerName} से ${item.amount.toStringAsFixed(0)} रुपये, स्थिति: $statusText'
        : '${item.category}: ${item.weightKg} किलो, ${item.recyclerName} कडून ${item.amount.toStringAsFixed(0)} रुपये, स्थिती: $statusText';

    unawaited(widget.audioService.speakCustomText(speech));
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pcb') || cat.contains('circuit')) return Icons.memory_rounded;
    if (cat.contains('batt')) return Icons.battery_charging_full_rounded;
    if (cat.contains('cable') || cat.contains('wire')) return Icons.cable_rounded;
    if (cat.contains('crt') || cat.contains('tv')) return Icons.tv_rounded;
    if (cat.contains('lcd') || cat.contains('screen')) return Icons.tablet_rounded;
    if (cat.contains('motor')) return Icons.electric_meter_rounded;
    return Icons.recycling_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'hi'
              ? 'मेरी कमाई व हिसाब (Earnings)'
              : (locale == 'en' ? 'My Earnings & Ledger' : 'माझी कमाई व हिशोब (Earnings)'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          SpeakerButton(
            promptKey: 'tabEarnings',
            audioService: widget.audioService,
            tooltip: 'कमाई माहिती ऐका',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOverview,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Three Big Summary Tiles at Top
                    _buildThreeSummaryTiles(locale),
                    const SizedBox(height: 16),

                    // 2. Green/Red Visual Split Bar (Received vs Pending)
                    _buildSplitBar(locale),
                    const SizedBox(height: 16),

                    // 3. Pending Dues Section (If any)
                    if (_overview!.pendingAmount > 0) ...[
                      _buildPendingDuesCard(locale),
                      const SizedBox(height: 16),
                    ],

                    // 4. Action Buttons (PDF Export & Optional UPI)
                    _buildActionButtons(locale),
                    const SizedBox(height: 16),

                    // 5. Optional UPI Modal / Card (Hidden by default!)
                    if (_showUpiModal) ...[
                      _buildUpiPaymentCard(locale),
                      const SizedBox(height: 16),
                    ],

                    // 6. Transaction List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale == 'hi' ? 'हालिया लेनदेन (Transactions)' : 'अलीकडील व्यवहार (Transactions)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${_overview!.transactions.length} नोंदी',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 7. Transaction List
                    if (_overview!.transactions.isEmpty)
                      _buildEmptyState(locale)
                    else
                      ..._overview!.transactions.map((tx) => _buildTransactionCard(tx, locale)),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Three Big Summary Tiles: Today, This Week, This Month
  // ---------------------------------------------------------------------------
  Widget _buildThreeSummaryTiles(String locale) {
    final ov = _overview!;

    return Row(
      children: [
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_today'),
            title: locale == 'hi' ? 'आज' : (locale == 'en' ? 'Today' : 'आज'),
            amount: ov.todayTotal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_week'),
            title: locale == 'hi' ? 'इस हफ्ते' : (locale == 'en' ? 'This Week' : 'या आठवड्यात'),
            amount: ov.weekTotal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_month'),
            title: locale == 'hi' ? 'इस महीने' : (locale == 'en' ? 'This Month' : 'या महिन्यात'),
            amount: ov.monthTotal,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTile({required Key key, required String title, required double amount}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.greenGoEarn,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Visual Green / Red Split Bar (Received vs Pending)
  // ---------------------------------------------------------------------------
  Widget _buildSplitBar(String locale) {
    final ov = _overview!;
    final total = ov.receivedAmount + ov.pendingAmount;
    final receivedRatio = total > 0 ? (ov.receivedAmount / total).clamp(0.0, 1.0) : 1.0;
    final pendingRatio = 1.0 - receivedRatio;

    return Container(
      key: const Key('earnings_split_bar'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'hi' ? 'भुगतान स्थिति (Payment Status)' : 'पेमेंट स्थिती (Payment Status)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'एकूण: ₹${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stacked horizontal proportional bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: (receivedRatio * 100).round(),
                    child: Container(color: AppTheme.greenGoEarn),
                  ),
                  if (pendingRatio > 0.01)
                    Expanded(
                      flex: (pendingRatio * 100).round(),
                      child: Container(color: const Color(0xFFDC2626)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Split labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.greenGoEarn, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    '${locale == 'hi' ? 'रोख मिळाले' : 'मिळाले'}: ₹${ov.receivedAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.greenGoEarn),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    '${locale == 'hi' ? 'बाकी' : 'येणे बाकी'}: ₹${ov.pendingAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Pending Dues Card with Recycler Contact Button
  // ---------------------------------------------------------------------------
  Widget _buildPendingDuesCard(String locale) {
    final ov = _overview!;

    return Container(
      key: const Key('pending_dues_section'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locale == 'hi'
                      ? 'बाकी रक्कम (Pending Dues: ${ov.pendingDuesCount} लॉट)'
                      : 'रक्कम येणे बाकी (${ov.pendingDuesCount} व्यवहार प्रलंबित)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                ),
              ),
              Text(
                '₹${ov.pendingAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            locale == 'hi'
                ? 'रीसायकलर से नकद प्राप्त होने पर "पैसे मिले" बटन दबाएं।'
                : 'रीसायकलरकडून रोख रक्कम मिळाल्यावर खालील "पैसे मिळाले" बटण दाबा.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Action Buttons (PDF Export & Pay via UPI Toggle)
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons(String locale) {
    return Row(
      children: [
        // Export PDF Statement
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              key: const Key('export_pdf_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _exportPdfStatement,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
              label: Text(
                locale == 'hi' ? 'PDF विवरण (Statement)' : 'पावती PDF (Statement)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Optional UPI Toggle Button (Never shown by default!)
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              key: const Key('toggle_upi_button'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _showUpiModal ? const Color(0xFF2563EB) : Colors.grey.shade400,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                HapticService.selectionClick();
                setState(() {
                  _showUpiModal = !_showUpiModal;
                  if (_showUpiModal && _overview!.transactions.isNotEmpty) {
                    final first = _overview!.transactions.first;
                    _selectedUpiAmount = first.amount;
                  }
                });
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB), size: 22),
              label: Text(
                locale == 'hi' ? 'UPI से भुगतान' : 'UPI पेमेंट',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Optional UPI Payment Card (Rendered only on explicit toggle)
  // ---------------------------------------------------------------------------
  Widget _buildUpiPaymentCard(String locale) {
    final amt = _selectedUpiAmount > 0 ? _selectedUpiAmount : 1500.0;
    final upiUri = 'upi://pay?pa=collector.kabadiwala@upi&pn=Kabadiwala%20Connect&am=${amt.toStringAsFixed(2)}&cu=INR&tn=E-Waste%20Handover';

    return Container(
      key: const Key('upi_payment_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'UPI क्यूआर कोड (Optional UPI)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _showUpiModal = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            key: const Key('upi_qr_code'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QrImageView(
              data: upiUri,
              version: QrVersions.auto,
              size: 160.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'रक्कम: ₹${amt.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'collector.kabadiwala@upi',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Transaction Row Card
  // ---------------------------------------------------------------------------
  Widget _buildTransactionCard(LedgerItemDetail tx, String locale) {
    final isPending = tx.paymentStatus == 'pending';
    final isDisputed = tx.paymentStatus == 'disputed';

    Color statusColor = AppTheme.greenGoEarn;
    Color statusBg = const Color(0xFFDCFCE7);
    String statusLabel = locale == 'hi' ? 'रोख मिळाली' : 'रोख मिळाली';

    if (isPending) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusLabel = locale == 'hi' ? 'बाकी (Pending)' : 'बाकी (Pending)';
    } else if (isDisputed) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
      statusLabel = locale == 'hi' ? 'विवादित (Disputed)' : 'विवादित (Disputed)';
    }

    return Container(
      key: Key('transaction_item_${tx.entryId}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? const Color(0xFFFBBF24) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(tx.category),
                  color: isPending ? const Color(0xFFD97706) : AppTheme.greenGoEarn,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Recycler Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.category,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.recyclerName,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.weightKg.toStringAsFixed(1)} kg • ${_fmtDate(tx.recordedAt)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              // Rupee Amount and Speaker Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${tx.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isPending ? const Color(0xFFD97706) : AppTheme.greenGoEarn,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Payment Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),

              // Tap-to-hear Speaker Button
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn, size: 22),
                tooltip: 'ऐका',
                onPressed: () => _speakTransaction(tx),
              ),
            ],
          ),

          // If pending: Show One-Tap "Mark as Cash Received" button & Contact button
          if (isPending) ...[
            const Divider(height: 20),
            Row(
              children: [
                // Contact Recycler Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    key: const Key('contact_recycler_button'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      HapticService.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${tx.recyclerName}: ${tx.recyclerPhone ?? "+91 98200 12345"}')),
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, size: 16, color: AppTheme.textHighContrast),
                    label: Text(
                      locale == 'hi' ? 'फोन करें' : 'संपर्क',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textHighContrast),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Mark Cash Received Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    key: Key('mark_cash_button_${tx.entryId}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenGoEarn,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleMarkCashReceived(tx),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: Text(
                      locale == 'hi' ? 'पैसे मिले (Cash)' : 'पैसे मिळाले (Cash)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            locale == 'hi' ? 'अभी कोई लेनदेन दर्ज नहीं है।' : 'अद्याप कोणतेही व्यवहार नाहीत.',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
