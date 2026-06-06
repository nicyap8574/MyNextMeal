import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/meal_analysis_helpers.dart';

class MacroBreakdownBar extends StatelessWidget {
  const MacroBreakdownBar({
    super.key,
    required this.label,
    required this.level,
    required this.icon,
    required this.dark,
    this.onLevelChanged,
  });

  final String label;
  final String level;
  final IconData icon;
  final bool dark;
  final ValueChanged<String>? onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final color = MealAnalysisHelpers.macroColor(level, dark: dark);
    final plainLabel = MealAnalysisHelpers.macroPlainLabel(level);
    final progress = MealAnalysisHelpers.macroToProgress(level);
    final surface = dark ? AppColors.darkContainer : AppColors.white;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: color.withOpacity(dark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSizes.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plainLabel,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeSm,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: dark
                  ? AppColors.darkerGrey.withOpacity(0.4)
                  : AppColors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (onLevelChanged != null) ...[
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              children: MealAnalysisHelpers.macroLevels.map((option) {
                final selected = level == option;
                return ChoiceChip(
                  label: Text(MealAnalysisHelpers.macroPlainLabel(option)),
                  selected: selected,
                  onSelected: (_) => onLevelChanged!(option),
                  selectedColor: color.withOpacity(0.25),
                  labelStyle: TextStyle(
                    fontSize: AppSizes.fontSizeSm,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
