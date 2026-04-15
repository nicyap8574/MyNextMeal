import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/popups/loaders.dart';

class UserProfileController extends GetxController{
  static UserProfileController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;


  Future<void> saveChanges({
    required BuildContext context,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
  }) async {
    final user = _auth.currentUser;

    // print("Diet Options: $selectedDietOptions");
    // print("Diet Focus: $selectedDietaryFocus");

    //Save to database
    try{
      await _db.collection('users').doc(user!.uid).set({
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
      }, SetOptions(merge: true));

      //AppLoaders.successSnackBar(title: "Success", message: "Changes Saved!");
      AppLoaders.showSnackBar(context, "Changes Saved!");

    }catch(e){
      print("Error saving changes: $e");
    }
  }

  Future<Map<String,dynamic>?> getSelectedPreferences() async{
    final user = _auth.currentUser;
    final doc = await _db.collection('users').doc(user!.uid).get(); //loads document of current user

    if(doc.exists){
      return doc.data();
    }
    return null;
  }
}

