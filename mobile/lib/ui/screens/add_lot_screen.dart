import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/hardware/image_processor.dart';
import '../../core/hardware/location_service.dart';
import '../../core/hardware/scale_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/ml/material_classifier.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local_database.dart';
import '../../data/models/lot_item_draft.dart';
import '../../data/repositories/lot_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../widgets/big_keypad.dart';
import '../widgets/big_tile.dart';
import '../widgets/camera_capture_card.dart';
import '../widgets/condition_chips.dart';
import '../widgets/reference_weight_helper.dart';
import '../widgets/speaker_button.dart';
import '../widgets/value_estimate_card.dart';

class AddLotScreen extends StatefulWidget {
  const AddLotScreen({
    super.key,
    required this.audioService,
    required this.lotRepository,
    required this.priceRepository,
    this.locale = 'mr',
    this.collectorId = 'KC-C-7821',
    this.materialClassifier,
    this.locationService,
    this.scaleService,
    this.onLotSaved,
  });

  final AudioFeedbackService audioService;
  final LotRepository lotRepository;
  final PriceRepository priceRepository;
  final String locale;
  final String collectorId;
  final MaterialClassifier? materialClassifier;
  final LocationService? locationService;
  final BluetoothScaleService? scaleService;
  final ValueChanged<LocalTransaction>? onLotSaved;

  @override
  State<AddLotScreen> createState() => _AddLotScreenState();
}

class _AddLotScreenState extends State<AddLotScreen> {
  late MaterialClassifier _classifier;
  late LocationService _locationService;
  late BluetoothScaleService _scaleService;

  // Active Draft Items
  final List<LotItemDraft> _draftItems = [];
  final List<ProcessedPhoto> _currentPhotos = [];

  // Active Item Entry State
  String _selectedCategory = 'PCB';
  String? _selectedSubCategory = 'संगणक (Computer)';
  ItemCondition _selectedCondition = ItemCondition.broken;
  String _weightInputString = '5';
  String _weightUnit = 'kg'; // 'kg' or 'gram'
  bool _showAllCategories = false;
  List<PredictionResult> _predictedCategories = [];
  bool _isScaleConnected = false;

  // Location State
  CollectorLocation? _currentLocation;

  // Cached benchmark rates per category
  final Map<String, ({double unitPrice, double minPrice, double maxPrice})> _rates = {
    'PCB': (unitPrice: 420.0, minPrice: 390.0, maxPrice: 450.0),
    'Cables': (unitPrice: 680.0, minPrice: 650.0, maxPrice: 720.0),
    'Batteries': (unitPrice: 140.0, minPrice: 120.0, maxPrice: 160.0),
    'LCD': (unitPrice: 45.0, minPrice: 35.0, maxPrice: 55.0),
    'Motors_Magnets': (unitPrice: 85.0, minPrice: 75.0, maxPrice: 95.0),
    'CRT': (unitPrice: 18.0, minPrice: 15.0, maxPrice: 22.0),
    'Mixed_Plastics': (unitPrice: 12.0, minPrice: 10.0, maxPrice: 15.0),
  };

  @override
  void initState() {
    super.initState();
    _classifier = widget.materialClassifier ?? MaterialClassifier();
    _locationService = widget.locationService ?? LocationService();
    _scaleService = widget.scaleService ?? StubBluetoothScaleService();

    _initAsyncServices();
  }

  Future<void> _initAsyncServices() async {
    await _classifier.initialize();
    _predictedCategories = await _classifier.predictTop3(hintCategory: _selectedCategory);

    final loc = await _locationService.getCurrentOrFallbackLocation();
    if (mounted) {
      setState(() {
        _currentLocation = loc;
      });
    }
  }

  double get _currentWeightKg {
    final parsed = double.tryParse(_weightInputString) ?? 0.0;
    return _weightUnit == 'gram' ? (parsed / 1000.0) : parsed;
  }

  double get _currentEstimatedValue {
    final rate = _rates[_selectedCategory] ?? (unitPrice: 100.0, minPrice: 90.0, maxPrice: 110.0);
    return (_currentWeightKg * rate.unitPrice).roundToDouble();
  }

  double get _currentMinPrice {
    final rate = _rates[_selectedCategory] ?? (unitPrice: 100.0, minPrice: 90.0, maxPrice: 110.0);
    return (_currentWeightKg * rate.minPrice).roundToDouble();
  }

  double get _currentMaxPrice {
    final rate = _rates[_selectedCategory] ?? (unitPrice: 100.0, minPrice: 90.0, maxPrice: 110.0);
    return (_currentWeightKg * rate.maxPrice).roundToDouble();
  }

