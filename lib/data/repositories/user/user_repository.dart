import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../screens/login.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  //Save user data to Firestore
  Future<void> saveUserRecord(UserModel user) async{
    try{
      //collection name: users
      //document name: user.id
      await _db.collection('users').doc(user.id).set(user.toJson());

    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore write failed (${e.code}): $details';

    }catch(e){
      throw "Unexpected error while saving user record: $e";
    }
  }



}