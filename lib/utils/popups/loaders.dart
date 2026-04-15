import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

//TODO: Combine into one snack bar?

class AppLoaders{
  // static successSnackBar({required title, message = '', duration = 3}){
  //   Get.snackbar(
  //     title,
  //     message,
  //     duration: Duration(seconds: duration),
  //     snackPosition: SnackPosition.BOTTOM
  //   );
  // }
  //
  // static warningSnackBar({required title, message = '', duration = 3}){
  //   Get.snackbar(
  //     title,
  //     message,
  //     duration: Duration(seconds: duration),
  //     snackPosition: SnackPosition.BOTTOM
  //   );
  // }
  //
  // static errorSnackBar({required title, message = '', duration = 3}){
  //   Get.snackbar(
  //     title,
  //     message,
  //     duration: Duration(seconds: duration),
  //     snackPosition: SnackPosition.BOTTOM
  //   );
  // }

  static void showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        )
    );
  }
}