import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';
import 'package:mynextmeal/screens/meal_recommendation.dart';
import '../features/user/user_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'image_analysis.dart';
import 'individual_meal.dart';
import 'package:material_symbols_icons/symbols.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  static bool isSameDay(DateTime a, DateTime b){
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String greetingForTime(){
    final hour = DateTime.now().hour;
    if(hour<12){
      return 'Good morning';
    }else if(hour >= 12 && hour < 17){
      return 'Good afternoon';
    }else{
      return 'Good evening';
    }
  }

  static int macroRank(String? value){
    switch(value){
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

  static String aggregateMacro(List<QueryDocumentSnapshot<Map<String,dynamic>>> meals, String key){
    if(meals.isEmpty){
      return '-';
    }

    var best = 0;
    var label = 'Unknown';

    for(final doc in meals){
      final nutrients = doc.data()['analysis']?['nutrients'];
      if(nutrients is! List || nutrients.isEmpty){
        continue;
      }
      final value = nutrients[0][key]?.toString();
      final rank = macroRank(value);
      if(rank > best){
        best = rank;
        label = value ?? 'Unknown';
      }
    }

    return best == 0 ? '-' : label;
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  Obx((){
                    final name = controller.user.value.username;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greetingForTime(), style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          name.isNotEmpty ? name : '',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: dark ? AppColors.white : AppColors.textPrimary,
                          ),
                        )
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

                  StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                      stream: mealHistoryController.displayCurrentUserMeals(),
                      builder: (context, snapshot){
                        final todayMeals = <QueryDocumentSnapshot<Map<String,dynamic>>>[];

                        if(snapshot.hasData){
                          for(final doc in snapshot.data!.docs){
                            final createdAt = doc.data()['createdAt'];
                            if(createdAt == null){
                              continue;
                            }
                            final date = (createdAt as Timestamp).toDate();
                            if(isSameDay(date,today)){
                              todayMeals.add(doc);
                            }
                          }
                        }

                        final carbs = aggregateMacro(todayMeals, 'carbs_macro');
                        final protein = aggregateMacro(todayMeals, 'protein_macro');
                        final fats = aggregateMacro(todayMeals, 'fats_macro');

                        return Row(
                          children: [
                            Expanded(
                              child: MacroPill(
                                label: 'Carbs',
                                value: carbs,
                                icon: Icons.ramen_dining,
                                accent: AppColors.apricotCream500,
                                dark: dark,
                              ),
                            ),

                            const SizedBox(width: AppSizes.sm),

                            Expanded(
                              child: MacroPill(
                                label: 'Protein',
                                value: protein,
                                icon: Symbols.exercise,
                                accent: AppColors.celadon500,
                                dark: dark,
                              ),
                            ),

                            const SizedBox(width: AppSizes.sm),

                            Expanded(
                              child: MacroPill(
                                label: 'Fat',
                                value: fats,
                                icon: Icons.icecream,
                                accent: AppColors.apricotCream700,
                                dark: dark,
                              ),
                            ),
                          ],
                        );
                      },
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF221E19) : AppColors.white,
                      border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent),
                      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkerGrey.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems/2),
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => const MealRecommendation()),
                      icon: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 22,
                      ),
                      label: const Text(
                        'Get meal recommendations',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  Text(
                    "Today's meals",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                      stream: mealHistoryController.displayCurrentUserMeals(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator());
                        }

                        if(snapshot.hasError){
                          return Center(child: Text(snapshot.error.toString()));
                        }

                        final todayMeals = snapshot.data!.docs.where((doc){
                          final createdAt = doc.data()['createdAt'];
                          if(createdAt == null) return false;
                          return isSameDay(
                            (createdAt as Timestamp).toDate(),
                            today,
                          );
                        }).toList();

                        if(todayMeals.isEmpty){
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.spaceBtwSections,
                              horizontal: AppSizes.lg,
                            ),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF221E19) : AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                              border: Border.all(
                                color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.lunch_dining,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                SizedBox(height: AppSizes.md),
                                Text(
                                  'No meals logged today',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AppSizes.xs),
                                Text(
                                  "Let's get started by adding your first meal!",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppSizes.md),
                                ElevatedButton(
                                    onPressed: () => Get.to(() => const ImageAnalysis()),
                                    child: Text('Add my first meal'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                            itemCount: todayMeals.length > 5 ? 5 : todayMeals.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context,index){
                              final meal = todayMeals[index].data(); //JSON output from Firestore
                              final mealId = todayMeals[index].id;

                              //format date for output
                              final timestamp = meal['createdAt'];
                              final date = timestamp.toDate();
                              final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                              return GestureDetector(
                                onTap: () => Get.to(() => IndividualMeal(mealId, meal['imageUrl'])),

                                child: Container(
                                    width: double.infinity,
                                    height: 95,
                                    margin: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems/2),

                                    decoration: BoxDecoration(
                                      color: dark ? const Color(0xFF221E19) : AppColors.white,
                                      border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkerGrey.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0,4),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(5),
                                    ),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                              width: 95,
                                              child: meal['imageUrl'] != null && meal['imageUrl'].toString().isNotEmpty
                                                      ? Image.network(
                                                          meal['imageUrl'],
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(Icons.fastfood, color: Colors.white),
                                                      ),
                                            ),

                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                        "Carbs: ${meal['analysis']['nutrients'][0]['carbs_macro']} | Protein: ${meal['analysis']['nutrients'][0]['protein_macro']} | Fats: ${meal['analysis']['nutrients'][0]['fats_macro']} \n"
                                                        "Uploaded At: $formattedDateTime",
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                )
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ),
                              );
                            }
                        );
                      }
                  )
                ],
              ),
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ImageAnalysis()),
        // backgroundColor: AppColors.apricotCream700,
        backgroundColor: dark ? AppColors.apricotCream600 : AppColors.apricotCream700,
        foregroundColor: AppColors.apricotCream100,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MacroPill extends StatelessWidget{
  const MacroPill({
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
    final surface = dark ? const Color(0xFF221E19) : AppColors.white;
    final border = accent.withOpacity(dark ? 0.45: 0.35);

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
  }}