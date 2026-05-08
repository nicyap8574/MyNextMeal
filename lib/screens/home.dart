import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/screens/meal_history_page.dart';
import 'package:mynextmeal/screens/user_profile_page.dart';

import '../features/personalisation/user_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import 'image_analysis.dart';
import 'meal_recommendation.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text("Welcome,",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: AppColors.primary,
                  fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize! + 5),
                ),

            //observe and change state of widget
            Obx(() => Text(controller.user.value.username,style: Theme.of(context).textTheme.headlineMedium)),

            const SizedBox(height: AppSizes.spaceBtwSections),

            Row(
              children: [
                //Gemini button
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ElevatedButton(
                        onPressed: () => Get.to(() => const ImageAnalysis()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lunch_dining, size: 40),
                            SizedBox(height: AppSizes.spaceBtwItems),
                            Text("Add New Meal", style: TextStyle(fontSize: AppSizes.buttonTextSize)),
                          ],
                        )
                    ),
                  ),
                ),

                const SizedBox(width: AppSizes.spaceBtwSections),

                //View past meals button
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ElevatedButton(
                        onPressed: () => Get.to(() => const MealHistoryPage()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Icon(Icons.history, size: 40),
                            SizedBox(height: AppSizes.spaceBtwItems),
                            Text("View Past Meals", style: TextStyle(fontSize: AppSizes.buttonTextSize)),
                          ],
                        )
                  ),
                ),
              ),
            ],
          ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            //Meal recommender button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Get.to(() => const MealRecommendation()),
                  child: const Text("Meal Recommender")),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            //My profile button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Get.to(() => const UserProfilePage()),
                  child: const Text("My Profile")),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            //sign out button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => controller.signOut(), child: const Text("Sign Out")),
            ),
          ],
        ),
      ),
    );
  }
}