import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mynextmeal/utils/constants/colors.dart';
import 'package:mynextmeal/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkMode,
      home: const Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(),
      ),
    );
  }
}