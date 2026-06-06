import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/common/widgets/confidence_indicator.dart';
import 'package:mynextmeal/common/widgets/macro_breakdown_bar.dart';
import '../features/meals/image_analysis_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/helpers/meal_analysis_helpers.dart';
import 'image_analysis.dart';

class FoodAnalysisResults extends StatefulWidget {
  const FoodAnalysisResults({super.key});

  @override
  State<FoodAnalysisResults> createState() => _FoodAnalysisResultsState();
}

class _FoodAnalysisResultsState extends State<FoodAnalysisResults> {
  final ImageAnalysisController _controller = Get.find<ImageAnalysisController>();

  final _dishNameController = TextEditingController();
  final List<_IngredientField> _ingredientFields = [];
  String _carbsMacro = 'Unknown';
  String _proteinMacro = 'Unknown';
  String _fatsMacro = 'Unknown';
  String _confidenceLevel = 'Medium';
  String _mealHealthiness = 'Unknown';
  String _briefSummary = '';
  bool _initialized = false;

  @override
  void dispose() {
    _dishNameController.dispose();
    for (final field in _ingredientFields) {
      field.dispose();
    }
    super.dispose();
  }

  void _loadFromResponse(String response) {
    final meal = MealAnalysisHelpers.parseMealFromResponse(response);
    if (meal == null) return;

    _dishNameController.text = meal['meal_name']?.toString() ?? '';
    _carbsMacro = meal['carbs_macro']?.toString() ?? 'Unknown';
    _proteinMacro = meal['protein_macro']?.toString() ?? 'Unknown';
    _fatsMacro = meal['fats_macro']?.toString() ?? 'Unknown';
    _confidenceLevel = meal['confidence_level']?.toString() ?? 'Medium';
    _mealHealthiness = meal['meal_healthiness']?.toString() ?? 'Unknown';
    _briefSummary = meal['brief_summary']?.toString() ?? '';

    _ingredientFields.clear();
    final ingredients = MealAnalysisHelpers.parseIngredients(
      meal['detected_ingredients'] as List<dynamic>?,
    );
    for (final ingredient in ingredients) {
      _ingredientFields.add(
        _IngredientField(
          nameController: TextEditingController(text: ingredient.name),
          quantityController: TextEditingController(text: ingredient.quantity),
        ),
      );
    }
    if (_ingredientFields.isEmpty) {
      _addIngredientField();
    }
    _initialized = true;
  }

  void _addIngredientField() {
    setState(() {
      _ingredientFields.add(
        _IngredientField(
          nameController: TextEditingController(),
          quantityController: TextEditingController(),
        ),
      );
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientFields.length <= 1) return;
    setState(() {
      _ingredientFields[index].dispose();
      _ingredientFields.removeAt(index);
    });
  }

  Map<String, dynamic> _buildPayload() {
    final ingredients = _ingredientFields
        .where((field) => field.nameController.text.trim().isNotEmpty)
        .map(
          (field) => IngredientEntry(
            name: field.nameController.text.trim(),
            quantity: field.quantityController.text.trim(),
          ),
        )
        .toList();

    return MealAnalysisHelpers.buildAnalysisPayload(
      mealName: _dishNameController.text.trim(),
      ingredients: ingredients,
      carbsMacro: _carbsMacro,
      proteinMacro: _proteinMacro,
      fatsMacro: _fatsMacro,
      mealHealthiness: _mealHealthiness,
      confidenceLevel: _confidenceLevel,
      briefSummary: _briefSummary,
    );
  }

  Future<void> _confirmAndSave() async {
    if (_dishNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a dish name before saving.')),
      );
      return;
    }

    final payload = _buildPayload();
    await _controller.saveMealRecord(
      payload,
      _controller.imageUrl.value,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final surface = dark ? AppColors.darkContainer : AppColors.white;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Review & confirm'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Analyzing your meal…',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        if (_controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: AppSpacingStyle.paddingWithAppBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    _controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_controller.response.value.isEmpty) {
          return const Center(child: Text('No analysis data available.'));
        }

        if (!_initialized) {
          _loadFromResponse(_controller.response.value);
        }

        return SingleChildScrollView(
          child: Padding(
            padding: AppSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.foodImage.value != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSizes.cardRadiusMd),
                    child: Image.file(
                      File(_controller.foodImage.value!.path),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                ConfidenceIndicator(
                  level: _confidenceLevel,
                  dark: dark,
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Text(
                  'Detected dish',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _dishNameController,
                  decoration: const InputDecoration(
                    hintText: 'Edit dish name if needed',
                    prefixIcon: Icon(Icons.restaurant_rounded),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Text(
                  'Macro breakdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Adjust levels if the AI estimate looks wrong.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                      ),
                ),
                const SizedBox(height: AppSizes.md),
                MacroBreakdownBar(
                  label: 'Carbs',
                  level: _carbsMacro,
                  icon: Icons.grain_rounded,
                  dark: dark,
                  onLevelChanged: (value) => setState(() => _carbsMacro = value),
                ),
                const SizedBox(height: AppSizes.sm),
                MacroBreakdownBar(
                  label: 'Protein',
                  level: _proteinMacro,
                  icon: Icons.fitness_center_rounded,
                  dark: dark,
                  onLevelChanged: (value) =>
                      setState(() => _proteinMacro = value),
                ),
                const SizedBox(height: AppSizes.sm),
                MacroBreakdownBar(
                  label: 'Fat',
                  level: _fatsMacro,
                  icon: Icons.water_drop_rounded,
                  dark: dark,
                  onLevelChanged: (value) => setState(() => _fatsMacro = value),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ingredients & portions',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addIngredientField,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Correct ingredient names and quantities to keep your log accurate.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                      ),
                ),
                const SizedBox(height: AppSizes.md),
                ..._ingredientFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadiusMd),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: field.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Ingredient',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: field.quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                hintText: 'e.g. 150g',
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeIngredientField(index),
                            icon: Icon(
                              Icons.close_rounded,
                              color: dark
                                  ? AppColors.darkGrey
                                  : AppColors.darkerGrey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (_briefSummary.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    _briefSummary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                        ),
                  ),
                ],

                const SizedBox(height: AppSizes.spaceBtwSections),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmAndSave,
                    child: const Text('Confirm & save meal'),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.off(() => const ImageAnalysis());
                    },
                    child: const Text('Discard & retake'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _IngredientField {
  _IngredientField({
    required this.nameController,
    required this.quantityController,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}
