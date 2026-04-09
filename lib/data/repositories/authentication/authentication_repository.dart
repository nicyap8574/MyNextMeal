import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../../screens/login.dart';
import '../../../screens/main_navigation_screen.dart';
import '../../../utils/popups/loaders.dart';

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    FlutterNativeSplash.remove(); //remove the splash screen
    screenRedirect();
  }

  //Redirect to respective screen
  void screenRedirect() async{
    final user = _auth.currentUser;

    if(user != null){
      Get.offAll(() => const MainNavigationScreen());
    }else{
      Get.offAll(() => const LoginScreen());
    }
  }

  //Login user
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async{
    try{
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (e){
      final details = e.message ?? 'No additional details provided.';

      if(e.code == 'email-already-in-use'){
        throw 'Email has already been used';
      }else{
        throw 'Authentication failed (${e.code}): $details';
      }
    }
  }

  //Register user
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
    try{
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (e){
      final details = e.message ?? 'No additional details provided.';

      if(e.code == 'email-already-in-use'){
        throw 'Email has already been used';
      }else{
        throw 'Authentication failed (${e.code}): $details';
      }
    }
  }
}