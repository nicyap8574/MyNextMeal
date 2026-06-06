import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/meal_analysis_helpers.dart';

class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    super.key,
    required this.level,
    required this.dark,
  });

  final String level;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = MealAnalysisHelpers.confidenceColor(level, dark: dark);
    final progress = MealAnalysisHelpers.confidenceToProgress(level);
    final message = MealAnalysisHelpers.confidenceMessage(level);
    final surface = dark ? AppColors.darkContainer : AppColors.white;
    final isUncertain = level == 'Low' || level == 'Medium';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: color.withOpacity(isUncertain ? 0.6 : 0.35),
          width: isUncertain ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUncertain ? Icons.info_outline_rounded : Icons.verified_outlined,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'AI confidence',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: AppSizes.fontSizeMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: dark
                  ? AppColors.darkerGrey.withOpacity(0.4)
                  : AppColors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
