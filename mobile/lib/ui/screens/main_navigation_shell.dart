import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/big_tile.dart';
import '../widgets/speaker_button.dart';
import '../widgets/sync_status_badge.dart';

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
  });

  final AudioFeedbackService audioService;
  final String initialLocale;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isOnline = false; // offline-first default
  int _pendingCount = 2; // simulates offline queued items for demonstration

  final List<String> _tabPromptKeys = [
    'tabAddLot',
    'tabPriceBoard',
    'tabEarnings',
    'tabSafety',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioService.speakPrompt(_tabPromptKeys[_currentIndex]);
    });
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
          // Persistent speaker button on every screen
          SpeakerButton(
            promptKey: _tabPromptKeys[_currentIndex],
            audioService: widget.audioService,
            tooltip: 'या स्क्रीनबद्दल माहिती ऐका',
          ),
          const SizedBox(width: 12),
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
        decoration: BoxDecoration(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(locale == 'mr' ? 'फोटो घेतला गेला!' : 'फोटो खींच लिया गया!'),
                    backgroundColor: AppTheme.greenGoEarn,
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
    final prices = [
      ('तांब्याची वायर (Copper)', '₹ 680 / किलो', 'सरकारी प्रमाणित दर', AppTheme.greenGoEarn),
      ('सर्किट बोर्ड (High-Grade PCB)', '₹ 420 / किलो', 'अधिकृत रीसायकलर', AppTheme.greenGoEarn),
      ('लिथियम बॅटरी (Li-ion)', '₹ 140 / किलो', 'सुरक्षित विल्हेवाट दर', const Color(0xFFD97706)),
      ('इलेक्ट्रिक मोटर (Motors)', '₹ 85 / किलो', 'प्रमाणित भाव', const Color(0xFF0284C7)),
      ('स्क्रीन पॅनेल (LCD/LED)', '₹ 45 / किलो', 'न्यूनतम ₹३५ - कमाल ₹५५', const Color(0xFF475569)),
      ('जुना टीव्ही (CRT Display)', '₹ 18 / किलो', 'काच न फोडता दर', AppTheme.dangerRed),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: prices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = prices[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.$4.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.currency_rupee_rounded, color: item.$4, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$3,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                item.$2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: item.$4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Earnings (कमाई)
  // ---------------------------------------------------------------------------
  Widget _buildEarningsTab(BuildContext context, String locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Cash Received Card (Green = Go/Earn)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.greenGoEarnLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.greenGoEarn, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'mr' ? 'एकूण रोख मिळाली' : 'कुल नकद प्राप्त',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.greenGoEarn,
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppTheme.greenGoEarn, size: 28),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹ 14,250',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF064E3B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Pending Dues Card (Yellow = Pending)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.yellowPendingLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.yellowPending, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'mr' ? 'येणे बाकी रक्कम' : 'बकाया राशि',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.yellowPending,
                      ),
                    ),
                    const Icon(Icons.schedule_rounded, color: AppTheme.yellowPending, size: 28),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹ 2,800',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Record Cash Received Button (Cash-first principle from AGENTS.md)
          SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenGoEarn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await HapticService.mediumImpact();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'mr' ? 'रोख रक्कम नोंदवली गेली!' : 'नकद राशि दर्ज कर ली गई!',
                    ),
                    backgroundColor: AppTheme.greenGoEarn,
                  ),
                );
              },
              icon: const Icon(Icons.payments_rounded, size: 28),
              label: Text(
                locale == 'mr' ? 'रोख पावती नोंदवा' : 'नकद रसीद दर्ज करें',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Safety (सुरक्षा)
  // ---------------------------------------------------------------------------
  Widget _buildSafetyTab(BuildContext context, String locale) {
    final rules = [
      (
        'बॅटरी कधीही कापू किंवा जाळू नका',
        'बैटरी कभी न काटें और न जलाएं',
        'स्फोट किंवा विषारी धूर निघू शकतो',
        Icons.battery_alert_rounded,
        AppTheme.dangerRed,
        AppTheme.dangerRedLight,
      ),
      (
        'सीआरटी ट्यूब फोडू नका',
        'सीआरटी ट्यूब न तोड़ें',
        'काचेमध्ये विषारी शिसे (Lead) असते',
        Icons.tv_off_rounded,
        AppTheme.dangerRed,
        AppTheme.dangerRedLight,
      ),
      (
        'वायर जाळू नका, प्लास्टिक सोलून काढा',
        'तार न जलाएं, प्लास्टिक अलग करें',
        'उघड्यावर वायर जाळणे कायद्याने गुन्हा आहे',
        Icons.warning_amber_rounded,
        const Color(0xFFD97706),
        AppTheme.yellowPendingLight,
      ),
      (
        'हातमोजे आणि मास्क वापरा',
        'दस्ताने और मास्क का उपयोग करें',
        'काच आणि धारदार पत्र्यापासून संरक्षण',
        Icons.health_and_safety_rounded,
        AppTheme.greenGoEarn,
        AppTheme.greenGoEarnLight,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: rules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rule = rules[index];
        final title = locale == 'hi' ? rule.$2 : rule.$1;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rule.$6,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: rule.$5, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(rule.$4, color: rule.$5, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: rule.$5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rule.$3,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textHighContrast,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
