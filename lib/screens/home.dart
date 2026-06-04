import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';
import '../features/user/user_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'image_analysis.dart';
import 'individual_meal.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _greetingForTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static int _macroRank(String? value) {
    switch (value) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }

  static String _aggregateMacro(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> meals,
    String key,
  ) {
    if (meals.isEmpty) return '—';

    var best = 0;
    var label = 'Unknown';

    for (final doc in meals) {
      final nutrients = doc.data()['analysis']?['nutrients'];
      if (nutrients is! List || nutrients.isEmpty) continue;
      final value = nutrients[0][key]?.toString();
      final rank = _macroRank(value);
      if (rank > best) {
        best = rank;
        label = value ?? 'Unknown';
      }
    }

    return best == 0 ? '—' : label;
  }

  static String? _moodTag(Map<String, dynamic> meal) {
    final direct = meal['mood'] ?? meal['moodTag'];
    if (direct != null && direct.toString().isNotEmpty) {
      return direct.toString();
    }

    final checkIn = meal['checkIn'] ?? meal['postMealCheckIn'];
    if (checkIn is Map) {
      final mood = checkIn['mood'] ?? checkIn['moodTag'];
      if (mood != null && mood.toString().isNotEmpty) {
        return mood.toString();
      }
    }

    return null;
  }

  static Color _moodColor(String mood, bool dark) {
    final normalized = mood.toLowerCase();
    if (normalized.contains('great') ||
        normalized.contains('happy') ||
        normalized.contains('energ')) {
      return dark ? AppColors.celadon400 : AppColors.celadon600;
    }
    if (normalized.contains('okay') || normalized.contains('neutral')) {
      return dark ? AppColors.apricotCream400 : AppColors.apricotCream600;
    }
    if (normalized.contains('tired') ||
        normalized.contains('sluggish') ||
        normalized.contains('low')) {
      return dark ? AppColors.apricotCream300 : AppColors.apricotCream700;
    }
    return dark ? AppColors.darkGrey : AppColors.darkerGrey;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final mealHistoryController = Get.find<MealHistoryController>();
    final dark = AppHelperFunctions.isDarkMode(context);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.defaultSpace,
                AppSizes.md,
                AppSizes.defaultSpace,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final name = controller.user.value.username;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greetingForTime(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: dark
                                    ? AppColors.apricotCream200
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          name.isNotEmpty ? name : 'there',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: dark ? AppColors.white : AppColors.textPrimary,
                              ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    "Today's macros",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? AppColors.apricotCream100 : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: mealHistoryController.displayCurrentUserMeals(),
                    builder: (context, snapshot) {
                      final todayMeals = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                      if (snapshot.hasData) {
                        for (final doc in snapshot.data!.docs) {
                          final createdAt = doc.data()['createdAt'];
                          if (createdAt == null) continue;
                          final date = (createdAt as Timestamp).toDate();
                          if (_isSameDay(date, today)) {
                            todayMeals.add(doc);
                          }
                        }
                      }

                      final carbs = _aggregateMacro(todayMeals, 'carbs_macro');
                      final protein =
                          _aggregateMacro(todayMeals, 'protein_macro');
                      final fats = _aggregateMacro(todayMeals, 'fats_macro');

                      return Row(
                        children: [
                          Expanded(
                            child: _MacroPill(
                              label: 'Carbs',
                              value: carbs,
                              icon: Icons.grain_rounded,
                              accent: AppColors.apricotCream500,
                              dark: dark,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _MacroPill(
                              label: 'Protein',
                              value: protein,
                              icon: Icons.fitness_center_rounded,
                              accent: AppColors.celadon500,
                              dark: dark,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _MacroPill(
                              label: 'Fat',
                              value: fats,
                              icon: Icons.water_drop_rounded,
                              accent: AppColors.apricotCream700,
                              dark: dark,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Text(
                    "Today's meals",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: mealHistoryController.displayCurrentUserMeals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _TodayEmptyState(dark: dark);
                      }

                      final todayMeals = snapshot.data!.docs.where((doc) {
                        final createdAt = doc.data()['createdAt'];
                        if (createdAt == null) return false;
                        return _isSameDay(
                          (createdAt as Timestamp).toDate(),
                          today,
                        );
                      }).toList()
                        ..sort((a, b) {
                          final aTime =
                              (a.data()['createdAt'] as Timestamp).toDate();
                          final bTime =
                              (b.data()['createdAt'] as Timestamp).toDate();
                          return aTime.compareTo(bTime);
                        });

                      if (todayMeals.isEmpty) {
                        return _TodayEmptyState(dark: dark);
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayMeals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) {
                          final doc = todayMeals[index];
                          final meal = doc.data();
                          final mealId = doc.id;
                          final nutrients = meal['analysis']?['nutrients'];
                          final mealName = (nutrients is List &&
                                  nutrients.isNotEmpty)
                              ? nutrients[0]['meal_name']?.toString() ??
                                  'Unnamed meal'
                              : 'Unnamed meal';
                          final loggedAt =
                              (meal['createdAt'] as Timestamp).toDate();
                          final timeLabel =
                              DateFormat('h:mm a').format(loggedAt);
                          final mood = _moodTag(meal);
                          final imageUrl = meal['imageUrl']?.toString();

                          return _MealLogTile(
                            mealName: mealName,
                            timeLabel: timeLabel,
                            mood: mood,
                            imageUrl: imageUrl,
                            dark: dark,
                            onTap: () => Get.to(
                              () => IndividualMeal(mealId, imageUrl ?? ''),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.defaultSpace,
                AppSizes.sm,
                AppSizes.defaultSpace,
                AppSizes.md,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(dark ? 0.35 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const ImageAnalysis()),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 22),
                    label: const Text(
                      'Log a meal',
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadiusLg),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.dark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final surface = dark ? AppColors.apricotCream900 : AppColors.white;
    final border = accent.withOpacity(dark ? 0.45 : 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark ? AppColors.white : AppColors.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MealLogTile extends StatelessWidget {
  const _MealLogTile({
    required this.mealName,
    required this.timeLabel,
    required this.mood,
    required this.imageUrl,
    required this.dark,
    required this.onTap,
  });

  final String mealName;
  final String timeLabel;
  final String? mood;
  final String? imageUrl;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? AppColors.apricotCream900 : AppColors.white;

    return Material(
      color: cardColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            border: Border.all(
              color: dark
                  ? AppColors.apricotCream800
                  : AppColors.apricotCream100,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkerGrey.withOpacity(dark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbnailPlaceholder(dark),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _thumbnailPlaceholder(dark);
                          },
                        )
                      : _thumbnailPlaceholder(dark),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: dark
                              ? AppColors.apricotCream300
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark
                                    ? AppColors.apricotCream200
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (mood != null) ...[
                const SizedBox(width: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Home._moodColor(mood!, dark).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    mood!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Home._moodColor(mood!, dark),
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder(bool dark) {
    return ColoredBox(
      color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
      child: Icon(
        Icons.restaurant_rounded,
        color: dark ? AppColors.apricotCream400 : AppColors.apricotCream600,
      ),
    );
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceBtwSections,
        horizontal: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.apricotCream900 : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lunch_dining_outlined,
            size: 40,
            color: dark ? AppColors.apricotCream400 : AppColors.apricotCream600,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No meals logged today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Tap Log a meal below to add your first entry.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
