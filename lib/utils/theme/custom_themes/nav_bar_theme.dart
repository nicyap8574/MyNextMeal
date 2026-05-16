import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppNavBarTheme {
  static final lightNavBarTheme = NavigationBarThemeData(
    backgroundColor: Color(0xFFf0ecd9),
    indicatorColor: Color(0xFF226147),
  );

  static final darkNavBarTheme = NavigationBarThemeData(
    backgroundColor: Color(0xFF211f26),
    indicatorColor: Color(0xFF244226),
  );
}