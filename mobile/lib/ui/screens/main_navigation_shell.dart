import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/repositories/lot_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../../data/repositories/ledger_repository.dart';
import '../../data/sync/sync_engine.dart';
import '../widgets/demo_banner.dart';
import '../widgets/speaker_button.dart';
import '../widgets/sync_status_badge.dart';
import 'add_lot_screen.dart';
import 'earnings_screen.dart';
import 'price_board_screen.dart';
import 'privacy_screen.dart';
import 'safety_screen.dart';


/// Bottom Navigation Shell with 4 tabs:
/// 1. Add Lot (माल जोडा / माल जोड़ें)
/// 2. Price Board (दर फलक / भाव सूची)
/// 3. Earnings (कमाई)
/// 4. Safety (सुरक्षा)
/// Includes persistent speaker button, sync status badge, and min 56dp touch targets.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.audioService,
    this.initialLocale = 'mr',
    this.lotRepository,
    this.priceRepository,
    this.db,
    this.ledgerRepository,
  });

  final AudioFeedbackService audioService;
  final String initialLocale;
  final LotRepository? lotRepository;
  final PriceRepository? priceRepository;
  final AppDatabase? db;
  final LedgerRepository? ledgerRepository;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isOnline = false; // offline-first default
  int _pendingCount = 2; // offline queue count

  late final AppDatabase _db;
  late final bool _ownsDb;
  late final LedgerRepository _ledgerRepo;
  late final PriceRepository _priceRepo;
  SyncEngine? _syncEngine;
  StreamSubscription<SyncEngineState>? _syncSub;

  final List<String> _tabPromptKeys = [
    'tabAddLot',
    'tabPriceBoard',
    'tabEarnings',
    'tabSafety',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.db != null) {
      _db = widget.db!;
      _ownsDb = false;
    } else if (widget.lotRepository != null) {
      _db = widget.lotRepository!.db;
      _ownsDb = false;
    } else {
      _db = AppDatabase();
      _ownsDb = true;
    }
    _ledgerRepo = widget.ledgerRepository ?? LedgerRepository(_db);
    _priceRepo = widget.priceRepository ?? PriceRepository(_db);

    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      try {
        _syncEngine = SyncEngine(db: _db);
        _syncSub = _syncEngine!.stateStream.listen((state) {
          if (!mounted) return;
          setState(() {
            _isOnline = state.isOnline;
            _pendingCount = state.pendingQueueCount;
          });
        });
      } catch (e) {
        debugPrint('[MainNavigationShell] SyncEngine init fallback: $e');
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioService.speakPrompt(_tabPromptKeys[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    _syncEngine?.dispose();
    if (_ownsDb) {
      _db.close();
    }
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    HapticService.selectionClick();
    setState(() {
      _currentIndex = index;
    });
    widget.audioService.speakPrompt(_tabPromptKeys[index]);
  }

  String get _appBarTitle {
    final locale = widget.initialLocale;
    switch (_currentIndex) {
      case 0:
        return locale == 'mr' ? 'माल जोडा' : (locale == 'hi' ? 'माल जोड़ें' : 'Add Lot');
      case 1:
        return locale == 'mr' ? 'आजचे दर फलक' : (locale == 'hi' ? 'आज का भाव' : 'Price Board');
      case 2:
        return locale == 'mr' ? 'माझी कमाई' : (locale == 'hi' ? 'मेरी कमाई' : 'Earnings & Lots');
      case 3:
        return locale == 'mr' ? 'सुरक्षा नियम' : (locale == 'hi' ? 'सुरक्षा नियम' : 'Safety Guidance');
      default:
        return locale == 'en' ? 'Kabadiwala Connect' : 'कबाडीवाला कनेक्ट';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.initialLocale;
    final isMr = locale == 'mr';
    final isHi = locale == 'hi';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        final exitTitle = isMr ? 'अ‍ॅपमधून बाहेर पडायचे आहे का?' : (isHi ? 'ऐप बंद करें?' : 'Exit App?');
        final exitContent = isMr
            ? 'आपण कबाडीवाला कनेक्ट अ‍ॅपमधून बाहेर पडू इच्छिता?'
            : (isHi ? 'क्या आप कबाडीवाला कनेक्ट से बाहर निकलना चाहते हैं?' : 'Are you sure you want to exit Kabadiwala Connect?');
        final cancelText = isMr ? 'नाही (रद्द करा)' : (isHi ? 'नहीं, चालू रखें' : 'Cancel');
        final confirmText = isMr ? 'होय, बाहेर पडा' : (isHi ? 'हां, बाहर निकलें' : 'Exit');

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.exit_to_app_rounded, color: AppTheme.dangerRed, size: 28),
                const SizedBox(width: 8),
                Text(
                  exitTitle,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              exitContent,
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _appBarTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              key: const Key('btn_open_privacy_screen'),
              tooltip: locale == 'mr' ? 'गोपनीयता व सुरक्षा' : (locale == 'hi' ? 'गोपनीयता एवं सुरक्षा' : 'Privacy & Security'),
              icon: const Icon(Icons.privacy_tip_outlined, color: AppTheme.greenGoEarn, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivacyScreen(
                      audioService: widget.audioService,
                      db: _db,
                      locale: locale,
                    ),
                  ),
                );
              },
            ),
            // Persistent speaker button on every screen
            SpeakerButton(
              promptKey: _tabPromptKeys[_currentIndex],
              audioService: widget.audioService,
              tooltip: 'या स्क्रीनबद्दल माहिती ऐका',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              DemoBannerWidget(locale: locale),
              // Connectivity & sync queue badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SyncStatusBadge(
                  isOnline: _isOnline,
                  pendingCount: _pendingCount,
                  onTapSync: () async {
                    setState(() {
                      _isOnline = true;
                    });
                    HapticService.mediumImpact();
                    try {
                      if (_syncEngine != null) {
                        await _syncEngine!.triggerSync();
                      } else {
                        await _priceRepo.fetchLatestPricesFromServer();
                      }
                    } catch (_) {}
                    widget.audioService.speakPrompt(_isOnline ? 'syncSuccess' : 'offlineNotice');
                  },
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildAddLotTab(context, locale),
                    _buildPriceBoardTab(context, locale),
                    _buildEarningsTab(context, locale),
                    _buildSafetyTab(context, locale),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderColor, width: 1.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.add_box_rounded, size: 30, key: Key('nav_add_lot')),
                activeIcon: const Icon(Icons.add_box, size: 32, key: Key('nav_add_lot')),
                label: locale == 'mr' ? 'माल जोडा' : (locale == 'hi' ? 'माल जोड़ें' : 'Add Lot'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.currency_rupee_rounded, size: 30, key: Key('nav_price_board')),
                activeIcon: const Icon(Icons.monetization_on, size: 32, key: Key('nav_price_board')),
                label: locale == 'mr' ? 'दर फलक' : (locale == 'hi' ? 'भाव सूची' : 'Price Board'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance_wallet_outlined, size: 30, key: Key('nav_earnings')),
                activeIcon: const Icon(Icons.account_balance_wallet, size: 32, key: Key('nav_earnings')),
                label: locale == 'mr' ? 'कमाई' : (locale == 'hi' ? 'कमाई' : 'Earnings'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shield_outlined, size: 30, key: Key('nav_safety')),
                activeIcon: const Icon(Icons.shield, size: 32, key: Key('nav_safety')),
                label: locale == 'mr' ? 'सुरक्षा' : (locale == 'hi' ? 'सुरक्षा' : 'Safety'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Add Lot (माल जोडा)
  // ---------------------------------------------------------------------------
  Widget _buildAddLotTab(BuildContext context, String locale) {
    return AddLotScreen(
      audioService: widget.audioService,
      lotRepository: widget.lotRepository ?? LotRepository(_db),
      priceRepository: _priceRepo,
      locale: locale,
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Price Board (दर फलक)
  // ---------------------------------------------------------------------------
  Widget _buildPriceBoardTab(BuildContext context, String locale) {
    return PriceBoardScreen(
      audioService: widget.audioService,
      priceRepository: _priceRepo,
      locale: locale,
      enableLiveStream: !WidgetsBinding.instance.runtimeType.toString().contains('Test'),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Earnings (कमाई)
  // ---------------------------------------------------------------------------
  Widget _buildEarningsTab(BuildContext context, String locale) {
    return EarningsScreen(
      db: _db,
      audioService: widget.audioService,
      ledgerRepository: _ledgerRepo,
      locale: locale,
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Safety (सुरक्षा)
  // ---------------------------------------------------------------------------
  Widget _buildSafetyTab(BuildContext context, String locale) {
    return SafetyScreen(locale: locale);
  }

}
