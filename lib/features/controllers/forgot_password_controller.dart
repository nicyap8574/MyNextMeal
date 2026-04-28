import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/data/repositories/authentication_repository.dart';
import 'package:mynextmeal/screens/forgot_password_sheet.dart';
import 'package:mynextmeal/utils/popups/loaders.dart';

import '../../data/network/network_manager.dart';

class ForgotPasswordController extends GetxController{

  static ForgotPasswordController get instance => Get.find();

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

      //send email to reset password
      await AuthenticationRepository.instance.forgotPassword(email.text.trim());
      Get.back();

      //show success message
      AppLoaders.showSnackBar(Get.context!, "Password reset email sent");

      Get.to(() => ForgotPasswordSheet(email: email.text.trim()));
      Get.back();

      Get.dialog(
        AlertDialog(
          title: const Text("Password reset link has been sent"),
          content: const Text(
            "We've sent a link to the email address to reset your password."
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK")
            ),
          ],
        ),
      );

    } catch (e) {
      Get.back();
      AppLoaders.showSnackBar(Get.context!, e.toString());
    }
  }

  // resendPasswordResetEmail(String email) async{
  //   try{} catch (e) {}
  // }
}