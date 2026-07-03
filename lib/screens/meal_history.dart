import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import '../features/meals/meal_history_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/popups/loaders.dart';
import 'image_analysis.dart';
import 'individual_meal.dart';

class MealHistory extends StatelessWidget {
  const MealHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.find<MealHistoryController>();

    return SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
            stream: controller.displayCurrentUserMeals(),
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }

              if(snapshot.hasError){
                return Center(child: Text(snapshot.error.toString()));
              }

              if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceBtwSections,
                    horizontal: AppSizes.lg,
                  ),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.apricotCream900 : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                    border: Border.all(
                      color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lunch_dining,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      SizedBox(height: AppSizes.md),
                      Text(
                        'No meals logged today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        "Let's get started by adding your first meal!",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.md),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const ImageAnalysis()),
                        child: Text('Add my first meal'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final meals = snapshot.data!.docs;

              return Column(
                children:[
                  ListView.builder(
                      itemCount: meals.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        final meal = meals[index].data(); //JSON output from Firestore
                        final mealId = meals[index].id;

                        //format date for output
                        final timestamp = meal['createdAt'];
                        final date = timestamp.toDate();
                        final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(() => IndividualMeal(mealId, meal['imageUrl'])),
                              child: Container(
                                  width: double.infinity,
                                  height: 95,
                                  margin: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems/2, horizontal: 16),

                                  decoration: BoxDecoration(
                                    color: dark ? AppColors.apricotCream800 : AppColors.white,
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

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: 95,
                                          child: meal['imageUrl'] != null && meal['imageUrl'].toString().isNotEmpty
                                              ? Image.network(
                                            meal['imageUrl'],
                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.fastfood, color: Colors.white),
                                          ),
                                        ),

                                        Expanded(
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "Carbs: ${meal['analysis']['nutrients'][0]['carbs_macro']} | Protein: ${meal['analysis']['nutrients'][0]['protein_macro']} | Fats: ${meal['analysis']['nutrients'][0]['fats_macro']} \n"
                                                          "Uploaded At: $formattedDateTime",
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                )
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: const Text("Delete History"),
                            content: const Text("Are you sure you want to delete all meal history? This cannot be undone."),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:  Color(0xFF960018),
                                  side: BorderSide.none,
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await controller.deleteAllMeals();
                                },
                              ),

                            ]
                          );
                        }
                      );

                    },
                    label: Text("Delete Meal History"),
                    icon: Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF960018),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      side: const BorderSide(
                        width: 0,
                      ),
                    ),
                  )
                ],

              );
            }
        )
    );
  }
}