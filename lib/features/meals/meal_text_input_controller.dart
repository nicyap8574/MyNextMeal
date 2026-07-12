import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
import 'package:mynextmeal/features/meals/sentiment_analysis.dart';
import 'package:mynextmeal/screens/food_analysis_results.dart';

import '../../services/gemini_controller.dart';

class MealTextInputController extends GetxController{
  final gemini = GeminiController();
  final sentimentAnalysis = SentimentAnalysis();

  final mealDetailsController = TextEditingController();
  GlobalKey<FormState> FormKey = GlobalKey<FormState>();

  Future<void> manualInputMeal(BuildContext context) async{
    final mealDetails = mealDetailsController.text.trim();
    final imageAnalysisController = Get.find<ImageAnalysisController>();

    Get.to(() => const FoodAnalysisResults());

    await imageAnalysisController.analyseFoodText(mealDetails: mealDetails);
  }
}