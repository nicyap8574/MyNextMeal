import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class IndividualMealController extends GetxController{
  static IndividualMealController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final user = _auth.currentUser;

  Future<Map<String,dynamic>?> getIndividualMeal(mealId) async{
    final meal = await _db
        .collection('meals')
        .doc(mealId)
        .get();

    return meal.data();
  }
}