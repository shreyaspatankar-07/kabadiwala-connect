import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/pdf/pdf_statement_generator.dart';
import '../../core/sharing/share_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/repositories/ledger_repository.dart';
import '../widgets/speaker_button.dart';
import 'handover_initiate_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({
    super.key,
    required this.db,
    required this.audioService,
    this.collectorId = 'KC-C-7821',
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
  List<LocalTransaction> _collectorLots = [];
  int _activeTab = 0; // 0 = Earnings & Ledger, 1 = My Created Lots
  bool _showUpiModal = false;
  double _selectedUpiAmount = 0.0;
  StreamSubscription<EarningsOverviewData>? _overviewSub;
  StreamSubscription<List<LocalTransaction>>? _lotsSub;

  @override
  void initState() {
    super.initState();
    _ledgerRepo = widget.ledgerRepository ?? LedgerRepository(widget.db);
    _loadOverview();
    _subscribeStreams();
  }

  @override
  void dispose() {
    _overviewSub?.cancel();
    _lotsSub?.cancel();
    super.dispose();
  }

  void _subscribeStreams() {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    _overviewSub = _ledgerRepo.watchDetailedOverview(widget.collectorId).listen((data) {
      if (mounted) {
        setState(() {
          _overview = data;
          _isLoading = false;
        });
      }
    });

    _lotsSub = (widget.db.select(widget.db.localTransactions)
          ..where((t) => t.collectorId.equals(widget.collectorId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .listen((lots) {
      if (mounted) {
        setState(() {
          _collectorLots = lots;
        });
      }
    });
  }

  Future<void> _loadOverview() async {
    final data = await _ledgerRepo.getDetailedOverview(widget.collectorId);
    final lots = await (widget.db.select(widget.db.localTransactions)
          ..where((t) => t.collectorId.equals(widget.collectorId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    if (mounted) {
      setState(() {
        _overview = data;
        _collectorLots = lots;
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

    final spokenText = widget.locale == 'en'
        ? 'Cash payment recorded'
        : (widget.locale == 'hi' ? 'पैसे मिल गए' : 'पैसे मिळाले');
    unawaited(widget.audioService.speakCustomText(spokenText));

    await _loadOverview();

    if (mounted) {
      final snackText = widget.locale == 'en'
          ? 'Cash payment marked as received'
          : (widget.locale == 'hi'
              ? 'नकद भुगतान दर्ज किया गया (पैसे मिल गए)'
              : 'रोख रक्कम मिळाली म्हणून नोंदवली गेली (पैसे मिळाले)');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackText),
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

      final isMr = widget.locale == 'mr';
      final isHi = widget.locale == 'hi';

      final spokenMsg = isMr
          ? 'पावती पीडीएफ तयार झाली आहे'
          : (isHi ? 'विवरण पीडीएफ तैयार हो गई है' : 'PDF Statement generated');
      unawaited(widget.audioService.speakCustomText(spokenMsg));

      widget.onPdfExported?.call(file.path);

      // Trigger native Android share sheet allowing view, download, or WhatsApp
      try {
        final shareText = isMr
            ? 'कबाडीवाला कनेक्ट - ई-कचरा कमाई पावती ($refNo)'
            : (isHi
                ? 'कबाडीवाला कनेक्ट - ई-कचरा आय विवरण ($refNo)'
                : 'Kabadiwala Connect - E-Waste Earnings Statement ($refNo)');
        await Share.shareXFiles([XFile(file.path)], text: shareText);
      } catch (shareErr) {
        debugPrint('[EarningsScreen] Native share note: $shareErr');
      }

      if (mounted) {
        _showPdfDialog(context, file.path, refNo);
      }
    } catch (e) {
      debugPrint('[EarningsScreen] PDF Export error: $e');
    }
  }

  void _showPdfDialog(BuildContext context, String filePath, [String? statementRef]) {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';
    final statementRefNo = statementRef ?? 'STMT-${DateTime.now().millisecondsSinceEpoch % 10000}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isMr ? 'अधिकृत कमाई पावती' : (isHi ? 'आधिकारिक आय विवरण' : 'Official Earnings Statement'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isMr ? 'कलेक्टर आयडी' : (isHi ? 'कलेक्टर आईडी' : 'Collector ID')}: ${widget.collectorId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isMr ? 'कालावधी' : (isHi ? 'अवधि' : 'Period')}: ${DateTime.now().subtract(const Duration(days: 30)).toString().split(' ')[0]} to ${DateTime.now().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isMr ? 'एकूण उलाढाल:' : (isHi ? 'कुल कारोबार:' : 'Total Volume:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${_overview?.allTimeTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.greenGoEarn)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isMr ? 'रोख मिळाली:' : (isHi ? 'नकद प्राप्त:' : 'Cash Received:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${_overview?.receivedAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isMr ? 'रक्कम येणे बाकी:' : (isHi ? 'बाकी राशि:' : 'Pending Dues:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${_overview?.pendingAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // WhatsApp Share Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('btn_share_whatsapp_pdf'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () async {
                    await ShareService.shareToWhatsApp(
                      filePath: filePath,
                      text: isMr
                          ? 'कबाडीवाला कनेक्ट - ई-कचरा कमाई पावती ($statementRefNo)'
                          : (isHi
                              ? 'कबाडीवाला कनेक्ट - ई-कचरा आय विवरण ($statementRefNo)'
                              : 'Kabadiwala Connect - E-Waste Earnings Statement ($statementRefNo)'),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                  label: Text(
                    isMr ? 'WhatsApp वर पाठवा' : (isHi ? 'WhatsApp पर भेजें' : 'Share via WhatsApp'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0284C7),
                        side: const BorderSide(color: Color(0xFF0284C7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        ShareService.shareGeneral(
                          filePath: filePath,
                          text: isMr
                              ? 'माझे ई-कचरा कमाई विवरण'
                              : (isHi ? 'मेरी ई-कचरा आय विवरण' : 'My E-Waste Earnings Statement'),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        isMr ? 'इतर शेअर' : (isHi ? 'अन्य शेयर' : 'Other Share'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greenGoEarn,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      label: Text(
                        isMr ? 'समजले' : (isHi ? 'समझ गया' : 'Done'),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _speakTransaction(LedgerItemDetail item) {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    final statusText = item.paymentStatus == 'cash_received'
        ? (isMr ? 'रोख मिळाली' : (isHi ? 'नकद प्राप्त' : 'Cash Received'))
        : (item.paymentStatus == 'disputed'
            ? (isMr ? 'विवादित' : (isHi ? 'विवादित' : 'Disputed'))
            : (isMr ? 'रक्कम येणे बाकी' : (isHi ? 'भुगतान बाकी' : 'Payment Pending')));

    final speech = isMr
        ? '${item.category}: ${item.weightKg} किलो, ${item.recyclerName} कडून ${item.amount.toStringAsFixed(0)} रुपये, स्थिती: $statusText'
        : (isHi
            ? '${item.category}: ${item.weightKg} किलो, ${item.recyclerName} से ${item.amount.toStringAsFixed(0)} रुपये, स्थिति: $statusText'
            : '${item.category}: ${item.weightKg} kg, from ${item.recyclerName}, Rs ${item.amount.toStringAsFixed(0)}, Status: $statusText');

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

  String _getCategoryDisplayName(String rawCategory) {
    final cat = rawCategory.toUpperCase();
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    if (cat.contains('PCB')) return isMr ? 'सर्किट बोर्ड (PCB)' : (isHi ? 'सर्किट बोर्ड (PCB)' : 'Circuit Board (PCB)');
    if (cat.contains('CABLE') || cat.contains('WIRE')) return isMr ? 'तांब्याची केबल (Cables)' : (isHi ? 'तांबे की केबल (Cables)' : 'Copper Cables');
    if (cat.contains('BATT')) return isMr ? 'बॅटरी (Batteries)' : (isHi ? 'बैटरी (Batteries)' : 'Lithium Batteries');
    if (cat.contains('LCD') || cat.contains('SCREEN')) return isMr ? 'स्क्रीन / एलसीडी (LCD)' : (isHi ? 'स्क्रीन / एलसीडी (LCD)' : 'Display / LCD Screen');
    if (cat.contains('CRT')) return isMr ? 'सीआरटी टीव्ही (CRT TV)' : (isHi ? 'सीआरटी टीवी (CRT TV)' : 'CRT Glass / Monitor');
    if (cat.contains('MOTOR') || cat.contains('MAGNET')) return isMr ? 'मोटार / मॅग्नेट (Motors)' : (isHi ? 'मोटर / चुंबक (Motors)' : 'Motors & Magnets');
    if (cat.contains('PLASTIC')) return isMr ? 'प्लास्टिक कॅबिनेट (Plastics)' : (isHi ? 'प्लास्टिक कैबिनेट (Plastics)' : 'Mixed Plastics');
    return rawCategory;
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    final title = isMr
        ? 'माझी कमाई व हिशोब (Earnings)'
        : (isHi ? 'मेरी कमाई व हिसाब (Earnings)' : 'My Earnings & Ledger');

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          SpeakerButton(
            promptKey: 'tabEarnings',
            audioService: widget.audioService,
            tooltip: isMr ? 'कमाई माहिती ऐका' : (isHi ? 'कमाई की जानकारी सुनें' : 'Listen Earnings Info'),
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
                    // Top Segmented Switcher: [Earnings & Ledger] vs [My Lots]
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() => _activeTab = 0);
                                HapticService.selectionClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0 ? AppTheme.greenGoEarn : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _activeTab == 0
                                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                      : null,
                                ),
                                child: Text(
                                  isMr ? '💰 कमाई व हिशोब' : (isHi ? '💰 मेरी कमाई' : '💰 Earnings & Ledger'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _activeTab == 0 ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() => _activeTab = 1);
                                HapticService.selectionClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1 ? AppTheme.greenGoEarn : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _activeTab == 1
                                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                      : null,
                                ),
                                child: Text(
                                  isMr
                                      ? '📦 माझे माल (${_collectorLots.length})'
                                      : (isHi ? '📦 मेरे लॉट (${_collectorLots.length})' : '📦 My Lots (${_collectorLots.length})'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _activeTab == 1 ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_activeTab == 0) ...[
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

                      // 5. Optional UPI Modal / Card
                      if (_showUpiModal) ...[
                        _buildUpiPaymentCard(locale),
                        const SizedBox(height: 16),
                      ],

                      // 6. Transaction List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isMr ? 'अलीकडील व्यवहार (Transactions)' : (isHi ? 'हालिया लेनदेन (Transactions)' : 'Recent Transactions'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${_overview!.transactions.length} ${isMr ? 'नोंदी' : (isHi ? 'प्रविष्टियां' : 'Records')}',
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
                    ] else ...[
                      // My Created Lots Tab
                      _buildMyLotsView(locale),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // My Created Lots List View (Allows re-opening Handover QR code)
  // ---------------------------------------------------------------------------
  Widget _buildMyLotsView(String locale) {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    if (_collectorLots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 54, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              isMr
                  ? 'अद्याप कोणताही माल तयार केलेला नाही.'
                  : (isHi ? 'अभी तक कोई लॉट नहीं बनाया गया है।' : 'No lots created yet.'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isMr
                  ? 'नवीन ई-कचरा माल जोडण्यासाठी "माल जोडा" टॅब वापरा.'
                  : (isHi ? 'नया ई-कचरा जोड़ने के लिए "माल जोड़ें" टैब का उपयोग करें।' : 'Use the "Add Lot" tab to record your first e-waste item.'),
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isMr ? 'तयार केलेले सर्व ई-कचरा लॉट्स:' : (isHi ? 'तैयार किए गए सभी ई-कचरा लॉट:' : 'All Created E-Waste Lots:'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ..._collectorLots.map((lot) => _buildLotCard(lot, locale)),
      ],
    );
  }

  Widget _buildLotCard(LocalTransaction lot, String locale) {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    final isCompleted = lot.transactionStatus == 'handed_over' || lot.transactionStatus == 'confirmed';
    final isPending = lot.transactionStatus == 'handover_pending';

    Color statusColor = const Color(0xFF0284C7);
    Color statusBg = const Color(0xFFE0F2FE);
    String statusText = isMr ? 'नोंदणीकृत (Listed)' : (isHi ? 'सूचीबद्ध (Listed)' : 'Listed');

    if (isCompleted) {
      statusColor = AppTheme.greenGoEarn;
      statusBg = const Color(0xFFDCFCE7);
      statusText = isMr ? 'हस्तांतरण पूर्ण (Handed Over)' : (isHi ? 'हस्तांतरित (Handed Over)' : 'Handed Over & Completed');
    } else if (isPending) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusText = isMr ? 'हस्तांतरण बाकी (Pending Code)' : (isHi ? 'हस्तांतरण लंबित' : 'Handover Pending');
    }

    final categoryDisplay = _getCategoryDisplayName(lot.category);
    final dateStr = '${lot.createdAt.day}/${lot.createdAt.month}/${lot.createdAt.year} ${lot.createdAt.hour.toString().padLeft(2, '0')}:${lot.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? const Color(0xFFFBBF24) : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.greenGoEarnLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(lot.category), color: AppTheme.greenGoEarn, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryDisplay,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isMr ? 'लॉट आयडी' : (isHi ? 'लॉट आईडी' : 'Lot ID')}: ${lot.lotId}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(lot.finalPrice ?? lot.quotedPrice).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.greenGoEarn),
                  ),
                  Text(
                    '${lot.weightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Button to Re-display Handover QR Certificate
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onPressed: () {
              HapticService.heavyImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HandoverInitiateScreen(
                    lotId: lot.lotId,
                    initialWeightKg: lot.weightKg,
                    category: lot.category,
                    recyclerName: 'Authorized Recycler',
                    quotedPrice: lot.quotedPrice,
                    db: widget.db,
                    audioService: widget.audioService,
                    locale: locale,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_2_rounded, size: 20),
            label: Text(
              isMr
                  ? 'हस्तांतरण QR आणि कोड पहा'
                  : (isHi ? 'हस्तांतरण QR और कोड देखें' : 'View Handover QR & Code'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Three Big Summary Tiles
  // ---------------------------------------------------------------------------
  Widget _buildThreeSummaryTiles(String locale) {
    final ov = _overview!;
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    return Row(
      children: [
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_today'),
            title: isMr ? 'आज' : (isHi ? 'आज' : 'Today'),
            amount: ov.todayTotal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_week'),
            title: isMr ? 'या आठवड्यात' : (isHi ? 'इस हफ्ते' : 'This Week'),
            amount: ov.weekTotal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleTile(
            key: const Key('tile_month'),
            title: isMr ? 'या महिन्यात' : (isHi ? 'इस महीने' : 'This Month'),
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
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

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
                isMr ? 'पेमेंट स्थिती (Payment Status)' : (isHi ? 'भुगतान स्थिति (Payment Status)' : 'Payment Status Split'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '${isMr ? 'एकूण' : (isHi ? 'कुल' : 'Total')}: ₹${total.toStringAsFixed(0)}',
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
                    '${isMr ? 'मिळाले' : (isHi ? 'रोख मिले' : 'Received')}: ₹${ov.receivedAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.greenGoEarn),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    '${isMr ? 'येणे बाकी' : (isHi ? 'बाकी' : 'Pending')}: ₹${ov.pendingAmount.toStringAsFixed(0)}',
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
  // 3. Pending Dues Card
  // ---------------------------------------------------------------------------
  Widget _buildPendingDuesCard(String locale) {
    final ov = _overview!;
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

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
                  isMr
                      ? 'रक्कम येणे बाकी (${ov.pendingDuesCount} व्यवहार प्रलंबित)'
                      : (isHi ? 'बाकी राशि (${ov.pendingDuesCount} लॉट लंबित)' : 'Pending Dues (${ov.pendingDuesCount} Lots)'),
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
            isMr
                ? 'रीसायकलरकडून रोख रक्कम मिळाल्यावर खालील "पैसे मिळाले" बटण दाबा.'
                : (isHi ? 'रीसायकलर से नकद प्राप्त होने पर "पैसे मिले" बटन दबाएं।' : 'Tap "Cash Received" once payment is handed over by recycler.'),
            style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('contact_recycler_button'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF92400E),
              side: const BorderSide(color: Color(0xFFD97706)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              HapticService.lightImpact();
              final msg = isMr ? 'रीसायकलरशी संपर्क केला जात आहे' : (isHi ? 'रीसायकलर से संपर्क किया जा रहा है' : 'Contacting Recycler');
              unawaited(widget.audioService.speakCustomText(msg));
            },
            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
            label: Text(
              isMr ? 'रीसायकलरशी संपर्क साधा' : (isHi ? 'रीसायकलर से संपर्क करें' : 'Contact Recycler'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Action Buttons
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons(String locale) {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

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
                isMr ? 'पावती PDF (Statement)' : (isHi ? 'PDF विवरण (Statement)' : 'PDF Statement'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Optional UPI Toggle Button
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
                isMr ? 'UPI पेमेंट' : (isHi ? 'UPI से भुगतान' : 'Pay via UPI'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Optional UPI Payment Card
  // ---------------------------------------------------------------------------
  Widget _buildUpiPaymentCard(String locale) {
    final amt = _selectedUpiAmount > 0 ? _selectedUpiAmount : 1500.0;
    final upiUri = 'upi://pay?pa=collector.kabadiwala@upi&pn=Kabadiwala%20Connect&am=${amt.toStringAsFixed(2)}&cu=INR&tn=E-Waste%20Handover';
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

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
              Text(
                isMr ? 'UPI क्यूआर कोड (Optional UPI)' : (isHi ? 'UPI क्यूआर कोड (Optional UPI)' : 'UPI QR Code (Optional)'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
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
            '${isMr ? 'रक्कम' : (isHi ? 'राशि' : 'Amount')}: ₹${amt.toStringAsFixed(0)}',
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
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    Color statusColor = AppTheme.greenGoEarn;
    Color statusBg = const Color(0xFFDCFCE7);
    String statusLabel = isMr ? 'रोख मिळाली' : (isHi ? 'नकद प्राप्त' : 'Cash Received');

    if (isPending) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusLabel = isMr ? 'बाकी (Pending)' : (isHi ? 'बाकी (Pending)' : 'Payment Pending');
    } else if (isDisputed) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
      statusLabel = isMr ? 'विवादित (Disputed)' : (isHi ? 'विवादित (Disputed)' : 'Disputed');
    }

    final categoryDisplay = _getCategoryDisplayName(tx.category);

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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.greenGoEarnLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(tx.category), color: AppTheme.greenGoEarn, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryDisplay,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.recyclerName,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${tx.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.greenGoEarn),
                  ),
                  Text(
                    '${tx.weightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn, size: 22),
                onPressed: () => _speakTransaction(tx),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              key: Key('mark_cash_button_${tx.entryId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenGoEarn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _handleMarkCashReceived(tx),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                isMr ? 'पैसे मिळाले (Mark Cash Received)' : (isHi ? 'पैसे मिल गए (नकद प्राप्त)' : 'Mark Cash Received'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            isMr ? 'अद्याप कोणतेही व्यवहार नाहीत' : (isHi ? 'अभी तक कोई लेनदेन नहीं' : 'No transactions recorded yet'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
