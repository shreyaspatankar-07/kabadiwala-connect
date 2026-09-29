import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lot_item_draft.dart';

/// Low-literacy condition selection chips with high-contrast semantic colors
/// (Working = Green, Broken = Yellow, Damaged = Orange, Burnt = Red).
class ConditionChips extends StatelessWidget {
  const ConditionChips({
    super.key,
    required this.selectedCondition,
    required this.onConditionChanged,
    this.locale = 'mr',
  });

  final ItemCondition selectedCondition;
  final ValueChanged<ItemCondition> onConditionChanged;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final List<({ItemCondition cond, String label, IconData icon, Color color, Color bg})> conditions = [
      (
        cond: ItemCondition.working,
        label: locale == 'hi' ? 'चालू स्थिति' : (locale == 'en' ? 'Working' : 'चालू स्थिति'),
        icon: Icons.check_circle_rounded,
        color: AppTheme.greenGoEarn,
        bg: AppTheme.greenGoEarnLight,
      ),
      (
        cond: ItemCondition.broken,
        label: locale == 'hi' ? 'टूटा हुआ' : (locale == 'en' ? 'Broken' : 'फुटलेला'),
        icon: Icons.broken_image_rounded,
        color: AppTheme.yellowPending,
        bg: AppTheme.yellowPendingLight,
      ),
      (
        cond: ItemCondition.damaged,
        label: locale == 'hi' ? 'खराब' : (locale == 'en' ? 'Damaged' : 'खराब'),
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFEA580C),
        bg: const Color(0xFFFFEDD5),
      ),
      (
        cond: ItemCondition.burnt,
        label: locale == 'hi' ? 'जला हुआ' : (locale == 'en' ? 'Burnt' : 'जळालेला'),
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.dangerRed,
        bg: AppTheme.dangerRedLight,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'hi' ? 'सामान की स्थिति:' : (locale == 'en' ? 'Item Condition:' : 'मालाची स्थिती:'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: conditions.map((item) {
            final isSelected = selectedCondition == item.cond;
            return Material(
              key: Key('condition_${item.cond.name}'),
              color: isSelected ? item.bg : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                key: Key('condition_chip_${item.cond.name}'),
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticService.selectionClick();
                  onConditionChanged(item.cond);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? item.color : AppTheme.borderColor,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: item.color, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? item.color : AppTheme.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
