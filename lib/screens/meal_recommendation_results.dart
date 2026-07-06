import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../common/spacing_styles.dart';
import '../features/meals/meal_recommendation_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class MealRecommendationResults extends StatefulWidget {
  const MealRecommendationResults({super.key});

  @override
  State<MealRecommendationResults> createState() => _MealRecommendationResultsState();
}

class _MealRecommendationResultsState extends State<MealRecommendationResults> {
  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(MealRecommendationController());

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Meal Recommendation Results"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                              data['imbalanced_food_explanation'] ?? 'Add your first meal to generate an imbalanced food explanation',
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recommended Options",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Obx((){
                            if(controller.isLoading.value){
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }

                            return IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: () => controller.generateMealRecs(),
                            );
                          }),
                        ],
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

                                      const SizedBox(height: AppSizes.spaceBtwItems),


                                      const Text(
                                        'Ingredients',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      const SizedBox(height: AppSizes.spaceBtwItems/2),


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

                                      const SizedBox(height: AppSizes.spaceBtwItems),


                                      //suitable for
                                      const Text(
                                        'Suitable For',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      const SizedBox(height: AppSizes.spaceBtwItems/2),

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
                                  ),
                              ),
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
