import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealHistoryController {

  Future<QuerySnapshot<Map<String, dynamic>>> displayCurrentUserMeals() async {
    final user = FirebaseAuth.instance.currentUser;

    var mealHistoryQuery = await FirebaseFirestore.instance
        .collection('meals')
        .where('user', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return mealHistoryQuery;
    }
  }
