import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/utils/constants/colors.dart';
import 'package:mynextmeal/utils/theme/theme.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {

  //Initialise firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
      (FirebaseApp value) => Get.put(AuthenticationRepository()), //check current state of the user
  );

  //Initialise authentication


  runApp(const App());

}