import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/common/spacing_styles.dart';

import '../features/auth/onboarding_controller.dart';
import '../features/user/user_controller.dart';
import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/popups/loaders.dart';
import '../utils/validator/validator.dart';

class PhysicalMetrics extends StatefulWidget {
  const PhysicalMetrics({super.key});

  @override
  State<PhysicalMetrics> createState() => _PhysicalMetricsState();
}

class _PhysicalMetricsState extends State<PhysicalMetrics> {
  late UserProfileController userProfileController;

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();


  @override
  void initState(){
    super.initState();
    userProfileController = Get.find<UserProfileController>();
    loadUserData();
  }

  @override
  void dispose(){
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async{
    final data = await userProfileController.getUserDetails();

    if(data!=null){
      final double height = data['height'] ?? 0.00;
      final double weight = data['weight'] ?? 0.00;
      final int age = data['age'] ?? 0;

      //populate text field
      setState((){
        heightController.text = height.toString();
        weightController.text = weight.toString();
        ageController.text = age.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(OnboardingController());
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Physical Metrics"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Form(
            key: controller.physicalMetricsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Height (in cm)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSizeSm,
                  ),
                ),
            
                const SizedBox(height: AppSizes.spaceBtwItems/2),
            
                TextFormField(
                  controller: heightController,
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
                  controller: weightController,
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
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) => AppValidator.validateAge(value),
                  decoration: InputDecoration(
                    hintText: 'e.g. 20',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
                  ),
                ),
            
                const SizedBox(height: AppSizes.spaceBtwSections),
            
                //save changes button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      //check if form is valid
                      if(!controller.physicalMetricsFormKey.currentState!.validate()){
                        return;
                      }

                      final profileController = Get.find<UserProfileController>();
                      await profileController.updatePhysicalMetrics(
                        context: context,
                        height: double.tryParse(heightController.text) ?? 170.00,
                        weight: double.tryParse(weightController.text) ?? 60.00,
                        age: int.tryParse(ageController.text) ?? 18,
                      );
                    },
                    child: const Text("Save Changes"),
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}
