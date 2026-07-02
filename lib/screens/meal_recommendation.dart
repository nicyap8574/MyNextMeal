import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/meals/meal_recommendation_controller.dart';
import 'package:mynextmeal/utils/constants/colors.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import 'package:mynextmeal/utils/helpers/helper_functions.dart';

class MealRecommendation extends StatefulWidget {
  const MealRecommendation({super.key});

  @override
  State<MealRecommendation> createState() => _MealRecommendationState();
}

class _MealRecommendationState extends State<MealRecommendation> {
  late final MealRecommendationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MealRecommendationController());
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Meal recommendations'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeader(dark: dark),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Text(
                'Which meal are you planning?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Obx(
                () => _MealTypeSelector(
                  dark: dark,
                  selected: _controller.selectedMealType.value,
                  onSelected: _controller.selectMealType,
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Text(
                "Today's meals",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              _TodayMealsCard(
                dark: dark,
                future: _controller.displayTodayMeals(),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: _controller.isLoading.value
                        ? null
                        : _controller.generateMealRecs,
                    icon: _controller.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: dark
                                  ? AppColors.apricotCream900
                                  : AppColors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _controller.isLoading.value
                          ? 'Generating ideas…'
                          : 'Generate recommendations',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                        horizontal: AppSizes.lg,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Obx(() {
                final isLoading = _controller.isLoading.value;
                final response = _controller.response.value;
                final mealType = _controller.selectedMealType.value;
                final hasTodayMeals = _controller.todayMeals.isNotEmpty;

                return _RecommendationsSection(
                  dark: dark,
                  isLoading: isLoading,
                  response: response,
                  mealType: mealType,
                  hasTodayMeals: hasTodayMeals,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.celadon500;
    final surface = dark ? AppColors.apricotCream900 : AppColors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(
          color: accent.withOpacity(dark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: accent.withOpacity(dark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 32,
              color: dark ? AppColors.celadon400 : AppColors.celadon600,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized for you',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'AI-powered ideas based on your macros, diet goals, and what you have eaten today.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? AppColors.apricotCream200
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTypeSelector extends StatelessWidget {
  const _MealTypeSelector({
    required this.dark,
    required this.selected,
    required this.onSelected,
  });

  final bool dark;
  final MealType selected;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MealType.values.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != MealType.dinner ? AppSizes.sm : 0,
            ),
            child: _MealTypeChip(
              dark: dark,
              type: type,
              isSelected: isSelected,
              onTap: () => onSelected(type),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  const _MealTypeChip({
    required this.dark,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final bool dark;
  final MealType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.celadon500;
    final selectedBg =
        dark ? AppColors.celadon800.withOpacity(0.5) : AppColors.celadon50;
    final unselectedBg = dark ? AppColors.apricotCream900 : AppColors.white;
    final borderColor = isSelected
        ? accent.withOpacity(dark ? 0.7 : 0.55)
        : (dark ? AppColors.apricotCream800 : AppColors.apricotCream100);

    return Material(
      color: isSelected ? selectedBg : unselectedBg,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.md,
            horizontal: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                type.icon,
                size: 26,
                color: isSelected
                    ? (dark ? AppColors.celadon300 : AppColors.celadon600)
                    : (dark ? AppColors.apricotCream300 : AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                type.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (dark ? AppColors.white : AppColors.celadon700)
                          : (dark
                              ? AppColors.apricotCream200
                              : AppColors.textSecondary),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayMealsCard extends StatelessWidget {
  const _TodayMealsCard({
    required this.dark,
    required this.future,
  });

  final bool dark;
  final Future<dynamic> future;

  @override
  Widget build(BuildContext context) {
    final surface = dark ? AppColors.apricotCream900 : AppColors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerGrey.withOpacity(dark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _EmptyTodayState(
              dark: dark,
              icon: Icons.error_outline_rounded,
              message: 'Could not load today\'s meals',
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _EmptyTodayState(
              dark: dark,
              icon: Icons.no_meals_rounded,
              message: 'No meals logged yet today',
              subtitle:
                  'We\'ll use your diet preferences to suggest ideas.',
            );
          }

          final meals = snapshot.data!.docs as List;

          return Column(
            children: [
              for (var i = 0; i < meals.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: AppSizes.lg,
                    color: dark
                        ? AppColors.apricotCream800
                        : AppColors.apricotCream100,
                  ),
                _TodayMealRow(
                  dark: dark,
                  meal: meals[i].data() as Map<String, dynamic>,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState({
    required this.dark,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  final bool dark;
  final IconData icon;
  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: dark ? AppColors.apricotCream400 : AppColors.apricotCream500,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: dark ? AppColors.apricotCream200 : AppColors.textPrimary,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark
                        ? AppColors.apricotCream300
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayMealRow extends StatelessWidget {
  const _TodayMealRow({
    required this.dark,
    required this.meal,
  });

  final bool dark;
  final Map<String, dynamic> meal;

  @override
  Widget build(BuildContext context) {
    final nutrients = meal['analysis']?['nutrients'];
    final nutrient = (nutrients is List && nutrients.isNotEmpty)
        ? nutrients[0] as Map<String, dynamic>
        : <String, dynamic>{};

    final name = nutrient['meal_name']?.toString() ?? 'Unnamed meal';
    final carbs = nutrient['carbs_macro']?.toString() ?? '—';
    final protein = nutrient['protein_macro']?.toString() ?? '—';
    final fats = nutrient['fats_macro']?.toString() ?? '—';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.apricotCream400.withOpacity(dark ? 0.15 : 0.12),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          child: Icon(
            Icons.restaurant_rounded,
            size: 20,
            color: dark ? AppColors.apricotCream300 : AppColors.apricotCream600,
          ),
        ),
        const SizedBox(width: AppSizes.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'C: $carbs · P: $protein · F: $fats',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark
                          ? AppColors.apricotCream300
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({
    required this.dark,
    required this.isLoading,
    required this.response,
    required this.mealType,
    required this.hasTodayMeals,
  });

  final bool dark;
  final bool isLoading;
  final String response;
  final MealType mealType;
  final bool hasTodayMeals;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LoadingRecommendations(dark: dark);
    }

    if (response.isEmpty) {
      return const SizedBox.shrink();
    }

    if (response.contains('AI is currently busy')) {
      return _ErrorBanner(message: response);
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response) as Map<String, dynamic>;
    } catch (_) {
      return _ErrorBanner(message: 'Could not read recommendations. Please try again.');
    }

    final recommendations = data['recommendations'] as List<dynamic>? ?? [];
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final imbalanceExplanation =
        data['imbalanced_food_explanation']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm + 2,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.celadon500.withOpacity(dark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mealType.icon,
                    size: 14,
                    color: dark ? AppColors.celadon300 : AppColors.celadon600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mealType.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              dark ? AppColors.celadon300 : AppColors.celadon700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (imbalanceExplanation != null &&
            imbalanceExplanation.isNotEmpty &&
            hasTodayMeals) ...[
          const SizedBox(height: AppSizes.md),
          _InsightBanner(
            dark: dark,
            message: imbalanceExplanation,
          ),
        ],
        const SizedBox(height: AppSizes.md),
        for (var i = 0; i < recommendations.length; i++) ...[
          _RecommendationCard(
            dark: dark,
            index: i + 1,
            meal: recommendations[i] as Map<String, dynamic>,
          ),
          if (i < recommendations.length - 1)
            const SizedBox(height: AppSizes.md),
        ],
      ],
    );
  }
}

class _LoadingRecommendations extends StatelessWidget {
  const _LoadingRecommendations({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: dark ? AppColors.apricotCream900 : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSizes.md),
          Text(
            'Crafting your meal ideas…',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'This usually takes a few seconds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark
                      ? AppColors.apricotCream300
                      : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({
    required this.dark,
    required this.message,
  });

  final bool dark;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.celadon500.withOpacity(dark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: AppColors.celadon500.withOpacity(dark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 22,
            color: dark ? AppColors.celadon300 : AppColors.celadon600,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition insight',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            dark ? AppColors.celadon300 : AppColors.celadon700,
                      ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: dark
                            ? AppColors.apricotCream100
                            : AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.dark,
    required this.index,
    required this.meal,
  });

  final bool dark;
  final int index;
  final Map<String, dynamic> meal;

  @override
  Widget build(BuildContext context) {
    final surface = dark ? AppColors.apricotCream900 : AppColors.white;
    final accent = AppColors.celadon500;
    final name = meal['meal_name']?.toString() ?? 'Untitled dish';
    final description = meal['description']?.toString() ?? '';
    final ingredients =
        (meal['main_ingredients'] as List<dynamic>?)?.cast<String>() ?? [];
    final suitableFor =
        (meal['suitable_for'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(
          color: accent.withOpacity(dark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerGrey.withOpacity(dark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: accent.withOpacity(dark ? 0.12 : 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.cardRadiusLg - 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(dark ? 0.35 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: dark ? AppColors.white : AppColors.celadon800,
                        ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm + 2),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: dark
                              ? AppColors.apricotCream100
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                if (ingredients.isNotEmpty) ...[
                  _SectionLabel(
                    dark: dark,
                    icon: Icons.shopping_basket_outlined,
                    label: 'Main ingredients',
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: ingredients.map((item) {
                      return _IngredientChip(dark: dark, label: item);
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                if (suitableFor.isNotEmpty) ...[
                  _SectionLabel(
                    dark: dark,
                    icon: Icons.favorite_outline_rounded,
                    label: 'Suitable for',
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: suitableFor.map((item) {
                      return _DietChip(dark: dark, label: item);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.dark,
    required this.icon,
    required this.label,
  });

  final bool dark;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: dark ? AppColors.apricotCream400 : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.dark, required this.label});

  final bool dark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.apricotCream800.withOpacity(0.5)
            : AppColors.apricotCream50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark ? AppColors.apricotCream700 : AppColors.apricotCream200,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: dark ? AppColors.apricotCream100 : AppColors.textPrimary,
            ),
      ),
    );
  }
}

class _DietChip extends StatelessWidget {
  const _DietChip({required this.dark, required this.label});

  final bool dark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.celadon500.withOpacity(dark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.celadon500.withOpacity(dark ? 0.4 : 0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: dark ? AppColors.celadon300 : AppColors.celadon700,
            ),
      ),
    );
  }
}
