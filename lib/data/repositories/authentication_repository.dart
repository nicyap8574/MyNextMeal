import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mynextmeal/common/widgets/app_navigation_bar.dart';
import '../../screens/login.dart';
import '../../utils/popups/loaders.dart';

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
    //get details of currently logged in user
    final user = _auth.currentUser;

    if(user != null){
      // Get.offAll(() => const Home());
      Get.offAll(() => const AppNavigationBar());
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
      }else if(e.code == 'invalid-credential'){
        throw 'Invalid email or password';
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

  //Forgot password
  Future<void> forgotPassword(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      AppLoaders.showSnackBar(Get.context!, "Password reset email sent");
    }on FirebaseAuthException catch (e){
      final details = e.message ?? 'No additional details provided.';
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //TODO: Google sign in
  Future<UserCredential> signInWithGoogle() async{
    try{
      //trigger the authentication flow
      // final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
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