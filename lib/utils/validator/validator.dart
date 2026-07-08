import 'package:flutter/src/widgets/framework.dart';

class AppValidator{

  //Empty text validation
  static String? validateEmptyText(String? fieldName, String? value){
    if (value == null || value.isEmpty){
      return "$fieldName is required";
    }
    return null;
  }

  //validate username
  static String? validateUsername (String? value){
    if(value==null || value.isEmpty){
      return "Username is required";
    }
    return null;
  }

  //validate email address
  static String? validateEmail(String? value){
    if (value == null || value.isEmpty){
      return "Email is required";
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(!emailRegExp.hasMatch(value)){
      return "Invalid email address";
    }

    return null;
  }

  static String? validateSignUpPassword(String? value) {
    if (value == null || value.isEmpty){
      return "Password is required";
    }

    if(value.length < 6){
      return "Password must be at least 6 characters long";
    }

    return null;
  }

  static String? validateSignInPassword(String? value) {
    if (value == null || value.isEmpty){
      return "Password is required";
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if(value == null || value.trim().isEmpty){
      return "Weight is required";
    }

    final weight = double.tryParse(value);

    if(weight == null){
      return "Please enter a valid number";
    }

    if(weight <= 20.00 || weight >= 250.00){
      return "Weight must be between 20kg and 250kg";
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if(value == null || value.trim().isEmpty){
      return "Height is required";
    }

    final height = double.tryParse(value);

    if(height == null){
      return "Please enter a valid number";
    }

    if(height <= 100.00 || height >= 220.00){
      return "Height must be between 100cm and 220cm.";
    }
    return null;
  }

  static String? validateAge(String? value) {
    if(value == null || value.trim().isEmpty){
      return "Age is required";
    }

    final age = double.tryParse(value);

    if(age == null){
      return "Please enter a valid number";
    }

    if(age <= 13 || age >= 80){
      return "Age must be between 13 and 80.";
    }
    return null;
  }
}