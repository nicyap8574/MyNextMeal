import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/common/spacing_styles.dart';

import '../features/user/user_controller.dart';
import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  late UserProfileController userProfileController;

  Set<int> selectedDietOptions = {}; //stores selected diet options
  Set<int> selectedDietaryFocus = {}; //stores selected dietary focus

  final List<String> dietOptions = [
    'Halal',
    'Vegetarian',
    'Vegan',
    'Keto'
  ];

  final List<String> dietaryFocus = [
    'Type-2 Diabetes',
    'High Cholesterol',
    'Weight Loss',
    'Muscle Gain',
    'General Health'
  ];

  @override
  void initState(){
    super.initState();

    userProfileController = Get.find<UserProfileController>();
    loadUserData();
  }
  //Show previously-selected diet and focus options (get from database)
  Future<void> loadUserData() async{
    final data = await userProfileController.getUserDetails();

    if(data != null){

      final List<dynamic> diet = data['dietOptions'];
      final List<dynamic> focus = data['dietaryFocus'];

      //pre-selects ChoiceChip
      setState((){
        selectedDietOptions = diet.map((item) => dietOptions
            .indexOf(item)) //converts String to index (read by ChoiceChip)
            .toSet(); //converts List to Set

        selectedDietaryFocus = focus.map((item) => dietaryFocus
            .indexOf(item))
            .toSet();
      });
    }
  }

@override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    // final userProfileController = Get.find<UserProfileController>();
    // final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.apricotCream100,
                    border: Border.all(color: Colors.transparent, width: 0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkerGrey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0,4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Container(
                          child: Text(
                            'Dietary Goals',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          child: Text(
                            'Select all that apply',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeSm-1,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        SizedBox(height: AppSizes.spaceBtwItems),

                        Wrap(
                            spacing: 8.0,
                            children: List.generate(dietOptions.length, (index){
                              final isSelected = selectedDietOptions.contains(index);

                              return ChoiceChip(
                                  label: Text(
                                    dietOptions[index],
                                  ),
                                  selected: isSelected,
                                  // showCheckmark: false,
                                  onSelected: (bool selected){
                                    setState((){
                                      if (isSelected){
                                        selectedDietOptions.remove(index);
                                      }else{
                                        selectedDietOptions.add(index);
                                      }
                                    });
                                  }
                              );
                            }
                            )
                        ),

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        Container(
                          child: Text(
                            'Dietary Focus',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          child: Text(
                            'Select all that apply',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeSm-1,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceBtwItems),

                        Wrap(
                            spacing: 8.0,
                            children: List.generate(dietaryFocus.length, (index){
                              final isSelected = selectedDietaryFocus.contains(index);

                              return ChoiceChip(
                                  label: Text(
                                    dietaryFocus[index],
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected){
                                    setState((){
                                      if (isSelected){
                                        selectedDietaryFocus.remove(index);
                                      }else{
                                        selectedDietaryFocus.add(index);
                                      }
                                    });
                                  }
                              );
                            }
                            )
                        ),

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        //save changes button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (){
                              final diet = selectedDietOptions
                                  .map((index) => dietOptions[index])
                                  .toList();
                              final focus = selectedDietaryFocus
                                  .map((index) => dietaryFocus[index])
                                  .toList();

                              userProfileController.saveChanges(
                                context: context,
                                selectedDietOptions: diet,
                                selectedDietaryFocus: focus,
                              );
                            },
                            child: const Text("Save Changes"),
                          ),
                        ),
                      ]
                  )
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                child: ElevatedButton.icon(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:  Color(0xFF960018),
                                side: BorderSide.none,
                              ),
                            ),
                          ],
                        );
                      }
                    );

                    if(confirmed == true){
                      await userProfileController.resetPreferences();

                      await loadUserData();

                      setState(() {
                        selectedDietOptions.clear();
                        selectedDietaryFocus.clear();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Meal preferences have been reset."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF960018),
                    // padding: EdgeInsets.symmetric(horizontal: 12),
                    side: BorderSide.none,
                  ),
                  label: const Text("Reset Meal Preferences"),
                  icon: const Icon(
                    Icons.delete,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwItems),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                child: ElevatedButton.icon(
                  onPressed: () async{
                    final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              "Are you sure you want to delete your account? "
                              "This cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context,false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context,true),
                                child: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:  Color(0xFF960018),
                                  side: BorderSide.none,
                                ),
                              ),
                            ],
                          );
                        }
                    );

                    if(confirmed == true){
                      final success = await userProfileController.deleteAccount();

                      if(success){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Your account has been deleted."),
                          ),
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false);
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to delete account."),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF960018),
                    // padding: EdgeInsets.symmetric(horizontal: 12),
                    side: BorderSide.none,
                  ),
                  label: const Text('Delete Account'),
                  icon: const Icon(
                    Icons.delete,
                    size: 22,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
