import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/meals/meal_recommendation_history_controller.dart';
import 'package:mynextmeal/screens/meal_recommendation.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class MealRecommendationHistory extends StatefulWidget {
  const MealRecommendationHistory({super.key});

  @override
  State<MealRecommendationHistory> createState() => _MealRecommendationHistoryState();
}

class _MealRecommendationHistoryState extends State<MealRecommendationHistory> {
  @override
  Widget build(BuildContext context) {

    final controller = Get.find<MealRecommendationHistoryController>();
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Past Recommendations"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                stream: controller.getRecommendations(),
                builder: (context, snapshot){
                  // if(snapshot.connectionState == ConnectionState.waiting){
                  //   return const Center(child: CircularProgressIndicator());
                  // }
                  if(!snapshot.hasData){
                    return const SizedBox();
                  }

                  if(snapshot.hasError){
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // IF NO RECOMMENDED MEALS YET
                  if(docs.isEmpty){
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
                            Icons.receipt_long,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          SizedBox(height: AppSizes.md),
                          Text(
                            'No recommendations yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppSizes.xs),
                          Text(
                            "Generate your first recommendation",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSizes.md),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => const MealRecommendation()),
                            style: ElevatedButton.styleFrom(
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            ),
                            icon: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 22,
                            ),
                            label: const Text(
                              'Get meal recommendations',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  //DISPLAY RECOMMENDED MEALS
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),

                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final generatedMeals = data['generatedMeals'] as Map<String,dynamic>?;

                      //format date for output
                      final timestamp = data['createdAt'];
                      final date = timestamp.toDate();
                      final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                      final recommendations = (generatedMeals?['recommendations'] as List<dynamic>?) ?? [];
                      // List<Widget> widgets = [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              formattedDateTime,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: dark ? Colors.white54 : AppColors.textSecondary,
                              ),
                            ),
                          ),

                          for(var meal in recommendations)
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
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                                    padding: const EdgeInsetsGeometry.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //meal desc
                                        Text(
                                          meal['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: dark ? Colors.white70 : AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),

                                        const SizedBox(height: AppSizes.spaceBtwItems),

                                        //meal ingredients

                                        const Text(
                                          'Ingredients',
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

                                        const SizedBox(height: AppSizes.spaceBtwItems),

                                        //Meal type

                                        const Text(
                                          'Meal Type',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),

                                        const SizedBox(height: AppSizes.spaceBtwItems/2),

                                        Chip(
                                          label: Text(
                                            generatedMeals?['meal_type'] ?? 'None',
                                            style: TextStyle(color: dark ? Colors.white70 : AppColors.textPrimary),
                                          ),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor: dark ? Colors.white.withOpacity(0.05) : AppColors.softGrey,
                                          side: BorderSide.none,
                                        ),

                                        const SizedBox(height: AppSizes.spaceBtwItems),

                                        //Meal cuisine

                                        const Text(
                                          'Meal Cuisine',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),

                                        const SizedBox(height: AppSizes.spaceBtwItems/2),

                                        Chip(
                                          label: Text(
                                            meal['cuisine'] ?? 'None',
                                            style: TextStyle(
                                              color: dark ? AppColors.white : AppColors.primary,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor: dark ? AppColors.apricotCream800.withOpacity(0.4) : AppColors.lightBackground.withOpacity(0.2),
                                          side: BorderSide.none,
                                        ),
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          )
        )
      )
    );
  }
}