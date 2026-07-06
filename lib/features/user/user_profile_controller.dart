import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mynextmeal/features/user/user_controller.dart';
import 'package:mynextmeal/features/user/user_model.dart';
import '../../utils/popups/loaders.dart';

class UserProfileController extends GetxController{
  //look for existing instance in memory
  static UserProfileController get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  Map<String,dynamic>? cachedData;

  Future<void> saveChanges({
    required BuildContext context,
    required String username,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
    required List<String> selectedRestrictions
  }) async {

    //Save to database
    try{
      await _db.collection('users').doc(user!.uid).set({
        'username': username,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'dietaryRestrictions': selectedRestrictions,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'username': username,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'dietaryRestrictions': selectedRestrictions,
      };

      //updates user data
      if(Get.isRegistered<UserController>()){
        final userController = UserController.instance;
        userController.user.update((currentUser){
          if(currentUser != null){
            userController.user(UserModel(
              id: currentUser.id,
              email: currentUser.email,
              username: username,
            ));
          }
        });
      }

      AppLoaders.showSnackBar(context, "Changes Saved!");

    }catch(e){
      print("Error saving changes: $e");
      AppLoaders.showSnackBar(context, "Failed to save changes.");
    }
  }

  Future<void> saveOnboardingDetails({
    required BuildContext context,
    required double height,
    required double weight,
    required int age,
    required String activityLevel,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
    required List<String> selectedRestrictions,
  }) async{
    try{
      await _db.collection('users').doc(user!.uid).set({
        'height': height,
        'weight': weight,
        'age': age,
        'activityLevel': activityLevel,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'dietaryRestrictions': selectedRestrictions,
        'hasCompletedOnboarding': true,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'height': height,
        'weight': weight,
        'age': age,
        'activityLevel': activityLevel,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'dietaryRestrictions': selectedRestrictions,
        'hasCompletedOnboarding': true,
      };

      //updates user data
      if(Get.isRegistered<UserController>()){
        final userController = UserController.instance;
        userController.user.update((currentUser){
          if(currentUser != null){
            userController.user(UserModel(
              id: currentUser.id,
              email: currentUser.email,
              username: currentUser.username,
              height: height,
              weight: weight,
              age: age,
              activityLevel: activityLevel,
              hasCompletedOnboarding: true,
            ));
          }
        });
      }
    }catch(e){
      print("Error saving changes: $e");
      AppLoaders.showSnackBar(context, "Failed to save onboarding preferences.");
    }
  }

  Future<void> saveActivityLevel({required BuildContext context, required String activityLevel}) async {
    try{
      await _db.collection('users').doc(user!.uid).set({
        'activityLevel': activityLevel,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'activityLevel': activityLevel,
      };

      //updates user data
      if(Get.isRegistered<UserController>()){
        final userController = UserController.instance;
        userController.user.update((currentUser){
          if(currentUser != null){
            userController.user(UserModel(
              id: currentUser.id,
              email: currentUser.email,
              username: currentUser.username,
              height: currentUser.height,
              weight: currentUser.weight,
              age: currentUser.age,
              activityLevel: activityLevel,
              hasCompletedOnboarding: true,
            ));
          }
        });
      }
    }catch(e){
      print("Error saving changes: $e");
      AppLoaders.showSnackBar(context, "Failed to save onboarding preferences.");
    }
  }

  Future<Map<String,dynamic>?> getUserDetails() async{

    if(cachedData!=null){
      return cachedData;
    }else{
      try {
        final doc = await _db
            .collection('users')
            .doc(user!.uid)
            .get(); //loads document of current user

        if(doc.exists){
          cachedData = doc.data();
          return doc.data();
        }
        return null;
      } catch (e) {
        print("Error in getUserDetails: $e");
        rethrow;
      }
    }
  }

  //reset meal preferences
  Future<void> resetPreferences() async{
    final userRef = await _db.collection('users').doc(user!.uid);

    await userRef.update({
      "categoryStats" : FieldValue.delete(),
      "dietOptions": FieldValue.delete(),
      "dietaryFocus": FieldValue.delete(),
      "dietaryRestrictions": FieldValue.delete(),
    });

    cachedData = null;
  }

  Future<bool> deleteAccount({String? password}) async{
    final currentUser = _auth.currentUser;

    if(currentUser == null) return false;

    final uid = currentUser.uid;

    try{
      final providerId = currentUser.providerData.first.providerId;

      //reauthenticate user based on their provider
      if(providerId == 'password'){

        if(password == null || password.isEmpty){
          throw 'Password is required for authentication';
        }
        final cred = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(cred);

      }else if(providerId == 'google.com') {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        final GoogleSignInAuthentication? googleAuth = await googleUser
            ?.authentication;

        final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await currentUser.reauthenticateWithCredential(cred);
      }

      //delete all user-specific data from Firestore

      //delete associated meals and image
      final mealsSnapshot = await _db.collection('meals').where('user', isEqualTo: uid).get();
      final batch = _db.batch();

      for (var doc in mealsSnapshot.docs) {
        final data = doc.data();

        //delete image from firestore
        if(data.containsKey('imageUrl') && data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty){
          try{
            final imageRef = FirebaseStorage.instance.refFromURL(data['imageUrl']);
            await imageRef.delete();
          }catch(e){
            print("Error deleting image from Firestore: $e");
          }
        }

        batch.delete(doc.reference);
      }

      //delete associated recommendations
      final recsSnapshot = await _db.collection('recommendations').where('user', isEqualTo: uid).get();
      for (var doc in recsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      //delete user profile record
      batch.delete(_db.collection('users').doc(uid));
      await batch.commit();

      //clear profile controller cached data
      cachedData = null;

      //delete user account from Firebase Authentication
      await currentUser.delete();

      return true;
    }catch(e){
      print("Account deletion error: $e");
      return false;
    }
  }
}

