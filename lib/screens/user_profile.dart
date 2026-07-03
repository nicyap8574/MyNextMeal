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

    controller = Get.find<UserProfileController>();
    loadUserData();
  }

  //Show previously-selected diet and focus options (get from database)
  void loadUserData() async{
    final data = await controller.getUserDetails();

    if(data?['id'] != ''){
      setState((){
        //extract from user's document database
        email = data?['email'] ?? "No email set";
        id = data?['id'] ?? "No ID set";
        username = data?['username'] ?? "No username set";
      });
    }

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

                  // SizedBox(height: AppSizes.spaceBtwItems),

                  Text(id),

                  SizedBox(height: AppSizes.spaceBtwSections),

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
