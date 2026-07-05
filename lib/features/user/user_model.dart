import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final double? height;
  final double? weight;
  final int? age;
  final String? activityLevel;
  final bool hasCompletedOnboarding;

  //Constructor
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.height,
    this.weight,
    this.age,
    this.activityLevel,
    this.hasCompletedOnboarding = false,
  });

  //Empty user model (Helper method)
  static UserModel empty(){
    return UserModel(
        id: '',
        username: '',
        email: '',
        hasCompletedOnboarding: false,
    );
  }

  //Convert model to JSON structure
  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'username': username,
      'email': email,
      'height': height,
      'weight': weight,
      'age': age,
      'activityLevel': activityLevel,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  //Extracts data from Firestore document
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data();
    if (data != null){
      return UserModel(
        id: document.id,
        username: data['username'],
        email: data['email'],
        height: data['height'],
        weight: data['weight'],
        age: data['age'],
        activityLevel: data['activityLevel'],
        hasCompletedOnboarding: data['hasCompletedOnboarding'],
      );
    }else{
      return UserModel.empty();
    }
  }
}