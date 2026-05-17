import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../utils/popups/loaders.dart';

class UserProfileController extends GetxController{
  //look for existing instance in memory
  static UserProfileController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final user = _auth.currentUser;

  Map<String,dynamic>? cachedData;

  Future<void> saveChanges({
    required BuildContext context,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
  }) async {

    //Save to database
    try{
      await _db.collection('users').doc(user!.uid).set({
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
      };

      AppLoaders.showSnackBar(context, "Changes Saved!");

    }catch(e){
      print("Error saving changes: $e");
    }
  }

  Future<Map<String,dynamic>?> getUserDetails() async{

    if(cachedData!=null){
      return cachedData;
    }else{
      final doc = await _db
          .collection('users')
          .doc(user!.uid)
          .get(); //loads document of current user

      if(doc.exists){
        cachedData = doc.data();
        return doc.data();
      }
      return null;
    }
  }
}

