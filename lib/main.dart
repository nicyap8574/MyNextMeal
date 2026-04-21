import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mynextmeal/features/controllers/user_profile_controller.dart';

import 'firebase_options.dart';

import 'app.dart';
import 'data/repositories/authentication_repository.dart';

Future<void> main() async {

  //Add widgets binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  //Initialise local storage
  await GetStorage.init();

  //Await splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); //Until removed in onReady() in authentication_repository.dart

  //Initialise firebase
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  Get.put(AuthenticationRepository());
  Get.put(UserProfileController());

  runApp(const App());
}

