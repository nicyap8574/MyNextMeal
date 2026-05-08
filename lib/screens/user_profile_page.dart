import 'package:flutter/material.dart';
import 'package:mynextmeal/screens/user_profile.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: const UserProfile(),
    );
  }
}
