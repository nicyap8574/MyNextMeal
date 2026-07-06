import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class MealRecommendationHistoryController extends GetxController{
  static MealRecommendationHistoryController get instance => Get.find();

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendations(){
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('recommendations')
        .where('user', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}