import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/features/controllers/image_analysis_controller.dart';

import '../common/styles/spacing_styles.dart';
import '../features/personalisation/user_controller.dart';
import '../utils/constants/sizes.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageAnalysisController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Analysis'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: ElevatedButton(
                    onPressed: () => controller.pickImage(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                    ),
                    child: const Text("Upload Image")
                ),
              ),
          
              const SizedBox(height: AppSizes.spaceBtwSections),
          
              Obx((){
                final imageFile = controller.foodImage.value;
          
                if(controller.isLoading.value != true && imageFile != null){
                  return Column(
                    children: [
                      Image.file(
                        File(imageFile.path), //converts XFile to File -> directory to image in device
                        height: 300,
                        fit: BoxFit.cover
                      ),
                    ],
                  );
                }else{
                  return const SizedBox.shrink();
                }
              }),
          
              const SizedBox(height: AppSizes.spaceBtwSections),

              //Obx so that it updates when response changes and can get the data from repository
              Obx((){
                if(controller.isLoading.value == true){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Text("Response is loading..."),
                      ],
                    ),
                  );
                }else{
                  if (controller.response.value.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final data = jsonDecode(controller.response.value);
                  final nutrients = data['nutrients'] as List<dynamic>;
                  final meal = nutrients[0] as Map<String, dynamic>;
                  final mealName = meal['meal_name'];
                  final ingredients = meal['detected_ingredients'] as List<dynamic>;
                  final carbsMacro = meal['carbs_macro'];
                  final proteinMacro = meal['protein_macro'];
                  final fatsMacro = meal['fats_macro'];
                  final mealHealthiness = meal['meal_healthiness'];
                  final confidenceLevel = meal['confidence_level'];
                  final briefSummary = meal['brief_summary'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dish Name"),
                      Chip(
                        label: Text(mealName),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Ingredients"),
                      Wrap(
                        spacing: 8,
                        children: ingredients.map((individual_ingredient){
                          return Chip(
                            label: Text(individual_ingredient),
                          );
                        }).toList(), //converts Iterable to List<Widget> to be accepted by children
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Carbs Macro"),
                      Chip(
                        label: Text(carbsMacro),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Protein Macro"),
                      Chip(
                        label: Text(proteinMacro),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Fats Macro"),
                      Chip(
                        label: Text(fatsMacro),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Meal Healthiness"),
                      Chip(
                        label: Text(mealHealthiness),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Confidence Level"),
                      Chip(
                        label: Text(confidenceLevel),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Text("Brief Summary"),
                      Text(briefSummary),
                    ]
                  );

                  //return Text(repo.response.value);
                }
              }),
            ]
          ),
        )
      )
    );
  }
}
