import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/repositories/lot_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../../data/repositories/ledger_repository.dart';
import '../widgets/big_tile.dart';
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
  int _pendingCount = 2; // simulates offline queued items for demonstration

  late final AppDatabase _db;
  late final bool _ownsDb;
  late final LedgerRepository _ledgerRepo;

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
      _db = AppDatabase.inMemory();
      _ownsDb = true;
    }
    _ledgerRepo = widget.ledgerRepository ?? LedgerRepository(_db);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioService.speakPrompt(_tabPromptKeys[_currentIndex]);
    });
  }

  @override
  void dispose() {
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
        return locale == 'mr' ? 'माझी कमाई' : (locale == 'hi' ? 'मेरी कमाई' : 'Earnings');
      case 3:
        return locale == 'mr' ? 'सुरक्षा नियम' : (locale == 'hi' ? 'सुरक्षा नियम' : 'Safety');
      default:
        return 'कबाडीवाला कनेक्ट';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.initialLocale;

    return Scaffold(
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
            // Connectivity & sync queue badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SyncStatusBadge(
                isOnline: _isOnline,
                pendingCount: _pendingCount,
                onTapSync: () {
                  setState(() {
                    _isOnline = !_isOnline;
                    if (_isOnline) _pendingCount = 0;
                  });
                  HapticService.mediumImpact();
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
              icon: const Icon(Icons.add_box_rounded, size: 30),
              activeIcon: const Icon(Icons.add_box, size: 32),
              label: locale == 'mr' ? 'माल जोडा' : (locale == 'hi' ? 'माल जोड़ें' : 'Add Lot'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.currency_rupee_rounded, size: 30),
              activeIcon: const Icon(Icons.monetization_on, size: 32),
              label: locale == 'mr' ? 'दर फलक' : (locale == 'hi' ? 'भाव सूची' : 'Price Board'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 30),
              activeIcon: const Icon(Icons.account_balance_wallet, size: 32),
              label: locale == 'mr' ? 'कमाई' : (locale == 'hi' ? 'कमाई' : 'Earnings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shield_outlined, size: 30),
              activeIcon: const Icon(Icons.shield, size: 32),
              label: locale == 'mr' ? 'सुरक्षा' : (locale == 'hi' ? 'सुरक्षा' : 'Safety'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Add Lot (माल जोडा)
  // ---------------------------------------------------------------------------
  Widget _buildAddLotTab(BuildContext context, String locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large Photo Capture Button
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                await HapticService.mediumImpact();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddLotScreen(
                      audioService: widget.audioService,
                      lotRepository: widget.lotRepository ?? LotRepository(AppDatabase.inMemory()),
                      priceRepository: widget.priceRepository ?? PriceRepository(AppDatabase.inMemory()),
                      locale: locale,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    size: 54,
                    color: AppTheme.greenGoEarn,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locale == 'mr' ? 'मालाचा फोटो काढा' : (locale == 'hi' ? 'माल का फोटो लें' : 'Take Item Photo'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textHighContrast,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories Grid
          Text(
            locale == 'mr' ? 'प्रकार निवडा:' : (locale == 'hi' ? 'प्रकार चुनें:' : 'Select Category:'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BigTile(
                  title: locale == 'mr' ? 'सर्किट बोर्ड' : 'सर्किट बोर्ड',
                  subtitle: 'PCB',
                  icon: Icons.memory_rounded,
                  isSelected: true,
                  primaryColor: AppTheme.greenGoEarn,
                  minHeight: 90,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigTile(
                  title: locale == 'mr' ? 'तांब्याची वायर' : 'तांबा तार',
                  subtitle: 'Copper',
                  icon: Icons.cable_rounded,
                  isSelected: false,
                  primaryColor: const Color(0xFFD97706),
                  minHeight: 90,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BigTile(
                  title: locale == 'mr' ? 'बॅटरी' : 'बैटरी',
                  subtitle: 'Battery',
                  icon: Icons.battery_charging_full_rounded,
                  isSelected: false,
                  primaryColor: AppTheme.dangerRed,
                  minHeight: 90,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigTile(
                  title: locale == 'mr' ? 'टीव्ही/स्क्रीन' : 'स्क्रीन',
                  subtitle: 'Display',
                  icon: Icons.tv_rounded,
                  isSelected: false,
                  primaryColor: const Color(0xFF0284C7),
                  minHeight: 90,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Save Offline Button (Min 56dp target)
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenGoEarn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await HapticService.heavyImpact();
                setState(() {
                  _pendingCount++;
                });
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'mr'
                          ? 'माल फोनमध्ये सुरक्षित सेव्ह झाला!'
                          : 'माल फोन में सुरक्षित सहेज लिया गया!',
                    ),
                    backgroundColor: AppTheme.greenGoEarn,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 30),
              label: Text(
                locale == 'mr' ? 'माल सुरक्षित जतन करा' : (locale == 'hi' ? 'माल सुरक्षित सहेजें' : 'Save Lot Offline'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Price Board (दर फलक)
  // ---------------------------------------------------------------------------
  Widget _buildPriceBoardTab(BuildContext context, String locale) {
    return PriceBoardScreen(
      audioService: widget.audioService,
      priceRepository: widget.priceRepository,
      locale: locale,
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
