import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../common/spacing_styles.dart';
import '../features/auth/onboarding_controller.dart';
import '../features/user/user_controller.dart';
import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/popups/loaders.dart';

class ActivityLevel extends StatefulWidget {
  const ActivityLevel({super.key});

  @override
  State<ActivityLevel> createState() => _ActivityLevelState();
}

class _ActivityLevelState extends State<ActivityLevel> {
  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(OnboardingController());
    final userController = Get.find<UserController>();

    //if user has already set activity level, update activity level in OnboardingController with new value
    //userController.use.value.activityLevel -> fetches from memory
    if(userController.user.value.activityLevel != null){
      controller.activityLevel.value = userController.user.value.activityLevel!;
    }


    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Activity Level"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'How active are you on a weekly basis?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold
                  )
              ),

              const SizedBox(height: 8),

              Text(
                'Select your general level of physical movement.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Obx(() => Column(
                children: controller.activityLevels.map((level){
                  final title = level['title'] ?? '';
                  final description = level['description'] ?? '';
                  final isSelected = controller.activityLevel.value == title;

                  return GestureDetector(
                    onTap: () => controller.activityLevel.value = title,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                      color: isSelected
                          ? (dark ? AppColors.apricotCream600.withOpacity(0.2) : AppColors.apricotCream100)
                          : (dark ? AppColors.darkContainer : Colors.white),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isSelected ? (dark ? AppColors.apricotCream600 : AppColors.primary) : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              _getActivityIcon(title),
                              color: isSelected ? (dark ? AppColors.apricotCream600 : AppColors.primary) : (dark ? Colors.white70 : Colors.black54),
                              size: 28,
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (dark ? AppColors.apricotCream600 : AppColors.primary)
                                          : (dark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: dark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

              //save changes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final profileController = Get.find<UserProfileController>();
                    await profileController.updateActivityLevel(
                      context: context,
                      activityLevel: controller.activityLevel.value,
                    );
                    // AppLoaders.showSnackBar(Get.context!, "Activity level updated successfully");
                  },
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String title) {
    switch (title) {
      case 'Sedentary':
        return Icons.chair;
      case 'Lightly Active':
        return Icons.directions_walk;
      case 'Moderately Active':
        return Icons.directions_run;
      case 'Very Active':
        return Icons.fitness_center;
      default:
        return Icons.emoji_people;
    }
  }

}
