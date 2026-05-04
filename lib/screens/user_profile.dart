import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/common/styles/spacing_styles.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';

import '../features/controllers/user_profile_controller.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late UserProfileController controller;

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

    controller = Get.put(UserProfileController());
    loadUserData();
  }

  //Show previously-selected diet and focus options (get from database)
  void loadUserData() async{
    final data = await controller.getSelectedPreferences();

    if(data != null){
      //extract only dietOptions and dietaryFocus from user's document database
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
    final controller = Get.find<UserProfileController>();

        return SingleChildScrollView(
            child: Padding(
              padding: AppSpacingStyle.paddingWithAppBarHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      child: Text(
                        'Dietary Goals',
                        style: TextStyle(
                          fontSize: AppSizes.fontSizeLg,
                          fontWeight: FontWeight.bold,
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

                        controller.saveChanges(
                          context: context,
                          selectedDietOptions: diet,
                          selectedDietaryFocus: focus,
                        );
                      },
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
        );
  }
}
