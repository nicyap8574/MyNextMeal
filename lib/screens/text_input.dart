import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/features/meals/meal_text_input_controller.dart';

import '../common/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/validator/validator.dart';

class TextInput extends StatelessWidget {
  const TextInput({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(MealTextInputController());

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Text Input'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Form(
            key: controller.FormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Describe your meal",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
  
                const SizedBox(height: 6),
  
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: controller.mealDetailsController,
                  validator: (value) => AppValidator.validateEmptyText("Meal description", value),
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
  
                const SizedBox(height: AppSizes.spaceBtwInputFields),
  
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.manualInputMeal(context),
                    child: const Text("Analyse Meal"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
