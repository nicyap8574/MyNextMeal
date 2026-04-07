import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../../screens/login.dart';

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    FlutterNativeSplash.remove(); //remove the splash screen
    screenRedirect();
  }

  screenRedirect() async{
    //local storage
    deviceStorage.writeIfNull('NewUser', true);
    if(deviceStorage.read('NewUser') != true){
      //Not new user, show home page
    }else{
      //New user, show login page
      Get.offAll(()
      {
        return const LoginScreen();
      },
      );
    }
  }

  //Register user
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
    try{
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (e){
      final details = e.message ?? 'No additional details provided.';
      throw 'Authentication failed (${e.code}): $details';
    }catch(e){
      throw "Unexpected authentication error: $e";
    }
  }



}