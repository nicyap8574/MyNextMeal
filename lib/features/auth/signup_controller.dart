import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynextmeal/features/auth/auth_controller.dart';
import '../user/user_controller.dart';
import '../user/user_repository.dart';
import '../../screens/login.dart';
import '../../utils/popups/loaders.dart';
import '../user/user_model.dart';

class SignupController extends GetxController{

  //Variables
  final hidePassword = true.obs;
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>(); //Form validation

  Future<void> signup({required BuildContext context}) async{
    try{

      //Check if form is valid
      if(!signupFormKey.currentState!.validate()){
        return;
      }

      //Verify if passwords match
      if(password.text.trim() != confirmPassword.text.trim()){
        AppLoaders.showSnackBar(context, "Passwords do not match");
        // return "Passwords do not match";
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try{
        //Register user in firebase authentication and save user data in firebase
        final userCredential = await AuthController.instance.registerWithEmailAndPassword(email.text.trim(), password.text.trim());


        final newUser = UserModel(
          id: userCredential.user!.uid,
          username: username.text.trim(),
          email: email.text.trim(),
        );

        final userRepository = Get.put(UserRepository());
        await userRepository.saveUserRecord(newUser);

        final userController = Get.find<UserController>();
        userController.user(newUser);

        Navigator.of(context).pop();

        //Show success message
        AppLoaders.showSnackBar(context, "User created successfully");

        //Automatically redirect to home screen (already logged in)
        AuthController.instance.screenRedirect();
      }catch(e){
        Navigator.of(context).pop();
        rethrow;
      }

      //catch errors with Firebase Authentication
    } on FirebaseAuthException catch (e) {
      final details = e.message ?? 'No additional details provided.';

      AppLoaders.showSnackBar(context, "Auth Error: $details");

      //catch Firestore errors
    } on FirebaseException catch (e) {
      final details = e.message ?? 'No additional details provided.';

      AppLoaders.showSnackBar(context, "Firebase Error: $details");


    } catch(e){
      AppLoaders.showSnackBar(context, "Error: $e");

    }
  }
}