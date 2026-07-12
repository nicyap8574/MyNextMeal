import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/screens/meal_recommendation_results.dart';
import '../common/spacing_styles.dart';
import '../features/meals/meal_recommendation_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class MealRecommendation extends StatefulWidget {
  const MealRecommendation({super.key});

  @override
  State<MealRecommendation> createState() => _MealRecommendationState();
}

class _MealRecommendationState extends State<MealRecommendation> {
  final List<String> mealType = ['Breakfast','Lunch','Dinner','Supper','Snack'];
  final List<DropdownMenuEntry<String>> cuisine = [
    DropdownMenuEntry(value: 'Random', label: 'Random'),
    DropdownMenuEntry(value: 'Malay', label: 'Malay'),
    DropdownMenuEntry(value: 'Chinese', label: 'Chinese'),
    DropdownMenuEntry(value: 'Mamak', label: 'Mamak'),
    DropdownMenuEntry(value: 'Indian', label: 'Indian'),
    DropdownMenuEntry(value: 'Western', label: 'Western'),
    DropdownMenuEntry(value: 'Japanese', label: 'Japanese'),
    DropdownMenuEntry(value: 'Korean', label: 'Korean'),
    DropdownMenuEntry(value: 'Thai', label: 'Thai'),
    DropdownMenuEntry(value: 'Nyonya', label: 'Nyonya'),
    DropdownMenuEntry(value: 'Fast Food', label: 'Fast Food'),
    DropdownMenuEntry(value: 'Indonesian', label: 'Indonesian'),
    DropdownMenuEntry(value: 'Middle Eastern', label: 'Middle Eastern'),
    DropdownMenuEntry(value: 'Italian', label: 'Italian'),
    DropdownMenuEntry(value: 'Vietnamese', label: 'Vietnamese'),
    DropdownMenuEntry(value: 'Seafood', label: 'Seafood'),
  ];
  late Future<QuerySnapshot<Map<String,dynamic>>> todayMeals;

  @override
  void initState(){
    super.initState();

    final controller = Get.put(MealRecommendationController());
    todayMeals = controller.displayTodayMeals();
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(MealRecommendationController());
    // final todayMeals = controller.todayMeals;
    // var mealType = controller.mealType;


    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text("Meal Recommendation"),
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: AppSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                //Container to display today's meals
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: dark ?  const Color(0xFF221E19) : AppColors.apricotCream100,
                    border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkerGrey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0,4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Today's Meal History",
                          style: TextStyle(fontSize: AppSizes.md, fontWeight: FontWeight.bold)
                      ),

                      SizedBox(height: AppSizes.spaceBtwItems),

                      FutureBuilder(
                        future: todayMeals,
                        builder: (context, todayMeal){

                          if(todayMeal.connectionState == ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator());
                          }

                          if(!todayMeal.hasData || todayMeal.data!.docs.isEmpty){
                            return const Center(child: Text("No meals found"));
                          }

                          if(todayMeal.hasError){
                            return Center(child: Text(todayMeal.error.toString()));
                          }

                          final meals = todayMeal.data!.docs;

                          return ListView.builder(
                              itemCount: meals.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                final meal = meals[index].data(); //JSON output from Firestore
                                return ListTile(
                                  title: Text(meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name'),
                                  subtitle: Text(
                                      "Carbs: ${meal['analysis']['nutrients'][0]['carbs_macro']} | Protein: ${meal['analysis']['nutrients'][0]['protein_macro']} | Fats: ${meal['analysis']['nutrients'][0]['fats_macro']} "),
                                );
                              }
                          );
                        }
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meal Type",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Which meal are you planning next?',
                        style: TextStyle(
                          fontSize: 13,
                          color: dark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      //meal type chips selector
                      Obx(() => Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(mealType.length, (index){
                            final type = mealType[index];
                            final isSelected = controller.selectedMealType.value == type;

                            return ChoiceChip(
                              label: Text(type),
                              showCheckmark: false,
                              selected: isSelected,
                              // showCheckmark: false,
                              onSelected: (bool selected){
                                setState((){
                                  controller.selectedMealType.value = selected ? type : '';
                                });
                              },
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meal Cuisine",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'What cuisine are you craving for?',
                        style: TextStyle(
                          fontSize: 13,
                          color: dark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      //meal cuisine drop down menu
                      Obx(() => DropdownMenu<String>(
                        width: MediaQuery.of(context).size.width,
                        initialSelection: controller.selectedMealCuisine.value,
                        dropdownMenuEntries: cuisine,
                        onSelected: (value){
                          if(value!=null){
                            controller.selectedMealCuisine.value = value;
                          }
                        },
                        requestFocusOnTap: true,
                        enableSearch: true,
                        enableFilter: true,

                        menuHeight: 250,
                      ))
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                //preferred and avoided categories
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF221E19) : AppColors.white,
                    border: Border.all(
                      color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meal Preferences",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            color: dark ? const Color(0xFF81C784) : const Color(0xFF366339),
                            size: 18
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preferred Categories',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Obx(() {
                                  if(controller.preferredCategories.isEmpty){
                                    return const Text("No preferred categories yet",
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic));
                                  }
                                  return Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: controller.preferredCategories.map((category){
                                      return Chip(
                                        label: Text(
                                          category,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF366339), fontWeight: FontWeight.bold),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: AppColors.celadon400.withOpacity(0.2),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                              Icons.block_outlined,
                              color: dark ? const Color(0xFFEF959D) : const Color(0xFF960018),
                              size: 18
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Avoided Categories',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Obx(() {
                                  if(controller.avoidCategories.isEmpty){
                                    return const Text("No avoided categories yet",
                                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic));
                                  }
                                  return Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: controller.avoidCategories.map((category){
                                      return Chip(
                                        label: Text(
                                          category,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF960018), fontWeight: FontWeight.bold),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: const Color(0xFF960018).withOpacity(0.1),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                Obx((){
                  if(controller.isLoading.value){
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSizes.spaceBtwItems),
                          const Text("Response is loading..."),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () async {
                          await controller.generateMealRecs();
                          Get.to(() => const MealRecommendationResults());
                        },
                        child: const Text("Generate Meal Recommendations"),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwSections),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
    );
  }
}
