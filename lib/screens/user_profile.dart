import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/user/user_controller.dart';
import 'package:mynextmeal/screens/profile_settings.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late UserProfileController controller;

  String email = '';
  String id = '';
  String username = '';

  @override
  void initState(){
    super.initState();

    controller = Get.find<UserProfileController>();
    loadUserData();
  }

  //Show previously-selected diet and focus options (get from database)
  void loadUserData() async{
    try {
      final data = await controller.getUserDetails();

      if(data != null && data['id'] != null && data['id'] != ''){
        setState((){
          //extract from user's document database
          email = data['email'] ?? "No email set";
          id = data['id'] ?? "No ID set";
          username = data['username'] ?? "No username set";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        email = "Error loading profile";
        id = "Error loading profile";
        username = "Error loading profile";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileController = Get.find<UserProfileController>();
    final userController = Get.find<UserController>();

        return SingleChildScrollView(
            child: Padding(
              padding: AppSpacingStyle.paddingWithAppBarHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // SizedBox(height: AppSizes.spaceBtwItems),

                  Text(username),

                  SizedBox(height: AppSizes.spaceBtwSections),

                  Container(
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // SizedBox(height: AppSizes.spaceBtwItems),

                  Text(email),

                  SizedBox(height: AppSizes.spaceBtwSections),

                  Container(
                    child: Text(
                      'User ID',
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(id),

                  SizedBox(height: AppSizes.spaceBtwSections),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => Get.to(() => const ProfileSettings()),
                        child: const Text("Profile Settings")),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => userController.signOut(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.apricotCream700,
                            side: BorderSide.none,
                        ),
                        child: const Text("Sign Out")),
                  ),
                ],
              ),
            ),
        );
  }
}