import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../common/styles/spacing_styles.dart';
import '../features/controllers/meal_recommendation_controller.dart';
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Color(0xFFF8F5D3),
                    border: Border.all(color: Colors.transparent, width: 0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkerGrey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0,4),
                      ),
                    ],
                  ),
                  
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Today's Meals",
                          style: TextStyle(fontSize: AppSizes.md, fontWeight: FontWeight.bold)),

                      // Expanded(
                      // child:
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
                    // )
                  ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                    ),
                    onPressed: () => controller.generateMealRecs(),
                    child: Text("Generate Meal Recommendations"),
                  )
                )
              ],
            ),
          )
        )
    );
  }
}
