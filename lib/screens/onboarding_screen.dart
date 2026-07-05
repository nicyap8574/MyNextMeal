import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/features/auth/onboarding_controller.dart';
import 'package:mynextmeal/utils/constants/colors.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import 'package:mynextmeal/utils/device/device_utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
      body: Stack(
        children: [
          //page
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.all(AppSizes.appBarHeight),
                child: Column(
                  children: [
                    Text('Welcome to MyNextMeal', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text('Insert caption here', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),

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
              onPressed: (){},
              style: ElevatedButton.styleFrom(shape: CircleBorder()),
              child: Icon(Icons.arrow_forward_ios),
            ),
          )
        ],
      )
    );
  }
}
