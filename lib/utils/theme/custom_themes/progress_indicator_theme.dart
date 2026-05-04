import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppProgressIndicatorTheme {

  static ProgressIndicatorThemeData lightProgressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColors.primary,
    circularTrackColor: AppColors.grey,
  );

  static ProgressIndicatorThemeData darkProgressIndicatorTheme = ProgressIndicatorThemeData(
    color: Colors.white,
    circularTrackColor: AppColors.grey,
  );
}