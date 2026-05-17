import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MealHistoryController extends GetxController{

  QuerySnapshot<Map<String, dynamic>>? cachedData;
  bool latestData = true;
  final user = FirebaseAuth.instance.currentUser;

  Future<QuerySnapshot<Map<String, dynamic>>> displayCurrentUserMeals() async {

    if(cachedData!=null && latestData){
      print("GETTING CACHED DATA");
      return cachedData!;
    }

    var mealHistoryQuery = await FirebaseFirestore.instance
        .collection('meals')
        .where('user', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .get();

    cachedData = mealHistoryQuery;
    latestData = true;
    print("READING FROM DATABASE");

    return mealHistoryQuery;
  }

  Future<void> deleteMeals() async{
    
  }
}
