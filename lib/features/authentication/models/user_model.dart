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

  //Convert model to JSON structure
  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'username': username,
      'email': email,
    };
  }
}