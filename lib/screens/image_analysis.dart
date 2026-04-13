import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../common/styles/spacing_styles.dart';
import '../data/repositories/image_analysis/image_analysis_repository.dart';
import '../utils/constants/sizes.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.put(ImageAnalysisRepository());

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
                    onPressed: () => repo.pickImage(),
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
                final imageFile = repo.foodImage.value;
          
                if(repo.isLoading.value != true && imageFile != null){
                  return Column(
                    children: [
                      Image.file(
                        imageFile,
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
          
              Obx((){
                if(repo.isLoading.value == true){
                  return Text("Response is loading...");
                }else{


                  final data = jsonDecode(repo.response.value);
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
