import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/common/spacing_styles.dart';

import '../features/user/user_controller.dart';
import '../features/user/user_profile_controller.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {
    final userProfileController = Get.find<UserProfileController>();
    final userController = Get.find<UserController>();

    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Container(
              child: ElevatedButton(
                  // onPressed: userProfileController.resetPreferences,
                  onPressed: () async{
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Reset Meal Preferences'),
                          content: const Text(
                            "Are you sure you want to reset your meal preferences? "
                            "This will clear your preferred and avoided meals.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context,false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context,true),
                              child: const Text("Reset"),
                            ),
                          ],
                        );
                      }
                    );

                    if(confirmed == true){
                      await userProfileController.resetPreferences();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Meal preferences have been reset."),
                        ),
                      );
                    }
                  },
                  child: const Text("Reset Meal Preferences"))
            )
          ]
        )
      )
    );
  }
}
