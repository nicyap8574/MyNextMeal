import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/meals/individual_meal_controller.dart';
import '../common/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class IndividualMeal extends StatefulWidget {
  final String mealId;
  final String? imageUrl;
  const IndividualMeal(this.mealId, this.imageUrl, {super.key});

  @override
  State<IndividualMeal> createState() => _IndividualMealState();
}

class _IndividualMealState extends State<IndividualMeal> {

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
            child: FutureBuilder(
              future: controller.getIndividualMeal(widget.mealId),
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

                final nutrients = meal.data!['analysis']['nutrients'][0];
                final mealName = nutrients['meal_name']?.toString() ?? 'Unknown';
                final ingredients = (nutrients['detected_ingredients'] as List<dynamic>?) ?? [];
                final carbsMacro = nutrients['carbs_macro']?.toString() ?? 'Unknown';
                final proteinMacro = nutrients['protein_macro']?.toString() ?? 'Unknown';
                final fatsMacro = nutrients['fats_macro']?.toString() ?? 'Unknown';
                final mealHealthiness = nutrients['meal_healthiness']?.toString() ?? 'Unknown';
                final confidenceLevel = nutrients['confidence_level']?.toString() ?? 'Unknown';
                final briefSummary = nutrients['brief_summary']?.toString() ?? 'Unknown';
                final createdAt = meal.data!['createdAt']?.toDate() ?? DateTime.now();
                final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
                final rawSentiment = meal.data!['sentiment']?.toString() ?? '';
                final sentiment = rawSentiment.trim().isEmpty ? 'No sentiment provided' : rawSentiment;
                final sentimentLabel = meal.data!['sentimentLabel']?.toString() ?? 'Unknown';
                final mealCategory = nutrients['category']?.toString() ?? 'Unknown';
                final manualTextInput = nutrients['manual_text_input']?.toString() ?? "No description provided";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                        child: Image.network(
                            widget.imageUrl!,
                            height: 300,
                            fit: BoxFit.cover
                        ),
                      )
                    else
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: dark ?  const Color(0xFF221E19) : AppColors.white,
                            border: Border.all(
                                color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                                width: 1
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Manual Text Input",
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(manualTextInput),
                            ],
                          )
                      ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark ?  const Color(0xFF221E19) : AppColors.white,
                        border: Border.all(
                            color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
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
                                label: Text(individual_ingredient?.toString() ?? 'Unknown'),
                              );
                            }).toList(), //converts Iterable to List<Chip> to be accepted by children
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
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    ElevatedButton.icon(
                      onPressed: () {
                        controller.deleteMeal(context, widget.mealId);
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
          )
      )
    );
  }
}