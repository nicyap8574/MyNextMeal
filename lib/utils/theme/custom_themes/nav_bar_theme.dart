import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppNavBarTheme {
  static final lightNavBarTheme = NavigationBarThemeData(
    backgroundColor: AppColors.apricotCream100,
    indicatorColor: AppColors.apricotCream700,
  );

  static final darkNavBarTheme = NavigationBarThemeData(
    backgroundColor: Color(0xFF211f26),
    indicatorColor: AppColors.apricotCream800,
  );
}