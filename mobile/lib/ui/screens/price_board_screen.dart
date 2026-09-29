import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/repositories/price_repository.dart';
import '../widgets/big_keypad.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/speaker_button.dart';

/// 7 Core Material Category Definition for the Vernacular Price Board
class CategoryBoardItem {
  const CategoryBoardItem({
    required this.id,
    required this.nameMr,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.defaultRate,
    required this.marketMin,
    required this.marketMax,
    required this.recyclerQuote,
    required this.trend,
    required this.pctChange,
  });

  final String id;
  final String nameMr;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final double defaultRate;
  final double marketMin;
  final double marketMax;
  final double recyclerQuote;
  final String trend; // 'up' | 'down' | 'flat'
  final double pctChange;

  String localizedName(String locale) {
    if (locale == 'hi') return nameHi;
    if (locale == 'en') return nameEn;
    return nameMr;
  }
}

const List<CategoryBoardItem> kStandardCategories = [
  CategoryBoardItem(
    id: 'PCB',
    nameMr: 'सर्किट बोर्ड (PCB)',
    nameHi: 'सर्किट बोर्ड (PCB)',
    nameEn: 'Printed Circuit Board',
    icon: Icons.memory_rounded,
    defaultRate: 420.0,
    marketMin: 390.0,
    marketMax: 450.0,
    recyclerQuote: 435.0,
    trend: 'up',
    pctChange: 4.2,
  ),
  CategoryBoardItem(
    id: 'Cables',
    nameMr: 'तांब्याची वायर (Cables)',
    nameHi: 'तांबे का तार (Cables)',
    nameEn: 'Copper Cables',
    icon: Icons.cable_rounded,
    defaultRate: 680.0,
    marketMin: 650.0,
    marketMax: 720.0,
    recyclerQuote: 700.0,
    trend: 'up',
    pctChange: 2.8,
  ),
  CategoryBoardItem(
    id: 'Batteries',
    nameMr: 'बॅटरी (Batteries)',
    nameHi: 'बैटरी (Batteries)',
    nameEn: 'Batteries',
    icon: Icons.battery_charging_full_rounded,
    defaultRate: 140.0,
    marketMin: 120.0,
    marketMax: 160.0,
    recyclerQuote: 145.0,
    trend: 'flat',
    pctChange: 0.0,
  ),
  CategoryBoardItem(
    id: 'LCD',
    nameMr: 'स्क्रीन पॅनेल (LCD)',
    nameHi: 'स्क्रीन पैनल (LCD)',
    nameEn: 'LCD Panel',
    icon: Icons.desktop_windows_rounded,
    defaultRate: 45.0,
    marketMin: 35.0,
    marketMax: 55.0,
    recyclerQuote: 48.0,
    trend: 'down',
    pctChange: -3.5,
  ),
  CategoryBoardItem(
    id: 'Motors_Magnets',
    nameMr: 'मोटर / चुंबक (Motors)',
    nameHi: 'मोटर / चुंबक (Motors)',
    nameEn: 'Motors & Magnets',
    icon: Icons.electric_meter_rounded,
    defaultRate: 85.0,
    marketMin: 75.0,
    marketMax: 95.0,
    recyclerQuote: 88.0,
    trend: 'up',
    pctChange: 1.5,
  ),
  CategoryBoardItem(
    id: 'CRT',
    nameMr: 'जुना टीव्ही (CRT Display)',
    nameHi: 'पुराना टीवी (CRT)',
    nameEn: 'CRT Display',
    icon: Icons.tv_rounded,
    defaultRate: 18.0,
    marketMin: 15.0,
    marketMax: 22.0,
    recyclerQuote: 19.0,
    trend: 'flat',
    pctChange: 0.0,
  ),
  CategoryBoardItem(
    id: 'Mixed_Plastics',
    nameMr: 'ई-कचरा प्लास्टिक (Plastics)',
    nameHi: 'ई-कचरा प्लास्टिक (Plastics)',
    nameEn: 'Mixed Plastics',
    icon: Icons.recycling_rounded,
    defaultRate: 12.0,
    marketMin: 10.0,
    marketMax: 15.0,
    recyclerQuote: 13.0,
    trend: 'down',
    pctChange: -1.2,
  ),
];

