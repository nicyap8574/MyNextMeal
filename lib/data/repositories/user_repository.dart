import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/models/user_model.dart';
import '../../screens/login.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //Save user data to Firestore
  Future<void> saveUserRecord(UserModel user) async{
    try{
      //collection name: users
      //document name: user.id
      await _db.collection('users').doc(user.id).set(user.toJson()); //automatically creates document if doesn't exist

    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore write failed (${e.code}): $details';

    }catch(e){
      throw "Unexpected error while saving user record: $e";
    }
  }

  //Fetch user details based on user ID
  Future<UserModel> fetchUserDetails() async{
    final user = _auth.currentUser;
    try{
      final documentSnapshot = await _db.collection('users').doc(user!.uid).get();

      if(documentSnapshot.exists){
        return UserModel.fromSnapshot(documentSnapshot);
      }else{
        return UserModel.empty();
      }
    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore failed (${e.code}): $details';

    }catch(e){
      throw "Unexpected error occurred: $e";
    }
  }

  //Update user data
/*  Future<void> updateUserDetails(UserModel updateUser) async{
    final user = _auth.currentUser;
    try{
      await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toJson());
    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore failed (${e.code}): $details';

    }catch(e){
      throw "Unexpected error occurred: $e";
    }
  }*/

  //Update user data (any field)
  Future<void> updateSingleField(Map<String, dynamic> json) async{
    final user = _auth.currentUser;
    try{
      await _db.collection("Users").doc(user!.uid).update(json);
    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore failed (${e.code}): $details';
    }catch(e){
      throw "Unexpected error occurred: $e";
    }
  }

  //Remove user data
  Future<void> deleteUser(String userId) async{
    final user = _auth.currentUser;
    try{
      await _db.collection("Users").doc(user!.uid).delete();
    }on FirebaseException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Firestore failed (${e.code}): $details';

    }catch(e){
      throw "Unexpected error occurred: $e";
    }
  }


}