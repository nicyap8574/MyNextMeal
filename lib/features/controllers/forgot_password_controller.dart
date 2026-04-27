import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/data/repositories/authentication_repository.dart';
import 'package:mynextmeal/utils/popups/loaders.dart';

import '../../data/network/network_manager.dart';

class ForgotPasswordController extends GetxController{

  final email = TextEditingController();
  GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  //send reset password email
  sendPasswordResetEmail() async{
    try{
      //start loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        Get.back(); //close dialog
        AppLoaders.showSnackBar(Get.context!, "No internet connection");
        return;
      }

      await AuthenticationRepository.instance.forgotPassword(email.text.trim());
      Get.back();

      //show success message
      AppLoaders.showSnackBar(Get.context!, "Password reset email sent");

      Get.to(() => ResetPasswordScreen(email: email.text.trim()));

      //TODO: Design forgot password and reset password screen (12:32)

    } catch (e) {}
  }

  resendPasswordResetEmail(String email) async{
    try{} catch (e) {}
  }
}