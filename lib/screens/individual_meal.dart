import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/meals/individual_meal_controller.dart';
import '../common/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class IndividualMeal extends StatelessWidget {
  final String mealId;
  final String imageUrl;
  const IndividualMeal(this.mealId, this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IndividualMealController>();
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Meal Details"),
      ),

      body: SingleChildScrollView(
        child: Padding(
            padding: AppSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    fit: BoxFit.cover
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                FutureBuilder(
                    future: controller.getIndividualMeal(mealId),
                    builder: (context, meal){

                      if(meal.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      }

                      if(meal.hasError){
                        return Center(child: Text(meal.error.toString()));
                      }

                      if(!meal.hasData || meal.data == null){
                        return const Center(child: Text("No data found"));
                      }

                      print(mealId);

                      final nutrients = meal.data!['analysis']['nutrients'][0];
                      final mealName = nutrients['meal_name'];
                      final ingredients = nutrients['detected_ingredients'] as List<dynamic>;
                      final carbsMacro = nutrients['carbs_macro'];
                      final proteinMacro = nutrients['protein_macro'];
                      final fatsMacro = nutrients['fats_macro'];
                      final mealHealthiness = nutrients['meal_healthiness'];
                      final confidenceLevel = nutrients['confidence_level'];
                      final briefSummary = nutrients['brief_summary'];
                      final createdAt = meal.data!['createdAt'].toDate();
                      final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
                      final sentiment = meal.data!['sentiment'];
                      final sentimentLabel = meal.data!['sentimentLabel'];
                      final mealCategory = nutrients['category'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dish Name",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: AppSizes.sm),

                          Chip(
                            label: Text(mealName),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              "Category"
                          ),

                          Chip(
                            label: Text(mealCategory),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Ingredients",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Wrap(
                            spacing: 8,
                            children: ingredients.map((individual_ingredient){
                              return Chip(
                                label: Text(individual_ingredient),
                              );
                            }).toList(), //converts Iterable to List<Widget> to be accepted by children
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Carbs Macro",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Chip(
                            label: Text(carbsMacro),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Protein Macro",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Chip(
                            label: Text(proteinMacro),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Fats Macro",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Chip(
                            label: Text(fatsMacro),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Meal Healthiness",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Chip(
                            label: Text(mealHealthiness),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Confidence Level",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Chip(
                            label: Text(confidenceLevel),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Brief Summary",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(briefSummary),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Sentiment",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(sentiment),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Sentiment Label",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(sentimentLabel),

                          const SizedBox(height: AppSizes.spaceBtwItems),

                          Text(
                            "Uploaded At",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(formattedDateTime),

                          const SizedBox(height: AppSizes.spaceBtwSections),

                          ElevatedButton.icon(
                            onPressed: () {
                              controller.deleteMeal(context, mealId);
                            },
                            label: Text("Delete Meal"),
                            icon: Icon(Icons.delete),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF960018),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              side: const BorderSide(
                                width: 0,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                ),
              ],
            )
        )
      ),
    );
  }
}
