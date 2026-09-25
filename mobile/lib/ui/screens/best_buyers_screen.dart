import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/matching/offline_matching_engine.dart';
import '../../data/repositories/recycler_repository.dart';

class BestBuyersScreen extends StatefulWidget {
  const BestBuyersScreen({
    super.key,
    required this.lot,
    required this.audioService,
    required this.db,
    this.locale = 'mr',
    this.recyclerRepository,
    this.overrideCandidates,
    this.onBuyerSelected,
    this.autoSpeakTopResult = true,
  });

  final OfflineLotInput lot;
  final AudioFeedbackService audioService;
  final AppDatabase db;
  final String locale;
  final RecyclerRepository? recyclerRepository;
  final List<RecyclerCandidateData>? overrideCandidates;
  final ValueChanged<RankedRecyclerResult>? onBuyerSelected;
  final bool autoSpeakTopResult;

  @override
  State<BestBuyersScreen> createState() => _BestBuyersScreenState();
}

class _BestBuyersScreenState extends State<BestBuyersScreen> {
  late final RecyclerRepository _repository;
  bool _isLoading = true;
  List<RankedRecyclerResult> _buyers = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.recyclerRepository ?? RecyclerRepository(widget.db);
    _loadMatches();
  }

  @override
  void didUpdateWidget(covariant BestBuyersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overrideCandidates != widget.overrideCandidates ||
        oldWidget.lot.category != widget.lot.category) {
      _loadMatches();
    }
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final results = await _repository.getBestBuyers(
      widget.lot,
      overrideCandidates: widget.overrideCandidates,
    );

    if (mounted) {
      setState(() {
        _buyers = results;
        _isLoading = false;
      });

      if (results.isNotEmpty && widget.autoSpeakTopResult) {
        _speakBuyer(results.first);
      }
    }
  }

  void _speakBuyer(RankedRecyclerResult buyer) {
    widget.audioService.speakBestBuyer(
      recyclerName: buyer.name,
      distanceKm: buyer.distanceKm,
      ratePerKg: buyer.offeredRate,
      localeOverride: widget.locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'hi'
              ? 'सर्वश्रेष्ठ खरीदार (Best Buyers)'
              : (locale == 'en' ? 'Best Buyers' : 'सर्वोत्तम खरेदीदार'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          if (_buyers.isNotEmpty)
            IconButton(
              key: const Key('speak_top_buyer_button'),
              icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn, size: 28),
              tooltip: 'ऐका / Listen',
              onPressed: () {
                HapticService.selectionClick();
                _speakBuyer(_buyers.first);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buyers.isEmpty
                ? _buildNoBuyersState(locale)
                : _buildBuyersList(locale),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State: No Buyers Found
  // ---------------------------------------------------------------------------
  Widget _buildNoBuyersState(String locale) {
    final title = locale == 'hi'
        ? 'कोई खरीदार नहीं मिला'
        : (locale == 'en' ? 'No Buyers Found' : 'खरेदीदार सापडले नाहीत');

    final suggestion = locale == 'hi'
        ? 'कृपया अन्य ई-कचरा श्रेणी का चयन करें या खोज क्षेत्र का दायरा बढ़ाएं।'
        : (locale == 'en'
            ? 'Try selecting a different material category or expanding your search area.'
            : 'कृपया इतर प्रकार निवडून पहा किंवा शोध परिसर वाढवा.');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 72,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              suggestion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                key: const Key('back_to_lot_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenGoEarn,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  HapticService.selectionClick();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 26),
                label: Text(
                  locale == 'hi' ? 'वापस जाएं' : (locale == 'en' ? 'Go Back' : 'मागे जा'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Buyers List: Maximum 3 Cards
  // ---------------------------------------------------------------------------
  Widget _buildBuyersList(String locale) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: _buyers.length,
      itemBuilder: (context, index) {
        final buyer = _buyers[index];
        final isRankOne = buyer.rank == 1;

        return _buildRecyclerCard(buyer, isRankOne, locale);
      },
    );
  }

  Widget _buildRecyclerCard(RankedRecyclerResult buyer, bool isRankOne, String locale) {
    const goldBorderColor = Color(0xFFF59E0B);
    final regularBorderColor = Colors.grey.shade300;

    return Container(
      key: Key('recycler_card_${buyer.recyclerId}'),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRankOne ? goldBorderColor : regularBorderColor,
          width: isRankOne ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isRankOne ? goldBorderColor.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.04),
            blurRadius: isRankOne ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Rank & Gold highlight header if Rank #1
          if (isRankOne)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    locale == 'hi'
                        ? '★ रैंक #1 : सर्वोत्तम खरीदार (Best Choice)'
                        : (locale == 'en'
                            ? '★ Rank #1 : Best Choice Buyer'
                            : '★ क्रमांक १ : सर्वोत्तम पर्याय (Best Choice)'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Name & Verified Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Green verified badge
                          Container(
                            key: Key('verified_badge_${buyer.recyclerId}'),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF22C55E)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF16A34A)),
                                const SizedBox(width: 5),
                                Text(
                                  locale == 'hi'
                                      ? 'अधिकृत रीसायकलर'
                                      : (locale == 'en' ? 'Verified Recycler' : 'अधिकृत रिसायकलर'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Speaker read-out button for this card
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn),
                      tooltip: 'ऐका / Listen',
                      onPressed: () {
                        HapticService.selectionClick();
                        _speakBuyer(buyer);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Rate & Distance Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rate in Rupees per kg
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale == 'hi' ? 'प्रस्तावित दर' : 'दिला जाणारा भाव',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '₹${buyer.offeredRate.toStringAsFixed(buyer.offeredRate.truncateToDouble() == buyer.offeredRate ? 0 : 1)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.greenGoEarn,
                                ),
                              ),
                              const Text(
                                ' / kg',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Distance with Map Pin Icon
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 24),
                          const SizedBox(width: 4),
                          Text(
                            '${buyer.distanceKm.toStringAsFixed(buyer.distanceKm.truncateToDouble() == buyer.distanceKm ? 0 : 1)} किमी',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Pickup vs Drop-off Indicator
                Row(
                  children: [
                    Icon(
                      buyer.pickupAvailable
                          ? Icons.local_shipping_rounded // Truck icon
                          : Icons.directions_walk_rounded, // Walking icon
                      key: Key(buyer.pickupAvailable
                          ? 'pickup_icon_${buyer.recyclerId}'
                          : 'dropoff_icon_${buyer.recyclerId}'),
                      color: buyer.pickupAvailable ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        buyer.pickupAvailable
                            ? (locale == 'hi'
                                ? 'घर पर पिकअप सुविधा (${buyer.estimatedPickupTime})'
                                : 'घरी येऊन उचलणार (${buyer.estimatedPickupTime})')
                            : (locale == 'hi' ? 'स्वयं ले जाएं (ड्रॉप-ऑफ)' : 'स्वतः केंद्रावर घेऊन जा (ड्रॉप-ऑफ)'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: buyer.pickupAvailable ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Action Row: Phone Call & "Select this buyer"
                Row(
                  children: [
                    // Phone Call button (min 56dp target)
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: OutlinedButton(
                        key: Key('phone_button_${buyer.recyclerId}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Color(0xFF0284C7), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          HapticService.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('कॉल करत आहे: ${buyer.phone}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0284C7), size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // "Select this buyer" button (Primary Green, min 56dp height)
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          key: Key('select_buyer_button_${buyer.recyclerId}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.greenGoEarn,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            HapticService.heavyImpact();
                            widget.onBuyerSelected?.call(buyer);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  locale == 'hi'
                                      ? '${buyer.name} का चयन किया गया।'
                                      : '${buyer.name} निवडले गेले.',
                                ),
                                backgroundColor: AppTheme.greenGoEarn,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 24),
                          label: Text(
                            locale == 'hi'
                                ? 'यह खरीदार चुनें'
                                : (locale == 'en' ? 'Select this buyer' : 'हा खरेदीदार निवडा'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
