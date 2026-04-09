import 'package:flutter/material.dart';
import 'package:mynextmeal/utils/helpers/helper_functions.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [

            ]
        ),
      ),
      ),
    );
  }
}
