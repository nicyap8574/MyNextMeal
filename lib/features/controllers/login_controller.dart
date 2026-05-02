import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mynextmeal/features/models/user_model.dart';

import '../../data/repositories/authentication_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/popups/loaders.dart';
import '../personalisation/user_controller.dart';

class LoginController extends GetxController {

  //Variables
  final hidePassword = true.obs; //observer
  final rememberMe = false.obs; //observer
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>(); //Form validation
  final localStorage = GetStorage();
  final userRepository = Get.put(UserRepository());
  final userController = Get.put(UserController());

  Future<void> signIn({required BuildContext context}) async{
    try{
      //Check if form is valid
      if(!loginFormKey.currentState!.validate()){
        return;
      }

      //Remember Me
      if(rememberMe.value){
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      //Login user
      final userCredential = await AuthenticationRepository.instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      //Redirect
      AuthenticationRepository.instance.screenRedirect();
    }catch(e){
      AppLoaders.showSnackBar(context, "Error: $e");
    }
  }

  Future<void> googleSignIn({required BuildContext context}) async{
    try{
      final userCredential = await AuthenticationRepository.instance.signInWithGoogle();

      //save user record
      await userController.saveUserRecord(userCredential);
      // await userController.fetchUserRecord();

      //Redirect
      AuthenticationRepository.instance.screenRedirect();
    }catch(e){
      AppLoaders.showSnackBar(context, "Error: $e");
    }
  }
}