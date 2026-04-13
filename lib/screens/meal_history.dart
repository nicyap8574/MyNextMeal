import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mynextmeal/common/styles/spacing_styles.dart';

import '../features/controllers/meal_history_controller.dart';

class MealHistory extends StatelessWidget {
  const MealHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealHistoryController());
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
      ),
      body: FutureBuilder(
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

            //query snapshot (from displayCurrentUserMeals())
            final meals = snapshot.data!.docs;

            return ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context,index){
                  final meal = meals[index].data(); //JSON output from Firestore

                  // print(meal.runtimeType);
                  // print(meal);

                  return ListTile(
                    title: Text(meal['analysis']['nutrients'][0]['meal_name'] ?? 'No name'), //[0] means get the first (and only) item from nutrients list
                    //analysis -> map{} / Map<String,dynamic>
                    //nutrients -> list[] / List<dynamic>
                    //inside nutrients[], {} -> Map<String,dynamic>
                  );
                }
            );
          }
      )
    );

  }
}
