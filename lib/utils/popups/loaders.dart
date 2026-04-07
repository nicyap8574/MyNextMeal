import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AppLoaders{
  static successSnackBar({required title, message = '', duration = 3}){
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM
    );
  }

  static warningSnackBar({required title, message = '', duration = 3}){
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM
    );
  }

  static errorSnackBar({required title, message = '', duration = 3}){
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM
    );
  }
}