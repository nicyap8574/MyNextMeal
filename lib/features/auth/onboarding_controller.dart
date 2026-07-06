import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import 'package:path/path.dart';

import '../../common/app_navigation_bar.dart';
import '../../screens/home.dart';

class OnboardingController extends GetxController{
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  final physicalMetricsFormKey = GlobalKey<FormState>();

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  var activityLevel = 'Sedentary'.obs;

  var selectedDietOptions = <String>{}.obs;
  var selectedDietaryFocus = <String>{}.obs;

  var selectedRestrictions = <String>[].obs;
  final customRestrictionController = TextEditingController();

  final List<String> dietOptions = [
    'Halal',
    'Vegetarian',
    'Vegan',
    'Keto'
  ];

  final List<String> dietaryFocus = [
    'Type-2 Diabetes',
    'High Cholesterol',
    'Weight Loss',
    'Muscle Gain',
    'General Health'
  ];

  final List<String> dietaryRestrictions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Soy',
    'Seafood',
    'Eggs',
  ];

  final List<Map<String, String>> activityLevels = [
    {
      'title': 'Sedentary',
      'description': 'Little or no daily exercise. Glued to the chair.',
    },
    {
      'title': 'Lightly Active',
      'description': 'Light exercise or active lifestyle 1-3 days a week.',
    },
    {
      'title': 'Moderately Active',
      'description': 'Moderate exercise or sports 3-5 days a week.',
    },
    {
      'title': 'Very Active',
      'description': 'Hard exercise or physical work 6-7 days a week.',
    },
  ];

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index){
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage(BuildContext context) async{
    if (currentPageIndex.value == 1) {
      if (!physicalMetricsFormKey.currentState!.validate()) {
        return;
      }
    }

    if(currentPageIndex.value == 4){
      await saveOnboardingDetails(context);
    }else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page); //TODO: change to animateToPage?
    }
  }

  void previousPage(){
    if(currentPageIndex.value > 0){
      int page = currentPageIndex.value -1;
      pageController.jumpToPage(page); //TODO: change to animateToPage?
    }
  }

  void toggleDietOptions(String option){
    if(selectedDietOptions.contains(option)){
      selectedDietOptions.remove(option);
    }else{
      selectedDietOptions.add(option);
    }
  }

  void toggleDietaryFocus(String focus){
    if(selectedDietaryFocus.contains(focus)){
      selectedDietaryFocus.remove(focus);
    }else{
      selectedDietaryFocus.add(focus);
    }
  }

  void toggleRestriction(String restriction){
    if(selectedRestrictions.contains(restriction)){
      selectedRestrictions.remove(restriction);
    }else{
      selectedRestrictions.add(restriction);
    }
  }

  void addCustomRestriction(String rawRestriction){
    final trimmedRestriction = rawRestriction.trim();
    if(trimmedRestriction.isNotEmpty){
      if(!selectedRestrictions.contains(trimmedRestriction)){
        selectedRestrictions.add(trimmedRestriction);
      }
      customRestrictionController.clear();
    }
  }

  void removeRestriction(String restriction){
    selectedRestrictions.remove(restriction);
  }


  Future<void> saveOnboardingDetails(BuildContext context) async {
    final height = double.tryParse(heightController.text) ?? 170.00;
    final weight = double.tryParse(weightController.text) ?? 60.00;
    final age = int.tryParse(ageController.text) ?? 18;

    final profileController = Get.find<UserProfileController>();

    await profileController.saveOnboardingDetails(
        context: context,
        height: height,
        weight: weight,
        age: age,
        activityLevel: activityLevel.value,
        selectedDietOptions: selectedDietOptions.toList(),
        selectedDietaryFocus: selectedDietaryFocus.toList(),
        selectedRestrictions: selectedRestrictions.toList(),
    );

    Get.offAll(() => const AppNavigationBar());
  }

  @override
  void onClose(){
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    customRestrictionController.dispose();
    super.onClose();
  }
}