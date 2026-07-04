import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../common/spacing_styles.dart';
import '../features/meals/meal_recommendation_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class MealRecommendation extends StatefulWidget {
  const MealRecommendation({super.key});

  @override
  State<MealRecommendation> createState() => _MealRecommendationState();
}

class _MealRecommendationState extends State<MealRecommendation> {
  final List<String> mealType = ['Breakfast','Lunch','Dinner','Supper','Snack'];
  // String selectedMealType = '';
  late Future<QuerySnapshot<Map<String,dynamic>>> todayMeals;

  @override
  void initState(){
    super.initState();

    final controller = Get.put(MealRecommendationController());
    todayMeals = controller.displayTodayMeals();
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(MealRecommendationController());
    // final todayMeals = controller.todayMeals;
    // var mealType = controller.mealType;


    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text("Meal Recommendation"),
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: AppSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                //Container to display today's meals
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: dark ?  const Color(0xFF221E19) : AppColors.apricotCream100,
                    border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkerGrey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0,4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Today's Meal History",
                          style: TextStyle(fontSize: AppSizes.md, fontWeight: FontWeight.bold)
                      ),

                      SizedBox(height: AppSizes.spaceBtwItems),

                      FutureBuilder(
                        future: todayMeals,
                        builder: (context, todayMeal){

                          if(todayMeal.connectionState == ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator());
                          }

                          if(!todayMeal.hasData || todayMeal.data!.docs.isEmpty){
                            return const Center(child: Text("No meals found"));
                          }

                          if(todayMeal.hasError){
                            return Center(child: Text(todayMeal.error.toString()));
                          }

                          final meals = todayMeal.data!.docs;

                          return ListView.builder(
                              itemCount: meals.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                final meal = meals[index].data(); //JSON output from Firestore
                                return ListTile(
                                  title: Text(meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name'),
                                  subtitle: Text(
                                      "Carbs: ${meal['analysis']['nutrients'][0]['carbs_macro']} | Protein: ${meal['analysis']['nutrients'][0]['protein_macro']} | Fats: ${meal['analysis']['nutrients'][0]['fats_macro']} "),
                                );
                              }
                          );
                        }
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Meal Type",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Which meal are you planning next?',
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    //meal type chips selector
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(mealType.length, (index){
                        final type = mealType[index];
                        final isSelected = controller.selectedMealType.value == type;

                        return ChoiceChip(
                            label: Text(type),
                            showCheckmark: false,
                            selected: isSelected,
                            // showCheckmark: false,
                            onSelected: (bool selected){
                              setState((){
                                controller.selectedMealType.value = selected ? type : '';
                              });
                            },
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                //preferred and avoided categories
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF221E19) : AppColors.white,
                    border: Border.all(
                      color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meal Preferences",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            color: dark ? const Color(0xFF81C784) : const Color(0xFF366339),
                            size: 18
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preferred Categories',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Obx(() {
                                  if(controller.preferredCategories.isEmpty){
                                    return const Text("No preferred categories yet",
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic));
                                  }
                                  return Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: controller.preferredCategories.map((category){
                                      return Chip(
                                        avatar: const Icon(Icons.check, size: 12, color: Color(0xFF366339)),
                                        label: Text(
                                          category,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF366339), fontWeight: FontWeight.bold),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: const Color(0xFF366339).withOpacity(0.1),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                              Icons.block_outlined,
                              color: dark ? const Color(0xFFEF959D) : const Color(0xFF960018),
                              size: 18
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Avoided Categories',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Obx(() {
                                  if(controller.avoidCategories.isEmpty){
                                    return const Text("No avoided categories yet",
                                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic));
                                  }
                                  return Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: controller.avoidCategories.map((category){
                                      return Chip(
                                        avatar: const Icon(Icons.close, size: 12, color: Color(0xFF960018)),
                                        label: Text(
                                          category,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF960018), fontWeight: FontWeight.bold),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: const Color(0xFF960018).withOpacity(0.1),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => controller.generateMealRecs(),
                  child: const Text("Generate Meal Recommendations"),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Obx(() {
                  if (controller.isLoading.value == true) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSizes.spaceBtwItems),
                          const Text("Response is loading..."),
                        ],
                      ),
                    );
                  } else {
                    if (controller.response.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final data = jsonDecode(controller.response.value);
                    final recommendations = data['recommendations'] as List<dynamic>;
                    // final meal = recommendations[0] as Map<String, dynamic>;
                    // final mealName = meal['meal_name'];
                    // final description = meal['description'];
                    // final mainIngredients = meal['main_ingredients'] as List<dynamic>;
                    // final suitableFor = meal['suitable_for'] as List<dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF2A2115) : AppColors.apricotCream50,
                            border: Border.all(
                              color: dark ? AppColors.apricotCream800.withOpacity(0.4) : AppColors.apricotCream200,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${data['meal_type'][0].toUpperCase()}${data['meal_type'].substring(1)} Recommendations", //capitalise first letter of word
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: dark ? AppColors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data['imbalanced_food_explanation'] ?? 'No inbalanced food explanation available',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: dark ? Colors.white70 : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Recommended Options",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        for (var meal in recommendations)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF221E19) : AppColors.white,
                              border: Border.all(
                                color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(dark ? 0.2 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0,4),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsGeometry.fromLTRB(16, 16, 16, 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.restaurant, color: AppColors.primary, size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          meal['meal_name'] ?? 'Unknown Dish',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1),

                                //meal details
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //meal description
                                      Text(
                                        meal['description'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: dark ? Colors.white70 : AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      const Text(
                                        'Ingredients',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      //meal ingredients

                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (meal['main_ingredients'] as List<dynamic>).map((individual_ingredient){
                                          return Chip(
                                            label: Text(
                                              individual_ingredient.toString(),
                                              style: TextStyle(color: dark ? Colors.white70 : AppColors.textPrimary),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: dark ? Colors.white.withOpacity(0.05) : AppColors.softGrey,
                                            side: BorderSide.none,
                                          );
                                        }).toList(),
                                      ),

                                      const SizedBox(height: 16),

                                      //suitable for
                                      const Text(
                                        'Suitable For',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (meal['suitable_for'] as List<dynamic>).map((individual_suitableFor){
                                          return Chip(
                                            label: Text(
                                              individual_suitableFor.toString(),
                                              style: TextStyle(
                                                color: Color(0xFF59A65E),
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: dark ? AppColors.celadon300.withOpacity(0.12) : const Color(0xFF59A65E).withOpacity(0.12),
                                            side: BorderSide.none,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )
                                )
                              ],
                            ),
                          ),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
    );
  }
}
