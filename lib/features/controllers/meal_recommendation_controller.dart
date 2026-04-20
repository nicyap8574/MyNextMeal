import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class MealRecommendationController {
  static MealRecommendationController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getTodayMeals() async{
    //retrieves details of current user
    final user = _auth.currentUser;

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

    return todayMeal;
  }


}