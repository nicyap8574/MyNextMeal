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
  final weightHistory = <Map<String,dynamic>>[].obs;

  Future<void> saveChanges({
    required BuildContext context,
    required String username,
    required List<String> selectedDietOptions,
    required List<String> selectedDietaryFocus,
    required List<String> selectedNutritionalGoals,
    required List<String> selectedRestrictions
  }) async {

    //Save to database
    try{
      await _db.collection('users').doc(user!.uid).set({
        'username': username,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'nutritionalGoals': selectedNutritionalGoals,
        'dietaryRestrictions': selectedRestrictions,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'username': username,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'nutritionalGoals': selectedNutritionalGoals,
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
    required List<String> selectedNutritionalGoals,
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
        'nutritionalGoals': selectedNutritionalGoals,
        'dietaryRestrictions': selectedRestrictions,
        'hasCompletedOnboarding': true,
      }, SetOptions(merge: true)); //merge new dietOptions and dietaryFocus with current document

      //save initial weight
      final String dateKey = DateTime.now().toIso8601String().substring(0,10);
      await _db.collection('users').doc(user!.uid).update({
        'weightHistory.$dateKey':{
          'weight': weight,
          'date': dateKey,
        },
      });

      //add selected options to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'id': user!.uid,
        'email': user!.email,
        'username': UserController.instance.user.value.username,
        'height': height,
        'weight': weight,
        'age': age,
        'activityLevel': activityLevel,
        'dietOptions': selectedDietOptions,
        'dietaryFocus': selectedDietaryFocus,
        'nutritionalGoals': selectedNutritionalGoals,
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

  Future<void> updateActivityLevel({required BuildContext context, required String activityLevel}) async {
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

  Future<void> updatePhysicalMetrics({required BuildContext context, required double height, required double weight, required int age}) async {
    try{
      final String dateKey = DateTime.now().toIso8601String().substring(0, 10);

      await _db.collection('users').doc(user!.uid).set({
        'height': height,
        'weight': weight,
        'age': age,
      }, SetOptions(merge: true));

      await _db.collection('users').doc(user!.uid).update({
        'weightHistory.$dateKey': {
          'weight': weight,
          'date': dateKey,
        },
      });

      final existingHistory = Map<String,dynamic>.from(
        cachedData?['weightHistory'] as Map<String,dynamic>? ?? {},
      );
      existingHistory[dateKey] = {'weight': weight, 'date': dateKey};

      //add to cachedData so does not read again from db
      cachedData = {
        ...?cachedData, //merge previous cachedData with new
        'height': height,
        'weight': weight,
        'age': age,
        'weightHistory': existingHistory,
      };

      _rebuildWeightHistoryList(existingHistory);

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
              activityLevel: currentUser.activityLevel,
              hasCompletedOnboarding: true,
            ));
          }
        });
      }
      AppLoaders.showSnackBar(context, "Physical metrics updated successfully");
    }catch(e){
      print("Error saving changes: $e");
      AppLoaders.showSnackBar(context, "Failed to update physical metrics.");
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

  //fetch weight history from Firestore
  Future<List<Map<String,dynamic>>> fetchWeightHistory() async{
    try{
      final data = await getUserDetails();
      if(data == null){
        return [];
      }

      final rawHistory = data['weightHistory'] as Map<String,dynamic>? ?? {};
      _rebuildWeightHistoryList(rawHistory);
      return weightHistory;
    }catch(e){
      print("Error fetching weight history: $e");
      return [];
    }
  }

  void _rebuildWeightHistoryList(Map<String,dynamic> rawHistory){
    final entries = rawHistory.entries.map((entry){ //.map() iterates over all elements in rawHistory
      final entryData = entry.value as Map<String,dynamic>;
      return{
        'date': DateTime.tryParse(entry.key),
        'weight': (entryData['weight'] as num?)?.toDouble(),
      };
    }).toList();

    //sort oldest first
    entries.sort((a,b){
      DateTime firstDate = a['date'] as DateTime;
      DateTime secondDate = b['date'] as DateTime;

      return firstDate.compareTo(secondDate);
    });

    weightHistory.assignAll(entries);
  }

  //reset meal preferences
  Future<void> resetPreferences() async{
    final userRef = await _db.collection('users').doc(user!.uid);

    await userRef.update({
      "categoryStats" : FieldValue.delete(),
      "dietOptions": FieldValue.delete(),
      "dietaryFocus": FieldValue.delete(),
      "nutritionalGoals": FieldValue.delete(),
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

