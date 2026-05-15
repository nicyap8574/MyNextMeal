import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;

  //Constructor
  UserModel({
    required this.id,
    required this.username,
    required this.email
  });

  //Empty user model (Helper method)
  static UserModel empty(){
    return UserModel(id: '', username: '', email: '');
  }

  //Convert model to JSON structure
  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'username': username,
      'email': email,
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
      );
    }else{
      return UserModel.empty();
    }
  }
}