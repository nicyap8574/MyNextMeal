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
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.defaultSpace,
                      AppSizes.md,
                      AppSizes.defaultSpace,
                      AppSizes.md,
                    ),

                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final generatedMeals = data['generatedMeals'] as Map<String,dynamic>?;

                      //format date for output
                      final timestamp = data['createdAt'];
                      final date = timestamp.toDate();
                      final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                      final recommendations = (generatedMeals?['recommendations'] as List<dynamic>?) ?? [];


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