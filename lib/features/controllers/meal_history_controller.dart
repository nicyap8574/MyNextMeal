import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealHistoryController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> displayCurrentUserMeals() async {
    final user = _auth.currentUser;

    var mealHistoryQuery = await _db.collection('meals').where('user', isEqualTo: user!.uid).get();

    return mealHistoryQuery;
    }
  }
