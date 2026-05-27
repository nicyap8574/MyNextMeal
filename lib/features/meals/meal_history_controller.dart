import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MealHistoryController extends GetxController{

  QuerySnapshot<Map<String, dynamic>>? cachedData;
  bool latestData = true;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> displayCurrentUserMeals(){
    final user = _auth.currentUser;
    //
    // if(cachedData!=null && latestData){
    //   print("GETTING CACHED DATA");
    //   return cachedData!;
    // }
    //
    // var mealHistoryQuery = await FirebaseFirestore.instance
    //     .collection('meals')
    //     .where('user', isEqualTo: user!.uid)
    //     .orderBy('createdAt', descending: true)
    //     .get();
    //
    // cachedData = mealHistoryQuery;
    // latestData = true;
    // print("READING FROM DATABASE");
    //
    // return mealHistoryQuery;

    return FirebaseFirestore.instance
        .collection('meals')
        .where('user', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteMeals() async{
    
  }
}
