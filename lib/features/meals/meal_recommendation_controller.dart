import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import '../../services/gemini_controller.dart';

class MealRecommendationController extends GetxController{
  static MealRecommendationController get instance => Get.find();
  final userProfile = Get.find<UserProfileController>(); //retrieve an already-created controller instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> todayMeals = [];
  final RxBool isLoading = false.obs;
  final gemini = GeminiController();
  late RxString response = "".obs;
  RxList<String> preferredCategories = <String>[].obs;
  RxList<String> avoidCategories = <String>[].obs;
  RxString selectedMealType = ''.obs;

  @override
  void onInit(){
    super.onInit();
    autoSelectMealType();
  }

  void autoSelectMealType(){
    final hour = DateTime.now().hour;
    if(hour >= 5 && hour < 9){
      selectedMealType.value = 'Breakfast';
    }else if(hour >= 9 && hour < 13){
      selectedMealType.value = 'Lunch';
    }else if(hour >= 17 && hour < 20){
      selectedMealType.value = 'Dinner';
    }else if(hour >= 20 && hour < 22){
      selectedMealType.value = 'Supper';
    }else{
      selectedMealType.value = 'Snack';
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> displayTodayMeals() async{
    //retrieves details of current user
    final user = _auth.currentUser;
    await userMealPreferences();

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

  Future<void> userMealPreferences() async{
    final data = await userProfile.getUserDetails();

    //clear off from previous user
    preferredCategories.clear();
    avoidCategories.clear();

    Map<String,dynamic> categoryStats = data?['categoryStats'] ?? {};

    categoryStats.forEach((category,data){
      if(category == "unknown"){
        return;
      }

      int positive = data["positive"] ?? 0;
      int negative = data["negative"] ?? 0;

      int score = positive-negative;

      if(score >= 2){
        preferredCategories.add(category);
      }else if(score <= -2){
        avoidCategories.add(category);
      }
    },
    );
  }

  Future<void> generateMealRecs() async{
    var result;

    try{
      isLoading.value = true;
      final user = _auth.currentUser;
      TextPart prompt;

      //check if meal history is empty
      if(todayMeals.isEmpty){
        final data = await userProfile.getUserDetails();

        //user selected dietary goals
        List<dynamic>? selectedDietOptions = data?['dietOptions'] ?? 'No diet options';
        List<dynamic>? selectedDietaryFocus = data?['dietaryFocus'] ?? 'No dietary focus';
        List<dynamic>? selectedDietaryRestrictions = data?['dietaryRestrictions'] ?? 'No dietary restrictions';

        prompt = TextPart("""
          No previous meals have been recorded.
          
          This meal is for $selectedMealType
          
          User dietary goals and preferences include:
          Diet Options: $selectedDietOptions
          Dietary Focus: $selectedDietaryFocus
          Dietary Restrictions: $selectedDietaryRestrictions
          Preferred categories: $preferredCategories
          Avoid categories: $avoidCategories
          
          Return 4 simple, healthy meal recommendations that:
          - match the diet and focus
          - exclude any ingredients containing dietary restrictions
          - prioritize preferred categories
          - exclude avoided categories
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

        int totalMacroCount = carbsCount + proteinCount + fatsCount;

        //Calculate nutrition ratio
        double carbsRatio = carbsCount / totalMacroCount;
        double proteinRatio = proteinCount / totalMacroCount;
        double fatsRatio = fatsCount / totalMacroCount;

        //round to 2dp
        double carbsRatioRounded = double.parse(carbsRatio.toStringAsFixed(2));
        double proteinRatioRounded = double.parse(proteinRatio.toStringAsFixed(2));
        double fatsRatioRounded = double.parse(fatsRatio.toStringAsFixed(2));

        final data = await UserProfileController.instance.getUserDetails();

        //user selected dietary goals
        List<dynamic>? selectedDietOptions = data?['dietOptions'];
        List<dynamic>? selectedDietaryFocus = data?['dietaryFocus'];
        List<dynamic>? selectedDietaryRestrictions = data?['dietaryRestrictions'];

        prompt = TextPart("""
          User nutrition summary for today:
          Carbs: $carbsRatioRounded
          Protein: $proteinRatioRounded
          Fats: $fatsRatioRounded
          
          This meal is for $selectedMealType
          
          User dietary goals and preferences include:
          Diet Options: $selectedDietOptions
          Dietary Focus: $selectedDietaryFocus
          Dietary Restrictions: $selectedDietaryRestrictions
          Preferred categories: $preferredCategories
          Avoid categories: $avoidCategories
          
          Return 4 simple, healthy meal recommendations that:
          - match the diet and focus
          - exclude any ingredients containing dietary restrictions
          - prioritize preferred categories
          - exclude avoided categories
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

    }catch(e){
      print(e);
    }finally{
      isLoading.value = false;

      try{
        final data = jsonDecode(response.value);
        await saveMealRecommendations(data);
      }catch(e){
        print("JSON decode failed: $e");
      }

    }
  }

  Future<void> saveMealRecommendations(Map<String,dynamic> json) async{
    final user = _auth.currentUser;
    // final recommendations = json['recommendations'] as List<dynamic>;

    try{
      await _db.collection('recommendations').add({
        'generatedMeals': json,
        'createdAt': FieldValue.serverTimestamp(),
        'user': user!.uid,
      });
    }catch(e){
      print("Error saving recommended meal: $e");
    }
  }
}