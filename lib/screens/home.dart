import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';
import 'package:mynextmeal/screens/meal_history_page.dart';
import '../features/user/user_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'image_analysis.dart';
import 'individual_meal.dart';
import 'meal_recommendation.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final mealHistoryController = Get.find<MealHistoryController>();
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Welcome,",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.primary,
                    fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize! + 5),
                  ),

              //observe and change state of widget
              Obx(() => Text(controller.user.value.username,style: Theme.of(context).textTheme.headlineMedium)),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Row(
                children: [
                  //Gemini button
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ElevatedButton(
                          onPressed: () => Get.to(() => const ImageAnalysis()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lunch_dining, size: 40),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              Text("Add New Meal", style: TextStyle(fontSize: AppSizes.buttonTextSize)),
                            ],
                          )
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSizes.spaceBtwSections),

                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ElevatedButton(
                          onPressed: () => Get.to(() => const MealRecommendation()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Icon(Icons.restaurant, size: 40),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              Text("My Next Meal", style: TextStyle(fontSize: AppSizes.buttonTextSize)),
                            ],
                          )
                    ),
                  ),
                ),
              ],
            ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Text("Meal History",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              StreamBuilder(
                  stream: mealHistoryController.displayCurrentUserMeals(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }

                    if(snapshot.hasError){
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                      return const Center(child: Text("No meals found"));
                    }

                    final meals = snapshot.data!.docs;

                    return ListView.builder(
                        itemCount: meals.length > 5 ? 5 : meals.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context,index){
                          final meal = meals[index].data(); //JSON output from Firestore
                          final mealId = meals[index].id;

                          //format date for output
                          final timestamp = meal['createdAt'];
                          final date = timestamp.toDate();
                          final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                          return GestureDetector(
                            onTap: () => Get.to(() => IndividualMeal(mealId, meal['imageUrl'])),
                            child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems/2),

                                decoration: BoxDecoration(
                                  color: dark ? AppColors.celadon800 : AppColors.white,
                                  border: Border.all(color: Colors.transparent, width: 0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkerGrey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0,4),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                ),

                                child: ListTile(
                                  title: Text(
                                      meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name',
                                      style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  subtitle: Text(
                                      "Carbs: ${meal['analysis']['nutrients'][0]['carbs_macro']} | Protein: ${meal['analysis']['nutrients'][0]['protein_macro']} | Fats: ${meal['analysis']['nutrients'][0]['fats_macro']} \n"
                                          "Uploaded At: $formattedDateTime"),
                                )
                            ),
                          );
                        }
                    );
                  }
              ),

              const SizedBox(height: AppSizes.spaceBtwItems),

              //Meal recommender button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Get.to(() => const MealHistoryPage()),
                    child: const Text("View All Meals")),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ImageAnalysis()),
        backgroundColor: Color(0xFF226147),
        foregroundColor: AppColors.celadon100,
        child: const Icon(Icons.add),
      ),
    );
  }
}