  // ---------------------------------------------------------------------------
  // Camera & Image Capture
  // ---------------------------------------------------------------------------
  Future<void> _handleCapturePhoto() async {
    if (_currentPhotos.length >= 4) return;

    final photo = ImageProcessor.createMockPhoto(
      photoId: 'IMG_${DateTime.now().millisecondsSinceEpoch}_${_currentPhotos.length + 1}',
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
    );

    setState(() {
      _currentPhotos.add(photo);
    });

    unawaited(widget.audioService.speakPrompt('photoCaptured', localeOverride: widget.locale));

    // Run TFLite classifier on the newly captured image
    final top3 = await _classifier.predictTop3(
      imageBytes: photo.bytes,
      hintCategory: _selectedCategory,
    );

    setState(() {
      _predictedCategories = top3;
      if (top3.isNotEmpty) {
        _selectedCategory = top3.first.categoryId;
        _updateSubcategoryForCategory(_selectedCategory);
      }
    });
  }

  void _handleRemovePhoto(int index) {
    setState(() {
      _currentPhotos.removeAt(index);
    });
  }

  void _updateSubcategoryForCategory(String category) {
    switch (category) {
      case 'PCB':
        _selectedSubCategory = widget.locale == 'hi' ? 'कंप्यूटर बोर्ड' : 'संगणक बोर्ड (Computer)';
        break;
      case 'Batteries':
        _selectedSubCategory = 'Li-ion (लिथियम)';
        break;
      case 'Cables':
        _selectedSubCategory = widget.locale == 'hi' ? 'तांबा तार' : 'जाड तांबे (Thick Copper)';
        break;
      default:
        _selectedSubCategory = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Keypad & Weight Handling
  // ---------------------------------------------------------------------------
  void _onDigitPressed(String digit) {
    setState(() {
      if (_weightInputString == '0') {
        _weightInputString = digit;
      } else if (_weightInputString.length < 5) {
        _weightInputString += digit;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_weightInputString.length > 1) {
        _weightInputString = _weightInputString.substring(0, _weightInputString.length - 1);
      } else {
        _weightInputString = '0';
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Add Item to Draft Lot
  // ---------------------------------------------------------------------------
  void _addItemToLot() {
    final rate = _rates[_selectedCategory] ?? (unitPrice: 100.0, minPrice: 90.0, maxPrice: 110.0);
    final newItem = LotItemDraft(
      id: 'ITEM_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      condition: _selectedCondition,
      weightKg: _currentWeightKg,
      weightUnit: _weightUnit,
      unitPrice: rate.unitPrice,
      minPricePerKg: rate.minPrice,
      maxPricePerKg: rate.maxPrice,
      photos: List.from(_currentPhotos),
    );

    setState(() {
      _draftItems.add(newItem);
      _currentPhotos.clear();
      _weightInputString = '0';
    });

    HapticService.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.locale == 'hi'
              ? 'सामान लॉट में जोड़ा गया (${_draftItems.length} सामान)'
              : 'लॉटमध्ये माल जोडला गेला (${_draftItems.length} वस्तू)',
        ),
        backgroundColor: AppTheme.greenGoEarn,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save Full Offline Lot
  // ---------------------------------------------------------------------------
  Future<void> _saveOfflineLot() async {
    try {
      // If current inputs have weight, include current item as well
      if (_currentWeightKg > 0 && _draftItems.isEmpty) {
        _addItemToLot();
      }

      final totalWeight = _draftItems.fold(0.0, (acc, item) => acc + item.weightKg);
      final totalQuotedPrice = _draftItems.fold(0.0, (acc, item) => acc + item.estimatedTotalValue);
      final primaryCategory = _draftItems.isNotEmpty ? _draftItems.first.category : _selectedCategory;

      final allPhotoHashes = <String>[];
      for (final item in _draftItems) {
        allPhotoHashes.addAll(item.photoHashes);
      }

      final lat = _currentLocation?.latitude ?? 19.6967;
      final lng = _currentLocation?.longitude ?? 72.7699;

      final createdLot = await widget.lotRepository.createLotOffline(
        collectorId: widget.collectorId,
        category: primaryCategory,
        weightKg: totalWeight > 0 ? totalWeight : _currentWeightKg,
        quotedPrice: totalQuotedPrice > 0 ? totalQuotedPrice : _currentEstimatedValue,
        latitude: lat,
        longitude: lng,
        photoHashes: allPhotoHashes,
        items: _draftItems,
        subCategory: _selectedSubCategory,
        condition: _selectedCondition.dbValue,
      );

      widget.onLotSaved?.call(createdLot);

      await HapticService.heavyImpact();
      unawaited(widget.audioService.speakPrompt('lotSavedSuccess', localeOverride: widget.locale));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.locale == 'hi'
                        ? 'लॉट ${createdLot.lotId} फोन में सहेजा गया (सिंक प्रतीक्षा)'
                        : 'लॉट ${createdLot.lotId} फोनमध्ये सुरक्षित जतन (सिंक बाकी)',
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.greenGoEarn,
            duration: const Duration(seconds: 4),
          ),
        );

        setState(() {
          _draftItems.clear();
          _currentPhotos.clear();
          _weightInputString = '0';
        });
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[AddLotScreen] Error saving offline lot: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'hi' ? 'नया माल जोड़ें' : (locale == 'en' ? 'Add E-Waste Lot' : 'नवीन माल जोडा'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          SpeakerButton(
            promptKey: 'tabAddLot',
            audioService: widget.audioService,
            tooltip: 'सूचना ऐका',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Camera Photo Capture Section
              CameraCaptureCard(
                photos: _currentPhotos,
                onCapturePhoto: _handleCapturePhoto,
                onRemovePhoto: _handleRemovePhoto,
                locale: locale,
              ),
              const SizedBox(height: 18),

              // 2. On-Device TFLite Category Suggestions
              _buildCategorySelectionSection(locale),
              const SizedBox(height: 18),

              // 3. Sub-category & Condition Chips
              _buildSubCategoryAndConditionSection(locale),
              const SizedBox(height: 18),

              // 4. Weight Entry & Scale Section
              _buildWeightEntrySection(locale),
              const SizedBox(height: 18),

              // 5. Value Estimate Card
              ValueEstimateCard(
                estimatedPrice: _currentEstimatedValue,
                minPrice: _currentMinPrice,
                maxPrice: _currentMaxPrice,
                weightKg: _currentWeightKg,
                audioService: widget.audioService,
                locale: locale,
              ),
              const SizedBox(height: 20),

              // 6. Action Buttons: Add more items & Save Offline Lot
              _buildActionButtons(locale),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category Selection Widget (TFLite Top-3 + Manual)
  // ---------------------------------------------------------------------------
  Widget _buildCategorySelectionSection(String locale) {
    return Container(
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
                locale == 'hi'
                    ? 'AI सुझाई गई श्रेणियां (Top 3):'
                    : (locale == 'en' ? 'AI Suggested Categories:' : 'कॅमेरा सुचवलेले प्रकार (Top 3):'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () {
                  HapticService.selectionClick();
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                child: Text(
                  _showAllCategories
                      ? (locale == 'hi' ? 'कम दिखाएं' : 'कमी दाखवा')
                      : (locale == 'hi' ? 'सभी देखें' : 'सर्व पहा'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Top-3 Tiles
          Column(
            children: _predictedCategories.map((pred) {
              final isSelected = _selectedCategory == pred.categoryId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: BigTile(
                  title: pred.categoryId,
                  subtitle: '${pred.confidencePercent}% खात्री (Confidence)',
                  icon: pred.icon,
                  isSelected: isSelected,
                  primaryColor: pred.color,
                  minHeight: 80,
                  onTap: () {
                    setState(() {
                      _selectedCategory = pred.categoryId;
                      _updateSubcategoryForCategory(_selectedCategory);
                    });
                  },
                ),
              );
            }).toList(),
          ),

          // Expanded Manual Category Grid if toggled
          if (_showAllCategories) ...[
            const Divider(height: 24),
            Text(
              locale == 'hi' ? 'अन्य सभी श्रेणियां:' : 'इतर सर्व प्रकार:',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MaterialClassifier.categories.map((cat) {
                final id = cat['id'] as String;
                final isSelected = _selectedCategory == id;
                return ChoiceChip(
                  label: Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedCategory = id;
                        _updateSubcategoryForCategory(id);
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Category and Condition Section
  // ---------------------------------------------------------------------------
  Widget _buildSubCategoryAndConditionSection(String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Condition Chips
          ConditionChips(
            selectedCondition: _selectedCondition,
            onConditionChanged: (cond) {
              setState(() {
                _selectedCondition = cond;
              });
            },
            locale: locale,
          ),
          const SizedBox(height: 16),

          // Sub-Category Chips
          Text(
            locale == 'hi' ? 'उप-प्रकार (Sub-category):' : 'उप-प्रकार (Sub-category):',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _getSubcategoriesForActiveCategory(locale).map((sub) {
              final isSelected = _selectedSubCategory == sub;
              return ChoiceChip(
                label: Text(sub, style: const TextStyle(fontWeight: FontWeight.w800)),
                selected: isSelected,
                selectedColor: AppTheme.greenGoEarnLight,
                onSelected: (val) {
                  setState(() {
                    _selectedSubCategory = val ? sub : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getSubcategoriesForActiveCategory(String locale) {
    final isHi = locale == 'hi';
    switch (_selectedCategory) {
      case 'PCB':
        return [
          isHi ? 'कंप्यूटर' : 'संगणक (Computer)',
          isHi ? 'मोबाइल' : 'मोबाईल (Mobile)',
          isHi ? 'टीवी बोर्ड' : 'टीव्ही बोर्ड (TV)',
        ];
      case 'Batteries':
        return [
          'Li-ion (लिथियम)',
          'Lead-Acid (लेड-अ‍ॅसिड)',
        ];
      case 'Cables':
        return [
          isHi ? 'तांबा तार' : 'जाड तांबे (Thick Copper)',
          isHi ? 'मिक्स वायर' : 'मिक्स वायर (Mixed Wire)',
        ];
      default:
        return [
          isHi ? 'साधारण' : 'सामान्य (Standard)',
        ];
    }
  }

  // ---------------------------------------------------------------------------
  // Weight Entry & Big Keypad Section
  // ---------------------------------------------------------------------------
  Widget _buildWeightEntrySection(String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'hi' ? 'वजन दर्ज करें:' : 'वजन टाका:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),

              // kg / gram unit toggle
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('kg', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _weightUnit == 'kg',
                    onSelected: (val) {
                      if (val) setState(() => _weightUnit = 'kg');
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('gram', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _weightUnit == 'gram',
                    onSelected: (val) {
                      if (val) setState(() => _weightUnit = 'gram');
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weight Display Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor, width: 2),
            ),
            child: Text(
              '$_weightInputString $_weightUnit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppTheme.textHighContrast,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bluetooth Scale Stub Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isScaleConnected ? AppTheme.greenGoEarn : AppTheme.borderColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              HapticService.selectionClick();
              setState(() {
                _isScaleConnected = !_isScaleConnected;
                if (_isScaleConnected) {
                  _scaleService.connect('SCALE-01');
                  _weightInputString = '12.5';
                } else {
                  _scaleService.disconnect();
                }
              });
            },
            icon: Icon(
              Icons.scale_rounded,
              color: _isScaleConnected ? AppTheme.greenGoEarn : AppTheme.textMuted,
            ),
            label: Text(
              _isScaleConnected
                  ? (locale == 'hi' ? 'ब्लूटूथ कांटा कनेक्टेड (12.5 kg)' : 'ब्लूटूथ वजन काटा जोडला (12.5 kg)')
                  : (locale == 'hi' ? 'ब्लूटूथ तराजू कनेक्ट करें' : 'ब्लूटूथ वजन काटा जोडा'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isScaleConnected ? AppTheme.greenGoEarn : AppTheme.textHighContrast,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Reference Weight Helper
          ReferenceWeightHelper(
            category: _selectedCategory,
            onWeightSelected: (w) {
              setState(() {
                _weightUnit = 'kg';
                _weightInputString = w.toStringAsFixed(w.truncateToDouble() == w ? 0 : 1);
              });
            },
            locale: locale,
          ),
          const SizedBox(height: 14),

          // Big Numeric Keypad
          BigKeypad(
            onDigitPressed: _onDigitPressed,
            onBackspacePressed: _onBackspacePressed,
            onSubmitPressed: () {
              HapticService.mediumImpact();
            },
            showSubmit: false,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Buttons: Multi-item & Save Offline Lot
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Button: Add another item to this lot
        SizedBox(
          height: 58,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0284C7), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _addItemToLot,
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0284C7), size: 28),
            label: Text(
              locale == 'hi'
                  ? 'इस लॉट में और माल जोड़ें (+)'
                  : (locale == 'en' ? 'Add More Items to Lot (+)' : 'या लॉटमध्ये अजून माल जोडा (+)'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Button: Save Offline Lot (Green Go/Earn)
        SizedBox(
          height: 64,
          child: ElevatedButton.icon(
            key: const Key('save_offline_lot_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greenGoEarn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              _saveOfflineLot();
            },
            icon: const Icon(Icons.save_rounded, size: 30),
            label: Text(
              _draftItems.isEmpty
                  ? (locale == 'hi'
                      ? 'माल सुरक्षित सहेजें (Save Offline)'
                      : (locale == 'en' ? 'Save Lot Offline' : 'माल सुरक्षित जतन करा'))
                  : (locale == 'hi'
                      ? 'लॉट पूर्ण करें (${_draftItems.length} सामान)'
                      : (locale == 'en' ? 'Complete Lot (${_draftItems.length} Items)' : 'लॉट पूर्ण करा (${_draftItems.length} वस्तू)')),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
