import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/user/user_controller.dart';
import 'package:mynextmeal/screens/profile_settings.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import 'package:shimmer/shimmer.dart';
import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

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
    final dark = AppHelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
            child: Padding(
              padding: AppSpacingStyle.paddingWithAppBarHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: dark ?  const Color(0xFF221E19) : AppColors.white,
                      border: Border.all(
                        color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: AppSizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        username.isEmpty ? _buildShimmerLoader(width: 120, dark: dark) : Text(username),

                        SizedBox(height: AppSizes.spaceBtwSections),

                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: AppSizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        username.isEmpty ? _buildShimmerLoader(width: 120, dark: dark) : Text(email),

                        SizedBox(height: AppSizes.spaceBtwSections),

                        Text(
                          'User ID',
                          style: TextStyle(
                            fontSize: AppSizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        username.isEmpty ? _buildShimmerLoader(width: 120, dark: dark) : Text(id),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.spaceBtwSections),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async{
                        await Get.to(() => const ProfileSettings());
                        loadUserData();
                      },
                        child: const Text("Profile Settings")),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => userController.signOut(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: dark ? AppColors.apricotCream500.withOpacity(0.15) : AppColors.apricotCream100,
                            foregroundColor: dark ? AppColors.apricotCream300 : AppColors.black,
                            side: dark ? BorderSide(color: Colors.white.withOpacity(0.15)) : BorderSide.none,
                        ),
                        child: const Text("Sign Out")),
                  ),
                ],
              ),
            ),
        );
  }

  Widget _buildShimmerLoader({required double width, required bool dark}){
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: 16,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}