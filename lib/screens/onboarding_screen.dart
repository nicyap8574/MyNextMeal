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
import '../utils/validator/validator.dart';

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
                padding: const EdgeInsets.all(AppSizes.appBarHeight),
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
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: Form(
                    key: controller.physicalMetricsFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),

                        Text(
                            'Let us know more about you.',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'So we can serve you with better results.',
                          style: Theme.of(context).textTheme.bodyMedium,
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

                        TextFormField(
                          controller: controller.heightController,
                          keyboardType: TextInputType.number,
                          validator: (value) => AppValidator.validateHeight(value),
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

                        TextFormField(
                          controller: controller.weightController,
                          keyboardType: TextInputType.number,
                          validator: (value) => AppValidator.validateWeight(value),
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

                        TextFormField(
                          controller: controller.ageController,
                          keyboardType: TextInputType.number,
                          validator: (value) => AppValidator.validateAge(value),
                          decoration: InputDecoration(
                            hintText: 'e.g. 20',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      ))
                    ],
                  ),
                ),
              ),

              //page 4 -- dietary goals and focus
              Padding(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),

                    Text(
                        'What are your dietary preferences?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold
                        )
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Customise your meal recommendations according to your meal preferences',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //dietary goals

                    Text(
                      'Dietary Goals',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeLg
                      ),
                    ),

                    const SizedBox(height: 4),

                    Wrap(
                      spacing: 8.0,
                      children: controller.dietOptions.map((option){
                        return Obx((){
                          final isSelected = controller.selectedDietOptions.contains(option);
                          return ChoiceChip(
                              label: Text(option),
                              selected: isSelected,
                            onSelected: (_) => controller.toggleDietOptions(option),
                          );
                        });
                      }).toList(),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //dietary focus

                    Text(
                      'Dietary Focus',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeLg
                      ),
                    ),

                    const SizedBox(height: 4),

                    Wrap(
                      spacing: 8.0,
                      children: controller.dietaryFocus.map((option){
                        return Obx((){
                          final isSelected = controller.selectedDietaryFocus.contains(option);
                          return ChoiceChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (_) => controller.toggleDietaryFocus(option),
                          );
                        });
                      }).toList(),
                    ),
                  ],
                ),
              ),

              //page 5 -- dietary restrictions
              Padding(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),

                    Text(
                        'Any restrictions or allergies?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold
                        )
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'So that we can avoid these ingredients in your recommendations.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    Wrap(
                      spacing: 8.0,
                      children: controller.dietaryRestrictions.map((option){
                        return Obx((){
                          final isSelected = controller.selectedRestrictions.contains(option);
                          return ChoiceChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (_) => controller.toggleRestriction(option),
                          );
                        });
                      }).toList(),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //custom restrictions
                    Obx((){
                      final customRestrictions = controller.selectedRestrictions
                          .where((r) => !controller.dietaryRestrictions.contains(r))
                          .toList();

                      if(customRestrictions.isEmpty){
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Text(
                            'Custom Restrictions',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.fontSizeSm
                            ),
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: customRestrictions.map((r){
                              return InputChip(
                                label: Text(r),
                                onDeleted: () => controller.removeRestriction(r),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSizes.spaceBtwItems),
                        ],
                      );
                    }),

                    //type custom restrictions

                    Row(
                      children:[
                        Expanded(
                          child: TextField(
                            controller: controller.customRestrictionController,
                            decoration: const InputDecoration(
                              hintText: 'Type custom restriction',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onSubmitted: controller.addCustomRestriction,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                          onPressed: () => controller.addCustomRestriction(controller.customRestrictionController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          //dot navigation SmoothPageIndicator
          if(MediaQuery.of(context).viewInsets.bottom == 0)
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
          if(MediaQuery.of(context).viewInsets.bottom == 0)
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
