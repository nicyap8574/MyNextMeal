import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import '../features/meals/image_analysis_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class FoodAnalysisResults extends StatefulWidget {
  const FoodAnalysisResults({super.key});

  @override
  State<FoodAnalysisResults> createState() => _FoodAnalysisResultsState();
}

class _FoodAnalysisResultsState extends State<FoodAnalysisResults> {

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final controller = Get.find<ImageAnalysisController>();

  void addCustomCategory(String rawCategory){
    final trimmedCategory = rawCategory.trim();
    if(trimmedCategory.isNotEmpty){
      setState(() {
        final alreadyExists = controller.categoryOptions.any((element) => element.toLowerCase() == trimmedCategory.toLowerCase());
        if(!alreadyExists){
          controller.categoryOptions.add(trimmedCategory);
        }

        controller.category.value = trimmedCategory;
        categoryController.clear();
      });
    }
  }

  void addCustomIngredient(String rawIngredient){
    final trimmedIngredient = rawIngredient.trim();
    if(trimmedIngredient.isNotEmpty){
      if(!controller.ingredients.contains(trimmedIngredient)){
        controller.ingredients.add(trimmedIngredient);
      }
      ingredientsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Meal Analysis Results'),
        ),

        body: Obx((){
          if(controller.isLoading.value == true){
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Analysing meal...',
                  ),
                ],
              )
            );
          }

          return SingleChildScrollView(
              child: Padding(
                  padding: AppSpacingStyle.paddingWithAppBarHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      Obx((){
                        final imageFile = controller.foodImage.value;

                        if(controller.isLoading.value != true && imageFile != null){
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                                child: Image.file(
                                    File(imageFile.path), //converts XFile to File -> directory to image in device
                                    height: 300,
                                    fit: BoxFit.cover
                                ),
                              ),
                            ],
                          );
                        }else{
                          return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: dark ?  const Color(0xFF221E19) : AppColors.white,
                                border: Border.all(
                                    color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                                    width: 1
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Manual Text Input",
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(controller.userTextInput),
                                ],
                              )
                          );
                        }
                      }),

                      const SizedBox(height: AppSizes.spaceBtwSections),

                      //Obx so that it updates when response changes and can get the data from repository
                      Obx((){

                        if(controller.errorMessage.value != null){
                          return Text(
                            controller.errorMessage.value!,
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        if (controller.response.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final data = jsonDecode(controller.response.value);
                        final nutrients = data['nutrients'] as List<dynamic>;
                        final meal = nutrients[0] as Map<String, dynamic>;
                        final carbsMacro = meal['carbs_macro'];
                        final proteinMacro = meal['protein_macro'];
                        final fatsMacro = meal['fats_macro'];
                        final mealHealthiness = meal['meal_healthiness'];
                        final confidenceLevel = meal['confidence_level'];

                        if(controller.carbsMacro.value.isEmpty||controller.proteinMacro.value.isEmpty||controller.fatMacro.value.isEmpty){
                          controller.carbsMacro.value = carbsMacro;
                          controller.proteinMacro.value = proteinMacro;
                          controller.fatMacro.value = fatsMacro;
                        }

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Detected Dish",
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: AppSizes.sm),

                              TextField(
                                controller: controller.mealNameController,
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Category"
                              ),

                              Wrap(
                                  spacing: 8.0,
                                  children: List.generate(controller.categoryOptions.length, (index){
                                    return ChoiceChip(
                                        label: Text(
                                          controller.categoryOptions[index],
                                        ),
                                        selected: controller.category.value == controller.categoryOptions[index],
                                        showCheckmark: false,
                                        onSelected: (bool selected){
                                          if(selected){
                                            controller.category.value = controller.categoryOptions[index];
                                          }
                                        }
                                    );
                                  }
                                  )
                              ),

                              const SizedBox(height: AppSizes.sm),

                              //custom category
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: categoryController,
                                      decoration: const InputDecoration(
                                        hintText: 'Add custom category',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: addCustomCategory,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  IconButton(
                                      onPressed: () => addCustomCategory(categoryController.text),
                                      icon: const Icon(Icons.add)
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Ingredients"
                              ),

                              Wrap(
                                spacing: 8,
                                children: controller.ingredients.map((individual_ingredient){
                                  return InputChip(
                                    label: Text(individual_ingredient),
                                    onDeleted: (){
                                      controller.ingredients.remove(individual_ingredient);
                                    }
                                  );
                                }).toList(), //converts Iterable to List<Widget> to be accepted by children
                              ),

                              const SizedBox(height: AppSizes.sm),

                              //custom ingredient
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: ingredientsController,
                                      decoration: const InputDecoration(
                                        hintText: 'Add custom ingredient',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: addCustomIngredient,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  IconButton(
                                      onPressed: () => addCustomIngredient(ingredientsController.text),
                                      icon: const Icon(Icons.add)
                                  ),
                                ],
                              ),


                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Carbs Macro"
                              ),

                              Wrap(
                                  spacing: 8.0,
                                  children: List.generate(controller.macroOptions.length, (index){
                                    return ChoiceChip(
                                        label: Text(
                                          controller.macroOptions[index],
                                        ),
                                        selected: controller.carbsMacro.value == controller.macroOptions[index],
                                        showCheckmark: false,
                                        onSelected: (bool selected){
                                          if(selected){
                                            controller.carbsMacro.value = controller.macroOptions[index];
                                          }
                                        }
                                    );
                                  }
                                  )
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Protein Macro"
                              ),

                              Wrap(
                                  spacing: 8.0,
                                  children: List.generate(controller.macroOptions.length, (index){
                                    return ChoiceChip(
                                        label: Text(
                                          controller.macroOptions[index],
                                        ),
                                        selected: controller.proteinMacro.value == controller.macroOptions[index],
                                        showCheckmark: false,
                                        onSelected: (bool selected){
                                          if(selected){
                                            controller.proteinMacro.value = controller.macroOptions[index];
                                          }
                                        }
                                    );
                                  }
                                  )
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Fats Macro"
                              ),

                              Wrap(
                                  spacing: 8.0,
                                  children: List.generate(controller.macroOptions.length, (index){
                                    return ChoiceChip(
                                        label: Text(
                                          controller.macroOptions[index],
                                        ),
                                        selected: controller.fatMacro.value == controller.macroOptions[index],
                                        showCheckmark: false,
                                        onSelected: (bool selected){
                                          if(selected){
                                            controller.fatMacro.value = controller.macroOptions[index];
                                          }
                                        }
                                    );
                                  }
                                  )
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Meal Healthiness"
                              ),

                              Chip(
                                label: Text(mealHealthiness),
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "Confidence Level"
                              ),

                              Chip(
                                label: Text(confidenceLevel),
                              ),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      "Brief Summary"
                                  ),

                                  Obx((){
                                    if(controller.isSummaryLoading.value){
                                      return const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    }

                                    return IconButton(
                                      icon: const Icon(Icons.refresh, size: 20),
                                      onPressed: () => controller.regenerateMealSummary(),
                                    );
                                  }),
                                ],
                              ),

                              Obx(() => Text(controller.briefSummary.value)),

                              const SizedBox(height: AppSizes.spaceBtwItems),

                              Text(
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  "How did you feel after this meal?"),

                              const SizedBox(height: AppSizes.sm),

                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'E.g., I feel so sluggish after this meal.',
                                  border: OutlineInputBorder(),
                                ),
                                controller: controller.sentimentController,
                              ),

                              const SizedBox(height: AppSizes.spaceBtwSections),

                              Center(
                                child: Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:[
                                    //save meal
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: controller.isSaving.value
                                            ? null
                                            : () async {
                                                final data = jsonDecode(controller.response.value);

                                                final imageUrl = controller.imageUrl.value;
                                                print(imageUrl);

                                                final mealDetails = controller.userTextInput;

                                                await controller.saveMealRecord(data, imageUrl, mealDetails, context);
                                              },
                                        child: controller.isSaving.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text("Save Meal"),
                                      ),
                                    ),

                                    const SizedBox(height: AppSizes.spaceBtwItems),

                                    //cancel meal save
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                                          foregroundColor: dark ? AppColors.white : AppColors.black,
                                          side: dark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
                                        ),
                                        onPressed: controller.isSaving.value ? null : () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ),
                            ]
                        );
                      }
                      ),
                    ],
                  )
              )
          );
        })
    );
  }
}