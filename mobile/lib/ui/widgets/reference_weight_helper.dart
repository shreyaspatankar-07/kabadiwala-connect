import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';

class ReferenceWeightHelper extends StatelessWidget {
  const ReferenceWeightHelper({
    super.key,
    required this.category,
    required this.onWeightSelected,
    this.locale = 'mr',
  });

  final String category;
  final ValueChanged<double> onWeightSelected;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final references = _getReferencesForCategory(category, locale);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_size_select_actual_rounded, color: AppTheme.greenGoEarn, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locale == 'hi'
                      ? 'वजन संदर्भ चित्र (सहायक):'
                      : (locale == 'en' ? 'Reference Weight Guide:' : 'अंदाजे वजन संदर्भ चित्र:'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: references.map((ref) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticService.selectionClick();
                        onWeightSelected(ref.weightKg);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderColor, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(ref.icon, size: 32, color: AppTheme.greenGoEarn),
                            const SizedBox(height: 6),
                            Text(
                              '${ref.weightKg.toStringAsFixed(ref.weightKg.truncateToDouble() == ref.weightKg ? 0 : 1)} kg',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textHighContrast,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<({double weightKg, String label, IconData icon})> _getReferencesForCategory(
    String cat,
    String lang,
  ) {
    final bool isHi = lang == 'hi';
    switch (cat) {
      case 'Batteries':
        return [
          (weightKg: 0.5, label: isHi ? 'छोटा पैक' : 'छोटा पॅक', icon: Icons.battery_1_bar_rounded),
          (weightKg: 4.0, label: isHi ? 'बाइक बैटरी' : 'बाईक बॅटरी', icon: Icons.battery_5_bar_rounded),
          (weightKg: 18.0, label: isHi ? 'बड़ी इन्वर्टर' : 'मोठी इन्व्हर्टर', icon: Icons.battery_full_rounded),
        ];
      case 'Cables':
        return [
          (weightKg: 1.0, label: isHi ? 'छोटा बंडल' : 'छोटा बंडल', icon: Icons.cable_rounded),
          (weightKg: 5.0, label: isHi ? 'मध्यम थैला' : 'मध्यम गोणी', icon: Icons.shopping_bag_rounded),
          (weightKg: 20.0, label: isHi ? 'भारी बंडल' : 'मोठा ढीग', icon: Icons.inventory_2_rounded),
        ];
      case 'CRT':
        return [
          (weightKg: 8.0, label: isHi ? '14" मॉनिटर' : '१४" मॉनिटर', icon: Icons.tv_rounded),
          (weightKg: 16.0, label: isHi ? '21" टीवी' : '२१" टीव्ही', icon: Icons.tv_off_rounded),
          (weightKg: 25.0, label: isHi ? 'बड़ा टीवी' : 'मोठा टीव्ही', icon: Icons.desktop_windows_rounded),
        ];
      case 'PCB':
      default:
        return [
          (weightKg: 0.3, label: isHi ? 'मोबाइल बोर्ड' : 'मोबाईल बोर्ड', icon: Icons.smartphone_rounded),
          (weightKg: 5.0, label: isHi ? 'हा आकार ~ ५ कि.' : 'हा आकार ~ ५ कि.', icon: Icons.developer_board_rounded),
          (weightKg: 15.0, label: isHi ? 'बड़ा रैक' : 'मोठा रॅक', icon: Icons.storage_rounded),
        ];
    }
  }
}
