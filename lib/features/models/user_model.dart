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

  //Empty user model
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

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    if (document.data() != null){
      final data = document.data();
      return UserModel(
        id: document.id,
        username: data!['username'],
        email: data['email'],
      );
    }else{
      return UserModel.empty();
    }
  }
}