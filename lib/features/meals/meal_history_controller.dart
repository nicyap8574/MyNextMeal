import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';

class MealHistoryController extends GetxController{

  static MealHistoryController get instance => Get.find();
  final imageAnalysisController = Get.find<ImageAnalysisController>();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Stream<QuerySnapshot<Map<String, dynamic>>> displayCurrentUserMeals(){
    final user = _auth.currentUser;

    return FirebaseFirestore.instance
        .collection('meals')
        .where('user', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteAllMeals() async{
    final user = _auth.currentUser;

    //find meals to delete
    final mealData = await _db.collection('meals').where('user', isEqualTo: user!.uid).get();

    for (final doc in mealData.docs) {
      // print(doc.id);
      // print(doc.data());
      final data = doc.data();

      //delete image from Cloud Storage
      final imageUrl = data['imageUrl'];

      if(imageUrl != null){
        await imageAnalysisController.deleteImage(imageUrl: imageUrl);
      }

      //delete from Firestore
      await _db.collection('meals').doc(doc.id).delete();

    }
  }
}
