import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynextmeal/data/repositories/authentication/authentication_repository.dart';

import '../../data/repositories/user/user_repository.dart';
import '../../utils/popups/loaders.dart';
import '../models/user_model.dart';

class SignupController extends GetxController{
  static SignupController get instance => Get.find();

  //Variables
  final hidePassword = true.obs;
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>(); //Form validation

  Future<void> signup() async{
    try{

      //Check if form is valid
      if(!signupFormKey.currentState!.validate()){
        return;
      }

      //Verify if passwords match
      if(password.text.trim() != confirmPassword.text.trim()){
        AppLoaders.errorSnackBar(title: "Error", message: "Passwords do not match");
        return;
      }

      //Register user in firebase authentication and save user data in firebase
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(email.text.trim(), password.text.trim());


      final newUser = UserModel(
        id: userCredential.user!.uid,
        username: username.text.trim(),
        email: email.text.trim(),
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      //Show success message
      AppLoaders.successSnackBar(title: "Success", message: "User created successfully");

      //catch errors with Firebase Authentication
    } on FirebaseAuthException catch (e) {
      final details = e.message ?? 'No additional details provided.';
      AppLoaders.errorSnackBar(
        title: "Auth Error",
        message: "${e.code}: $details",
      );

      //catch Firestore errors
    } on FirebaseException catch (e) {
      final details = e.message ?? 'No additional details provided.';
      AppLoaders.errorSnackBar(
        title: "Firestore Error",
        message: "${e.code}: $details",
      );

    } catch(e){
      AppLoaders.errorSnackBar(title: "Error", message: (e));
    }
  }
}