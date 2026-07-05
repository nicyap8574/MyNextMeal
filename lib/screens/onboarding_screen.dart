import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/features/auth/onboarding_controller.dart';
import 'package:mynextmeal/utils/constants/colors.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import 'package:mynextmeal/utils/device/device_utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/constants/image_strings.dart';
import '../utils/helpers/helper_functions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,

      body: Stack(
        children: [
          //page
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              //page 1 -- Welcome Page
              Padding(
                padding: const EdgeInsetsGeometry.all(AppSizes.appBarHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      height: 150,
                      image: AssetImage(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    Text(
                        'Welcome to MyNextMeal',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                    ),

                    const SizedBox(height: AppSizes.spaceBtwItems),

                    Text(
                        "Let's get started by personalising your profile.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? AppColors.textWhite.withOpacity(0.7) : AppColors.textSecondary,
                        )
                    ),
                  ],
                ),
              ),

              //page 2 -- Height, weight, age
              Padding(
                padding: const EdgeInsetsGeometry.all(AppSizes.appBarHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    Text(
                        'Your Physical Metrics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //height
                    Text(
                        'Height (in cm)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontSizeSm,
                        ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: controller.heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 175',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //weight
                    Text(
                      'Weight (in kg)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeSm,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: controller.weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 60',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //age
                    Text(
                      'Age',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeSm,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: controller.ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 20',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
                      ),
                    ),
                  ],
                ),
              ),

              //page 3 - Activity level
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                          'Activity Level',
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
                      ))
                    ],
                  ),
                ),
              ),

              //page 4
              Padding(
                padding: const EdgeInsetsGeometry.all(AppSizes.appBarHeight),
                child: Column(
                  children: [
                    Text('Welcome to MyNextMeal2', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text('Insert caption here2', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),

              //page 5
              Padding(
                padding: const EdgeInsetsGeometry.all(AppSizes.appBarHeight),
                child: Column(
                  children: [
                    Text('Welcome to MyNextMeal2', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text('Insert caption here2', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

          //dot navigation SmoothPageIndicator
          Positioned(
            bottom: AppDeviceUtils.getBottomNavigationBarHeight() + 25,
            left: AppSizes.defaultSpace,

            child: SmoothPageIndicator(
              controller: controller.pageController,
              onDotClicked: controller.dotNavigationClick,
              count: 5,
              effect: ExpandingDotsEffect(
                activeDotColor: dark ? Colors.white : AppColors.primary,
                dotHeight: 6,
              ),
            ),
          ),

          //circular button
          Positioned(
            right: AppSizes.defaultSpace,
            bottom: AppDeviceUtils.getBottomNavigationBarHeight(),
            child: ElevatedButton(
              onPressed: () => OnboardingController.instance.nextPage(context),
              style: ElevatedButton.styleFrom(shape: CircleBorder()),
              child: Icon(Icons.arrow_forward_ios),
            ),
          )
        ],
      )
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