class PriceBoardScreen extends StatefulWidget {
  const PriceBoardScreen({
    super.key,
    required this.audioService,
    this.priceRepository,
    this.district = 'Palghar',
    this.locale = 'mr',
    this.forcedRecordedAt, // For testing cache staleness
    this.enableLiveStream = true,
  });

  final AudioFeedbackService audioService;
  final PriceRepository? priceRepository;
  final String district;
  final String locale;
  final DateTime? forcedRecordedAt;
  final bool enableLiveStream;

  @override
  State<PriceBoardScreen> createState() => _PriceBoardScreenState();
}

class _PriceBoardScreenState extends State<PriceBoardScreen> {
  CategoryBoardItem? _selectedCategory;
  late DateTime _lastCacheTime;
  late String _selectedDistrict;
  StreamSubscription<List<CachedPrice>>? _priceSub;
  Map<String, CachedPrice> _cachedPricesMap = {};
  bool _isRefreshing = false;

  static const List<String> kAvailableDistricts = [
    'Palghar',
    'Thane',
    'Mumbai',
    'Pune',
    'Nashik',
    'Nagpur',
    'Chhatrapati Sambhajinagar',
    'Kolhapur',
    'Solapur',
  ];

  @override
  void initState() {
    super.initState();
    _lastCacheTime = widget.forcedRecordedAt ?? DateTime.now();
    _selectedDistrict = widget.district;
    _initPrices();
  }

  Future<void> _initPrices() async {
    if (widget.priceRepository == null) return;
    try {
      final existing = await widget.priceRepository!.db.select(widget.priceRepository!.db.cachedPrices).get();
      if (existing.isNotEmpty && mounted) {
        _applyPrices(existing);
      } else {
        await widget.priceRepository!.seedInitialPricesIfEmpty();
        if (mounted) _loadExistingPrices();
      }
    } catch (_) {}
    _subscribePrices();
  }

  Future<void> _loadExistingPrices() async {
    if (widget.priceRepository == null) return;
    try {
      final existing = await widget.priceRepository!.db.select(widget.priceRepository!.db.cachedPrices).get();
      if (existing.isNotEmpty && mounted) {
        _applyPrices(existing);
      }
    } catch (_) {}
  }

  void _applyPrices(List<CachedPrice> prices) {
    final map = <String, CachedPrice>{};
    DateTime? latest;
    for (final p in prices) {
      final canonical = PriceRepository.normalizeCategory(p.category);
      final isTargetDistrict = p.district.toLowerCase() == _selectedDistrict.toLowerCase();
      final key = canonical;
      if (isTargetDistrict || !map.containsKey(key)) {
        map[key] = p;
      }
      if (latest == null || p.recordedAt.isAfter(latest)) {
        latest = p.recordedAt;
      }
    }
    setState(() {
      _cachedPricesMap = map;
      if (widget.forcedRecordedAt == null && latest != null) {
        _lastCacheTime = latest;
      }
    });
  }

  void _subscribePrices() {
    if (!widget.enableLiveStream) return;
    _priceSub?.cancel();
    if (widget.priceRepository != null) {
      _priceSub = widget.priceRepository!.watchAllPrices().listen((prices) {
        if (!mounted) return;
        _applyPrices(prices);
      });
    }
  }

