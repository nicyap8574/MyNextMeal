import 'package:flutter/material.dart';
import 'package:mynextmeal/utils/theme/custom_themes/chip_theme.dart';
import '../constants/colors.dart';
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_thene.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/outlined_button_theme.dart';
import 'custom_themes/progress_indicator_theme.dart';
import 'custom_themes/text_field_name.dart';
import 'custom_themes/text_theme.dart';

class AppTheme{
  AppTheme._(); //private constructor

  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    inputDecorationTheme: AppTextFieldName.lightInputDecorationTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
    progressIndicatorTheme: AppProgressIndicatorTheme.lightProgressIndicatorTheme,

    //TODO: Add other themes, such as bottomNavigationBarTheme
  );

  static ThemeData darkMode = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: AppTextTheme.darkTextTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    inputDecorationTheme: AppTextFieldName.darkInputDecorationTheme,
    checkboxTheme: AppCheckboxTheme.darkCheckboxTheme,
    progressIndicatorTheme: AppProgressIndicatorTheme.darkProgressIndicatorTheme,
  );

}