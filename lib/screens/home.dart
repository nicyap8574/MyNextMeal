import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/utils/helpers/helper_functions.dart';

import '../data/repositories/image_analysis/image_analysis_repository.dart';
import '../features/personalisation/user_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import 'image_analysis.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(UserController());
    final imageAnalysis = Get.put(ImageAnalysis());

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              //observe and change state of widget
              Obx(() => Text("Welcome ${controller.user.value.username}",style: Theme.of(context).textTheme.headlineMedium)),

              //sign out button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => controller.signOut(), child: const Text("Sign Out")),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              //Gemini button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Get.to(() => const ImageAnalysis()),
                    child: const Text("Gemini")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
