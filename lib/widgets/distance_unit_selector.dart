import 'package:flutter/material.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Compact unit selector for distance input (m / km / ft / mi).
class DistanceUnitSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const DistanceUnitSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const units = ['m', 'km', 'ft', 'mi'];
    return Wrap(
      spacing: 4,
      children: units.map((unit) {
        final isSelected = selected == unit;
        return ChoiceChip(
          label: Text(unit),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onChanged(unit),
          labelStyle: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}