  @override
  void dispose() {
    _priceSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PriceBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forcedRecordedAt != oldWidget.forcedRecordedAt) {
      _lastCacheTime = widget.forcedRecordedAt ?? DateTime.now();
    }
    if (widget.district != oldWidget.district) {
      _selectedDistrict = widget.district;
      _subscribePrices();
    }
  }

  List<CategoryBoardItem> get _displayedCategories {
    return kStandardCategories.map((base) {
      final cached = _cachedPricesMap[base.id];
      if (cached == null) return base;

      final trend = cached.buyingPrice > base.defaultRate
          ? 'up'
          : (cached.buyingPrice < base.defaultRate ? 'down' : base.trend);

      final pct = base.defaultRate > 0
          ? (((cached.buyingPrice - base.defaultRate) / base.defaultRate) * 100.0)
          : 0.0;

      return CategoryBoardItem(
        id: base.id,
        nameMr: base.nameMr,
        nameHi: base.nameHi,
        nameEn: base.nameEn,
        icon: base.icon,
        defaultRate: cached.buyingPrice,
        marketMin: cached.marketMin,
        marketMax: cached.marketMax,
        recyclerQuote: cached.sellingQuotedPrice,
        trend: trend,
        pctChange: double.parse(pct.toStringAsFixed(1)),
      );
    }).toList();
  }

  CategoryBoardItem get _activeDetailCategory {
    if (_selectedCategory == null) return kStandardCategories.first;
    return _displayedCategories.firstWhere(
      (c) => c.id == _selectedCategory!.id,
      orElse: () => _selectedCategory!,
    );
  }

  bool get _isCacheStale => PriceRepository.isCacheStale(_lastCacheTime);

  @override
  Widget build(BuildContext context) {
    final isHi = widget.locale == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          isHi ? 'सरकारी दर फलक' : 'सरकारी दर फलक (Price Board)',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            key: const Key('btn_refresh_prices'),
            tooltip: isHi ? 'दर अपडेट करें' : 'दर अपडेट करा',
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.greenGoEarn),
                  )
                : const Icon(Icons.refresh_rounded, color: AppTheme.greenGoEarn),
            onPressed: _isRefreshing
                ? null
                : () async {
                    setState(() => _isRefreshing = true);
                    await HapticService.selectionClick();
                    final ok = await widget.priceRepository?.fetchLatestPricesFromServer();
                    if (mounted) {
                      setState(() => _isRefreshing = false);
                      final msg = ok == true
                          ? (isHi ? 'ताज़ा भाव अपडेट हो गए' : 'नवीन बाजार भाव अपडेट झाले')
                          : (isHi ? 'ऑफलाइन मोड: सेव्ह केलेले भाव' : 'ऑफलाइन मोड: सेव्ह केलेले दर');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: ok == true ? AppTheme.greenGoEarn : AppTheme.yellowPending,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
          SpeakerButton(
            audioService: widget.audioService,
            promptKey: 'tabPriceBoard',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Amber Staleness Warning Banner (if cache older than 3 days)
            if (_isCacheStale) _buildStalenessBanner(isHi),

            // 2. District & Cache status indicator
            _buildDistrictHeader(isHi),

            // 3. Category Grid or Detail View
            Expanded(
              child: _selectedCategory == null
                  ? _buildCategoryGrid(isHi)
                  : _buildDetailView(_activeDetailCategory, isHi),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Staleness Warning Banner
  // ---------------------------------------------------------------------------
  Widget _buildStalenessBanner(bool isHi) {
    return Container(
      key: const Key('amber_staleness_banner'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.yellowPendingLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.yellowPending, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.yellowPending, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isHi
                  ? 'दर ३ दिन से पुराने हैं। इंटरनेट चालू होने पर अपडेट होंगे।'
                  : 'दर ३ दिवसांपेक्षा जुने आहेत. इंटरनेट सुरू झाल्यावर अपडेट होतील.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // District & Cache Header
  // ---------------------------------------------------------------------------
  Widget _buildDistrictHeader(bool isHi) {
    final daysAgo = DateTime.now().difference(_lastCacheTime).inDays;
    final timeLabel = daysAgo == 0
        ? (isHi ? 'आज अपडेट झाले' : 'आज अपडेट झाले')
        : (isHi ? '$daysAgo दिन पूर्व' : '$daysAgo दिवसांपूर्वी');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenuButton<String>(
            key: const Key('price_board_district_picker'),
            tooltip: 'जिल्हा निवडा / Select District',
            onSelected: (dist) {
              HapticService.selectionClick();
              setState(() {
                _selectedDistrict = dist;
              });
              _subscribePrices();
            },
            itemBuilder: (context) => kAvailableDistricts.map((d) {
              return PopupMenuItem<String>(
                value: d,
                child: Row(
                  children: [
                    Icon(
                      _selectedDistrict == d ? Icons.check_circle_rounded : Icons.location_city_rounded,
                      color: _selectedDistrict == d ? AppTheme.greenGoEarn : AppTheme.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(d, style: TextStyle(fontWeight: _selectedDistrict == d ? FontWeight.w900 : FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.greenGoEarn, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppTheme.greenGoEarn, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'जिल्हा: $_selectedDistrict',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textHighContrast),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.greenGoEarn, size: 22),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                _isCacheStale ? Icons.history_rounded : Icons.check_circle_outline_rounded,
                color: _isCacheStale ? AppTheme.yellowPending : AppTheme.greenGoEarn,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _isCacheStale ? AppTheme.yellowPending : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Picture Grid of 7 Material Categories
  // ---------------------------------------------------------------------------
  Widget _buildCategoryGrid(bool isHi) {
    final categories = _displayedCategories;
    return RefreshIndicator(
      onRefresh: () async {
        await widget.priceRepository?.fetchLatestPricesFromServer();
      },
      child: GridView.builder(
        key: const Key('price_board_category_grid'),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
        final isTrendUp = cat.trend == 'up';
        final isTrendDown = cat.trend == 'down';
        final trendColor = isTrendUp
            ? AppTheme.greenGoEarn
            : isTrendDown
                ? AppTheme.dangerRed
                : AppTheme.textMuted;
        final trendIcon = isTrendUp
            ? Icons.trending_up_rounded
            : isTrendDown
                ? Icons.trending_down_rounded
                : Icons.trending_flat_rounded;

        return InkWell(
          key: Key('category_tile_${cat.id}'),
          onTap: () {
            HapticService.selectionClick();
            setState(() {
              _selectedCategory = cat;
            });
            // Speak category rate immediately
            unawaited(
              widget.audioService.speakPriceDetail(
                category: cat.localizedName(widget.locale),
                pricePerKg: cat.defaultRate.round(),
                trendDirection: cat.trend,
                localeOverride: widget.locale,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon Header with trend badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat.icon, color: AppTheme.greenGoEarn, size: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trendColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${cat.pctChange > 0 ? '+' : ''}${cat.pctChange}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Category Title
                Text(
                  cat.localizedName(widget.locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textHighContrast,
                  ),
                ),
                const SizedBox(height: 6),

                // Rate Badge
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹ ${cat.defaultRate.round()} / kg',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.greenGoEarn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  // ---------------------------------------------------------------------------
  // 2. Detail View with Sparkline, Range Bar, and Speaker Read-out
  // ---------------------------------------------------------------------------
  Widget _buildDetailView(CategoryBoardItem cat, bool isHi) {
    final sparklinePoints = PriceRepository.generateSparklinePoints(cat.defaultRate);
    final isTrendUp = cat.trend == 'up';
    final isTrendDown = cat.trend == 'down';
    final trendColor = isTrendUp
        ? AppTheme.greenGoEarn
        : isTrendDown
            ? AppTheme.dangerRed
            : AppTheme.textMuted;
    final trendIcon = isTrendUp
        ? Icons.trending_up_rounded
        : isTrendDown
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return SingleChildScrollView(
      key: const Key('price_detail_scroll_view'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back Button & Category Header
          Row(
            children: [
              IconButton(
                key: const Key('back_to_grid_button'),
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () {
                  HapticService.selectionClick();
                  setState(() => _selectedCategory = null);
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cat.localizedName(widget.locale),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              // Persistent Speaker Button for this detail
              IconButton(
                key: const Key('detail_speaker_button'),
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.greenGoEarn, size: 30),
                onPressed: () async {
                  await HapticService.mediumImpact();
                  await widget.audioService.speakPriceDetail(
                    category: cat.localizedName(widget.locale),
                    pricePerKg: cat.defaultRate.round(),
                    trendDirection: cat.trend,
                    localeOverride: widget.locale,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large Price & Trend Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.borderColor, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  isHi ? 'आज का सरकारी भाव' : 'आजचा सरकारी प्रमाणित भाव',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹ ${cat.defaultRate.round()}',
                      key: const Key('large_price_digits'),
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.greenGoEarn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '/ किलो (per kg)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Trend badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '७ दिवस कल: ${cat.pctChange > 0 ? '+' : ''}${cat.pctChange}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 30-Day Sparkline Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHi ? '३० दिनों का भाव इतिहास' : '३० दिवसांचा भाव इतिहास',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const Icon(Icons.show_chart_rounded, color: AppTheme.greenGoEarn, size: 24),
                  ],
                ),
                const SizedBox(height: 14),
                SparklineChart(
                  dataPoints: sparklinePoints,
                  height: 120,
                  lineColor: trendColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recycler Offered vs Market Range Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isHi ? 'रीसायकलर भाव व बाजार मर्यादा' : 'अधिकृत रीसायकलर व बाजार मर्यादा',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),

                // Range visuals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'किमान: ₹ ${cat.marketMin.round()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'रीसायकलर: ₹ ${cat.recyclerQuote.round()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.greenGoEarn,
                        ),
                      ),
                    ),
                    Text(
                      'कमाल: ₹ ${cat.marketMax.round()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Visual progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (cat.recyclerQuote - cat.marketMin) / (cat.marketMax - cat.marketMin),
                    minHeight: 10,
                    backgroundColor: AppTheme.borderColor,
                    color: AppTheme.greenGoEarn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // "Report a Price" Button
          SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              key: const Key('report_price_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenGoEarn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
              ),
              onPressed: () => _openReportPriceModal(cat, isHi),
              icon: const Icon(Icons.edit_note_rounded, size: 28),
              label: Text(
                isHi ? 'अन्य भाव नोंदवा (Report Price)' : 'अन्य भाव नोंदवा (Report Price)',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Report a Price Modal (One tap + number pad)
  // ---------------------------------------------------------------------------
  void _openReportPriceModal(CategoryBoardItem cat, bool isHi) {
    HapticService.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        String enteredPrice = '';

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    isHi
                        ? '${cat.localizedName(widget.locale)}: आपको क्या भाव मिला?'
                        : '${cat.localizedName(widget.locale)}: तुम्हाला काय भाव मिळाला?',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Display box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor, width: 2),
                    ),
                    child: Text(
                      enteredPrice.isEmpty ? '₹ ० / kg' : '₹ $enteredPrice / kg',
                      key: const Key('report_price_display'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textHighContrast,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Big Keypad
                  BigKeypad(
                    onDigitPressed: (digit) {
                      setModalState(() {
                        if (enteredPrice.length < 5) {
                          enteredPrice += digit;
                        }
                      });
                    },
                    onBackspacePressed: () {
                      setModalState(() {
                        if (enteredPrice.isNotEmpty) {
                          enteredPrice = enteredPrice.substring(0, enteredPrice.length - 1);
                        }
                      });
                    },
                    onSubmitPressed: () {},
                    showSubmit: false,
                  ),
                  const SizedBox(height: 16),

                  // Submit Report Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('submit_price_report_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greenGoEarn,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: enteredPrice.isEmpty
                          ? null
                          : () async {
                              final priceVal = double.tryParse(enteredPrice) ?? 0.0;
                              if (priceVal <= 0) return;

                              if (widget.priceRepository != null) {
                                await widget.priceRepository!.savePriceReport(
                                  category: cat.id,
                                  offeredPrice: priceVal,
                                  district: widget.district,
                                );
                              }

                              await HapticService.heavyImpact();
                              await widget.audioService.speakCustomText(
                                isHi
                                    ? 'भाव दर्ज हो गया है, सिंक कतार में सुरक्षित है।'
                                    : 'भाव नोंदवला गेला आहे, सिंक रांगेत सुरक्षित आहे.',
                              );

                              if (modalCtx.mounted) {
                                Navigator.of(modalCtx).pop();
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isHi
                                                ? '₹ $priceVal भाव सुरक्षित जतन (सिंक प्रतीक्षा)'
                                                : '₹ $priceVal भाव सुरक्षित जतन (सिंक बाकी)',
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.textHighContrast,
                                  ),
                                );
                              }
                            },
                      child: Text(
                        isHi ? 'भाव जमा करा (Submit)' : 'भाव जमा करा (Submit)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }
}
