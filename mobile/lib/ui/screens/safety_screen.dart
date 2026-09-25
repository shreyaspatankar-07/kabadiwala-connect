import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/safety_repository.dart';
import '../widgets/speaker_button.dart';
import 'safety_card_detail_screen.dart';

/// Comic-style Safety Guidance Screen (Fourth Tab in Mobile Collector Shell).
class SafetyScreen extends StatefulWidget {
  final String locale;

  const SafetyScreen({
    super.key,
    this.locale = 'mr',
  });

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  String _selectedCategory = 'all';
  late List<SafetyCard> _cards;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    setState(() {
      _cards = SafetyRepository().getCards(
        locale: widget.locale,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
    });
  }

  void _playHeaderAudio() {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';
    final msg = isMr
        ? 'ई-कचरा सुरक्षितपणे हाताळण्याचे नियम आणि इशारे ऐका. कोणत्याही कार्डवर दाबून संपूर्ण माहिती वाचा.'
        : (isHi
            ? 'ई-कचरा सुरक्षित रूप से संभालने के नियम और चेतावनियां सुनें। किसी भी कार्ड पर टैप करके पूरी जानकारी पढ़ें।'
            : 'Listen to safe e-waste dismantling guidelines. Tap any card to view detailed illustrated steps.');
    AudioFeedbackService().speak(msg);
  }

  Color _getHazardColor(String level) {
    switch (level) {
      case 'danger':
        return AppTheme.dangerRed;
      case 'warning':
        return const Color(0xFFD97706);
      case 'info':
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getHazardBgColor(String level) {
    switch (level) {
      case 'danger':
        return AppTheme.dangerRedLight;
      case 'warning':
        return AppTheme.yellowPendingLight;
      case 'info':
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData _getHazardIcon(String topicId) {
    switch (topicId) {
      case 'cables_burn':
        return Icons.local_fire_department_rounded;
      case 'crt_monitor':
        return Icons.tv_off_rounded;
      case 'battery_crush':
        return Icons.battery_alert_rounded;
      case 'pcb_acid':
        return Icons.science_rounded;
      case 'safe_storage':
        return Icons.warehouse_rounded;
      case 'battery_smoke':
        return Icons.warning_rounded;
      case 'ppe_gloves':
        return Icons.health_and_safety_rounded;
      case 'first_aid':
        return Icons.medical_services_rounded;
      case 'burnt_condition':
        return Icons.fire_extinguisher_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = widget.locale == 'mr';
    final isHi = widget.locale == 'hi';

    final categories = [
      ('all', isMr ? 'सर्व नियम' : (isHi ? 'सभी नियम' : 'All')),
      ('batteries', isMr ? 'बॅटरी' : (isHi ? 'बैटरी' : 'Batteries')),
      ('CRT', isMr ? 'CRT स्क्रीन' : (isHi ? 'CRT टीवी' : 'CRT Screens')),
      ('cables', isMr ? 'केबल्स' : (isHi ? 'केबल्स' : 'Cables')),
      ('PCB', isMr ? 'सर्किट बोर्ड' : (isHi ? 'सर्किट बोर्ड' : 'PCBs')),
      ('handling', isMr ? 'हाताळणी' : (isHi ? 'हैंडलिंग' : 'Handling')),
      ('first_aid', isMr ? 'प्रथमोपचार' : (isHi ? 'प्राथमिक चिकित्सा' : 'First Aid')),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isMr ? 'सुरक्षा नियम व मार्गदर्शन' : (isHi ? 'सुरक्षा नियम एवं मार्गदर्शन' : 'Safety Guidance'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textHighContrast,
          ),
        ),
        actions: [
          SpeakerButton(
            key: const Key('btn_safety_header_audio'),
            onPressed: _playHeaderAudio,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips Carousel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cat.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textHighContrast,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.greenGoEarn,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat.$1;
                            _loadCards();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Cards List
          Expanded(
            child: ListView.separated(
              key: const Key('safety_card_list'),
              padding: const EdgeInsets.all(16.0),
              itemCount: _cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = _cards[index];
                final hazardColor = _getHazardColor(card.hazardLevel);
                final hazardBg = _getHazardBgColor(card.hazardLevel);
                final hazardIcon = _getHazardIcon(card.topicId);
                final isAck = card.isAcknowledged;

                return InkWell(
                  key: Key('safety_card_${card.topicId}'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SafetyCardDetailScreen(
                          card: card,
                          locale: widget.locale,
                          onAcknowledged: _loadCards,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAck ? AppTheme.greenGoEarn.withValues(alpha: 0.4) : hazardColor.withValues(alpha: 0.25),
                        width: isAck ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large Comic-Style Hazard Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: hazardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: hazardColor.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Icon(
                              hazardIcon,
                              color: hazardColor,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Summary
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Hazard Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: hazardColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      card.hazardLevel.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isAck)
                                    Container(
                                      key: Key('acknowledged_badge_${card.topicId}'),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.greenGoEarnLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_rounded, size: 12, color: AppTheme.greenGoEarn),
                                          SizedBox(width: 2),
                                          Text(
                                            'समजले',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.greenGoEarn,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                card.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHighContrast,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.summary,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
