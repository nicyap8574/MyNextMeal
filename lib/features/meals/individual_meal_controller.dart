import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';


class IndividualMealController extends GetxController{
  static IndividualMealController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final user = _auth.currentUser;
  final repo = Get.find<ImageAnalysisController>();

  Future<Map<String,dynamic>?> getIndividualMeal(mealId) async{
    final meal = await _db
        .collection('meals')
        .doc(mealId)
        .get();

    return meal.data();
  }

  Future<void> deleteMeal(BuildContext context, mealId) async{

    //delete image from Cloud Storage
    final mealData = await getIndividualMeal(mealId);
    if(mealData != null){
      final imageUrl = mealData['imageUrl'];

      if(imageUrl != null){

        try{
          await repo.deleteImage(imageUrl: mealData!['imageUrl']);
        }catch(e){
          print(e);
        }finally{
          showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: const Text("Meal Deleted"),
                  content: const Text("Meal has been deleted successfully"),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    )
                  ],
                );
              }
          );
        }
      }else{
        print("ERROR DELETING IMAGE");
      }
    }else{
      print("MEAL DATA DOES NOT EXIST");
    }

    //delete from Firestore
    await _db.collection('meals').doc(mealId).delete();
  }
}