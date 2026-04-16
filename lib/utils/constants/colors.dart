import 'package:flutter/material.dart';

class AppColors{
  AppColors._(); //private constructor

  //theme picker from Coolors
  static const Color celadon50  = Color(0xFFEFF6EF);
  static const Color celadon100 = Color(0xFFDEEDDF);
  static const Color celadon200 = Color(0xFFBDDDBF);
  static const Color celadon300 = Color(0xFF9CC99F);
  static const Color celadon400 = Color(0xFF7BB77F);
  static const Color celadon500 = Color(0xFF5BA45F);
  static const Color celadon600 = Color(0xFF48844C);
  static const Color celadon700 = Color(0xFF366339);
  static const Color celadon800 = Color(0xFF244226);
  static const Color celadon900 = Color(0xFF122113);
  static const Color celadon950 = Color(0xFF0D170D);

  //App colours
  static const Color primary = Color(0xFF48844c);
  static const Color secondary = Color(0xFFdeeddf);
  static const Color accent = Color(0xFFFCDDBC);

  //Text colours
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Color(0xFFFFFFFF);

  //Background colours
  // static const Color lightBackground = Color(0xFFF6F6F6);
  static const Color lightBackground = Color(0xFFfdfae7);
  static const Color darkBackground = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF6F6F6);

  //Background container colours
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = AppColors.textWhite.withOpacity(0.1);

  //Button colours
  static const Color primaryButton = Color(0xFF48844C);
  static const Color secondaryButton = Color(0xFFdeeddf);
  static const Color disabledButton = Color(0xFFC4C4C4);

  //Border colours
  static const Color primaryBorder = Color(0xFF366339);
  static const Color secondaryBorder = Color(0xFFb5cdb6);

  //Error and validation colours
  static const Color error = Color(0xFFEF959D);
  static const Color success = Color(0xFF366339);

  //neutral colours
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);



}