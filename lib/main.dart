import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mynextmeal/features/auth/forgot_password_controller.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
import 'package:mynextmeal/features/meals/individual_meal_controller.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import 'package:mynextmeal/features/user/user_controller.dart';
import 'services/network_manager.dart';
import 'features/auth/auth_controller.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {

  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  //Initialise local storage
  await GetStorage.init();

  //Await splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); //Until removed in onReady() in authentication_repository.dart

  //Initialise firebase
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  Get.put(AuthController());
  Get.put(UserController());
  Get.put(UserProfileController());
  Get.put(NetworkManager());
  Get.put(ImageAnalysisController());
  Get.put(MealHistoryController());
  Get.put(IndividualMealController());
  Get.put(ForgotPasswordController());
  //
  // Get.lazyPut(() => ImageAnalysisController());
  // Get.lazyPut(() => IndividualMealController());
  // Get.lazyPut(() => MealHistoryController());

  runApp(const App());
}

