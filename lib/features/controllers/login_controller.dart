import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mynextmeal/features/controllers/auth_controller.dart';
import '../user/user_repository.dart';
import '../../utils/popups/loaders.dart';
import '../user/user_controller.dart';

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
      await AuthController.instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      //Redirect
      AuthController.instance.screenRedirect();
    }catch(e){
      AppLoaders.showSnackBar(context, "Error: $e");
    }
  }

  Future<void> googleSignIn({required BuildContext context}) async{
    try{
      final userCredential = await AuthController.instance.signInWithGoogle();

      //save user record
      await userController.saveUserRecord(userCredential);
      //passes UserCredential data type instead of User data type because it checks for new user

      // await userController.fetchUserRecord();

      //Redirect
      AuthController.instance.screenRedirect();
    }catch(e){
      AppLoaders.showSnackBar(context, "Error: $e");
    }
  }
}