import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/popups/loaders.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  //Variables
  final hidePassword = true.obs; //observer
  final rememberMe = false.obs; //observer
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>(); //Form validation
  final localStorage = GetStorage();

  Future<void> signIn() async{
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
      AppLoaders.errorSnackBar(title: "Error", message: (e));
    }
  }
}