import 'dart:convert';

import 'package:flutter/material.dart';
import '../constants/colors.dart';

class IngredientEntry {
  IngredientEntry({required this.name, required this.quantity});

  String name;
  String quantity;

  Map<String, String> toJson() => {'name': name, 'quantity': quantity};

  static IngredientEntry fromDynamic(dynamic item) {
    if (item is Map) {
      return IngredientEntry(
        name: item['name']?.toString() ?? '',
        quantity: item['quantity']?.toString() ?? '',
      );
    }
    return IngredientEntry(name: item.toString(), quantity: '');
  }

  String displayLabel() {
    if (quantity.trim().isEmpty) return name;
    return '$name ($quantity)';
  }
}

class MealAnalysisHelpers {
  MealAnalysisHelpers._();

  static const macroLevels = ['Low', 'Medium', 'High', 'Unknown'];

  static List<IngredientEntry> parseIngredients(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw.map(IngredientEntry.fromDynamic).toList();
  }

  static double macroToProgress(String? level) {
    switch (level) {
      case 'High':
        return 1.0;
      case 'Medium':
        return 0.55;
      case 'Low':
        return 0.25;
      default:
        return 0.1;
    }
  }

  static String macroPlainLabel(String? level) {
    switch (level) {
      case 'High':
        return 'High';
      case 'Medium':
        return 'Moderate';
      case 'Low':
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  static Color macroColor(String? level, {required bool dark}) {
    switch (level) {
      case 'High':
        return dark ? AppColors.apricotCream400 : AppColors.apricotCream600;
      case 'Medium':
        return dark ? AppColors.celadon400 : AppColors.celadon500;
      case 'Low':
        return dark ? AppColors.celadon300 : AppColors.celadon600;
      default:
        return dark ? AppColors.darkGrey : AppColors.darkerGrey;
    }
  }

  static Color confidenceColor(String? level, {required bool dark}) {
    switch (level) {
      case 'High':
        return dark ? AppColors.celadon400 : AppColors.celadon600;
      case 'Medium':
        return dark ? AppColors.apricotCream400 : AppColors.apricotCream600;
      case 'Low':
        return dark ? AppColors.error : AppColors.error;
      default:
        return dark ? AppColors.darkGrey : AppColors.darkerGrey;
    }
  }

  static String confidenceMessage(String? level) {
    switch (level) {
      case 'High':
        return 'The AI is fairly confident about this analysis.';
      case 'Medium':
        return 'Some details may be off — please review and correct before saving.';
      case 'Low':
        return 'Low confidence — double-check the dish name and portions.';
      default:
        return 'Confidence unknown — review before confirming.';
    }
  }

  static double confidenceToProgress(String? level) {
    switch (level) {
      case 'High':
        return 0.85;
      case 'Medium':
        return 0.55;
      case 'Low':
        return 0.25;
      default:
        return 0.1;
    }
  }

  static Map<String, dynamic>? parseMealFromResponse(String response) {
    if (response.isEmpty) return null;
    try {
      final data = jsonDecode(response) as Map<String, dynamic>;
      final nutrients = data['nutrients'];
      if (nutrients is! List || nutrients.isEmpty) return null;
      final meal = nutrients[0];
      if (meal is! Map) return null;
      return Map<String, dynamic>.from(meal);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> buildAnalysisPayload({
    required String mealName,
    required List<IngredientEntry> ingredients,
    required String carbsMacro,
    required String proteinMacro,
    required String fatsMacro,
    required String mealHealthiness,
    required String confidenceLevel,
    required String briefSummary,
  }) {
    return {
      'nutrients': [
        {
          'meal_name': mealName,
          'detected_ingredients': ingredients.map((e) => e.toJson()).toList(),
          'carbs_macro': carbsMacro,
          'protein_macro': proteinMacro,
          'fats_macro': fatsMacro,
          'meal_healthiness': mealHealthiness,
          'confidence_level': confidenceLevel,
          'brief_summary': briefSummary,
        },
      ],
    };
  }

}
