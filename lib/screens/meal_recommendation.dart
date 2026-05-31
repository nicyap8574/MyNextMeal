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

class MealRecommendation extends StatefulWidget {
  const MealRecommendation({super.key});

  @override
  State<MealRecommendation> createState() => _MealRecommendationState();
}

class _MealRecommendationState extends State<MealRecommendation> {


  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(MealRecommendationController());
    final todayMeals = controller.todayMeals;

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
                    color: AppColors.apricotCream100,
                    border: Border.all(color: Colors.transparent, width: 0),
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
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Today's Meals",
                          style: TextStyle(fontSize: AppSizes.md, fontWeight: FontWeight.bold)),

                      SizedBox(height: AppSizes.spaceBtwItems),

                      FutureBuilder(
                        future: controller.displayTodayMeals(),
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
                    final meal = recommendations[0] as Map<String, dynamic>;
                    final mealName = meal['meal_name'];
                    final description = meal['description'];
                    // if(todayMeals.isNotEmpty){
                    //   final imbalanced_explanation = meal['imbalanced_explanation'];
                    // }
                    final mainIngredients = meal['main_ingredients'] as List<dynamic>;
                    final suitableFor = meal['suitable_for'] as List<dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        for (var meal in recommendations)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dish Name"),
                              Chip(
                                label: Text(meal['meal_name']),
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text("Description"),
                              Text(meal['description']),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              if(todayMeals.isNotEmpty)
                                Text("Reasoning"),
                                Text(meal['imbalanced_explanation'] ?? "No reasoning available") ,

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text("Main Ingredients"),
                              Wrap(
                                spacing: 8,
                                children: (meal['main_ingredients'] as List<dynamic>).map((individual_ingredient){
                                  return Chip(
                                    label: Text(individual_ingredient),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text("Suitable For"),
                              Wrap(
                                spacing: 8,
                                children: (meal['suitable_for'] as List<dynamic>).map((individual_suitableFor){
                                  return Chip(
                                    label: Text(individual_suitableFor),
                                  );
                                }).toList(),
                              ),
                            ],
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
