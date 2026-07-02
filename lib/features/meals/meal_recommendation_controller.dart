import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import '../../services/gemini_controller.dart';

enum MealType { breakfast, lunch, dinner }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
    }
  }

  static MealType defaultForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 16) return MealType.lunch;
    return MealType.dinner;
  }
}

class MealRecommendationController {
  static MealRecommendationController get instance => Get.find();
  final userProfile = Get.find<UserProfileController>(); //retrieve an already-created controller instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> todayMeals = [];
  final RxBool isLoading = false.obs;
  final Rx<MealType> selectedMealType =
      MealTypeX.defaultForTimeOfDay().obs;
  final gemini = GeminiController();
  late RxString response = "".obs;

  void selectMealType(MealType type) {
    selectedMealType.value = type;
  }


  Future<QuerySnapshot<Map<String, dynamic>>> displayTodayMeals() async{
    //retrieves details of current user
    final user = _auth.currentUser;

    //load today's date
    DateTime now = new DateTime.now();
    DateTime dateToday = new DateTime(now.year, now.month, now.day);
    DateTime dateTmr = dateToday.add(Duration(days: 1));

    final todayMeal = await FirebaseFirestore.instance
        .collection('meals')
        .where('user', isEqualTo: user!.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateToday))
        .where('createdAt', isLessThan: Timestamp.fromDate(dateTmr))
        .get();
    //data type: QuerySnapshot<Map<String,dynamic>>

    //add today's meals into a List
    for(var x in todayMeal.docs){
      todayMeals.add(x.data());
    }
    return todayMeal;
  }

  Future<void> generateMealRecs() async{
    var result;

    try{
      isLoading.value = true;
      final user = _auth.currentUser;
      TextPart prompt;

      //check if meal history is empty
      if(todayMeals.isEmpty){
        final data = await UserProfileController.instance.getUserDetails();

        //user selected dietary goals
        List<dynamic>? selectedDietOptions = data?['dietOptions'];
        List<dynamic>? selectedDietaryFocus = data?['dietaryFocus'];

        final mealType = selectedMealType.value.label;

        prompt = TextPart("""
          No previous meals have been recorded.
          
          User dietary goals and preferences include:
          Diet Options: $selectedDietOptions
          Dietary Focus: $selectedDietaryFocus
          
          Generate the following
          - 3 $mealType recommendations to maintain a healthy diet, while following diet options and dietary focus
          - Each recommendation should be appropriate for $mealType
          - Keep it simple
          """);

        //generate text output
        result = await gemini.recommendationModel_NoPreviousMeals.generateContent([
          Content.text(prompt.text),
        ]);

      }else{
        int carbsCount = 0;
        int proteinCount = 0;
        int fatsCount = 0;

        for(var x=0; x<todayMeals.length; x++){
          switch(todayMeals[x]['analysis']['nutrients'][0]['carbs_macro']){
            case 'High':
              carbsCount+=3;
              break;
            case 'Medium':
              carbsCount+=2;
              break;
            case 'Low':
              carbsCount+=1;
              break;
            default:
              carbsCount+=0;
          }

          switch(todayMeals[x]['analysis']['nutrients'][0]['protein_macro']){
            case 'High':
              proteinCount+=3;
              break;
            case 'Medium':
              proteinCount+=2;
              break;
            case 'Low':
              proteinCount+=1;
              break;
            default:
              proteinCount+=0;
          }

          switch(todayMeals[x]['analysis']['nutrients'][0]['fats_macro']){
            case 'High':
              fatsCount+=3;
              break;
            case 'Medium':
              fatsCount+=2;
              break;
            case 'Low':
              fatsCount+=1;
              break;
            default:
              fatsCount+=0;
          }
        }
        // print("Carbs Index: $carbsCount");
        // print("Protein Index: $proteinCount");
        // print("Fats Index: $fatsCount");

        //Calculate nutrition ratio
        double carbsRatio = carbsCount / (todayMeals.length * 3);
        double proteinRatio = proteinCount / (todayMeals.length * 3);
        double fatsRatio = fatsCount / (todayMeals.length * 3);

        //round to 2dp
        double carbsRatioRounded = double.parse(carbsRatio.toStringAsFixed(2));
        double proteinRatioRounded = double.parse(proteinRatio.toStringAsFixed(2));
        double fatsRatioRounded = double.parse(fatsRatio.toStringAsFixed(2));

        final data = await UserProfileController.instance.getUserDetails();

        //user selected dietary goals
        List<dynamic>? selectedDietOptions = data?['dietOptions'];
        List<dynamic>? selectedDietaryFocus = data?['dietaryFocus'];

        final mealType = selectedMealType.value.label;

        prompt = TextPart("""
          User nutrition summary for today:
          Carbs: $carbsRatioRounded
          Protein: $proteinRatioRounded
          Fats: $fatsRatioRounded
          
          User dietary goals and preferences include:
          Diet Options: $selectedDietOptions
          Dietary Focus: $selectedDietaryFocus
          
          Generate the following
          - Explain what is imbalanced
          - 3 $mealType recommendations to maintain a healthy diet, while following diet options and dietary focus
          - Each recommendation should be appropriate for $mealType
          - Keep it simple
          """);

        //generate text output
        result = await gemini.recommendationModel_PreviousMeals.generateContent([
          Content.text(prompt.text),
        ]);
      }

      if(result.text!.contains("error") || result.text!.contains("Overloaded")){
        response.value = "AI is currently busy. Please try again later.";
        return;
      }

      response.value = result.text!;

      // print("===== MEAL RECOMMENDATIONS =====");
      // print(todayMeals);
    }catch(e){
      print(e);
    }finally{
      isLoading.value = false;
    }
  }
}