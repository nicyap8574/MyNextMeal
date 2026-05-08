import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';

import '../features/controllers/meal_history_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';

class MealHistory extends StatelessWidget {
  const MealHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MealHistoryController>();

    return SingleChildScrollView(
      child: FutureBuilder(
          future: controller.displayCurrentUserMeals(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }

            if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
              return const Center(child: Text("No meals found"));
            }

            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()));
            }

            //query snapshot - documents list (from displayCurrentUserMeals())
            final meals = snapshot.data!.docs;

            return ListView.builder(
                itemCount: meals.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context,index){
                  final meal = meals[index].data(); //JSON output from Firestore

                  //format date for output
                  final timestamp = meal['createdAt'];
                  final date = timestamp.toDate();
                  final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                  return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems/2, horizontal: 16),

                      decoration: BoxDecoration(
                        color: AppColors.white,
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
                  );
                }
            );
          }
      )
    );
  }
}
