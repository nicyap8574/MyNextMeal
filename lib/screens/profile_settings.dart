import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/auth/forgot_password_controller.dart';

import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'forgot_password_sheet.dart';
import 'login.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  late UserProfileController userProfileController;
  final forgotPasswordController = Get.find<ForgotPasswordController>();

  Set<int> selectedDietOptions = {}; //stores selected diet options
  Set<int> selectedDietaryFocus = {}; //stores selected dietary focus
  List<String> selectedRestrictions = [];


  final TextEditingController usernameController = TextEditingController();
  final TextEditingController restrictionController = TextEditingController();

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

  final List<String> dietaryRestrictions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Soy',
    'Seafood',
    'Eggs',
  ];

  @override
  void initState(){
    super.initState();

    userProfileController = Get.find<UserProfileController>();
    loadUserData();
  }

  @override
  void dispose(){
    usernameController.dispose();
    restrictionController.dispose();
    super.dispose();
  }

  //Show previously-selected diet and focus options (get from database)
  Future<void> loadUserData() async{
    final data = await userProfileController.getUserDetails();

    if(data != null){

      final List<dynamic> diet = data['dietOptions'] ?? [];
      final List<dynamic> focus = data['dietaryFocus'] ?? [];
      final List<dynamic> restrictions = data['dietaryRestrictions'] ?? [];
      final String username = data['username'] ?? '';

      //pre-selects ChoiceChip
      setState((){
        usernameController.text = username; //populate textfield

        selectedDietOptions = diet.map((item) => dietOptions
            .indexOf(item)) //converts String to index (read by ChoiceChip)
            .toSet(); //converts List to Set

        selectedDietaryFocus = focus.map((item) => dietaryFocus
            .indexOf(item))
            .toSet();

        selectedRestrictions = List<String>.from(restrictions);
      });
    }
  }

  void addCustomRestriction(String rawRestriction){
    final trimmedRestriction = rawRestriction.trim();
    if(trimmedRestriction.isNotEmpty){
      setState(() {
        if(!selectedRestrictions.contains(trimmedRestriction)){
          selectedRestrictions.add(trimmedRestriction);
        }
        restrictionController.clear();
      });
    }
  }


@override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final user = FirebaseAuth.instance.currentUser;
    final isPasswordUser = user?.providerData.any((p) => p.providerId == 'password') ?? false;

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
              Text(
                'Username',
                style: TextStyle(
                  fontSize: AppSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              if(isPasswordUser) ...[
                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: (){
                      Get.bottomSheet(
                          ForgotPasswordSheet(email: ''),
                          backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          )
                      );
                    },
                    child: const Text("Reset Password via Email"),
                  ),
                ),
              ]else ...[
                const Text(
                  'Account Security',
                  style: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                    "Signed in with Google. Manage your password in your Google account.",
                    style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.darkerGrey)
                ),
              ],

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: dark ? Color(0xFF221E19) : AppColors.apricotCream100,
                    border: Border.all(
                        color: dark ? Colors.white.withOpacity(0.08) : Colors.transparent,
                        width: 0
                    ),
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

                        Container(
                          child: Text(
                            'Dietary Restrictions',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          child: Text(
                            'Allergies and ingredients to avoid in recommendations.',
                            style: TextStyle(
                              fontSize: AppSizes.fontSizeSm-1,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: dietaryRestrictions.map((restriction){
                              final isSelected = selectedRestrictions.contains(restriction);
                              return ChoiceChip(
                                  label: Text(restriction),
                                  selected: isSelected,
                                  onSelected: (bool selected){
                                    setState(() {
                                      if(selected){
                                        selectedRestrictions.add(restriction);
                                      }else{
                                        selectedRestrictions.remove(restriction);
                                      }
                                    });
                                  });
                            }).toList(),
                        ),

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        //custom restrictions
                        if(selectedRestrictions.any((r) => !dietaryRestrictions.contains(r))) ...[
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: selectedRestrictions
                              .where((r) => !dietaryRestrictions.contains(r))
                              .map((restriction){
                                return InputChip(
                                  label: Text(restriction),
                                  onDeleted: (){
                                    setState(() {
                                      selectedRestrictions.remove(restriction);
                                    });
                                  },
                                );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSizes.spaceBtwItems),
                        ],

                        //text field for typing custom restrictions
                        Row(
                          children:[
                            Expanded(
                              child: TextField(
                                controller: restrictionController,
                                decoration: const InputDecoration(
                                  hintText: 'Type custom restriction',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                onSubmitted: addCustomRestriction,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                              onPressed: () => addCustomRestriction(restrictionController.text),
                            ),
                          ],
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
                                username: usernameController.text.trim(),
                                selectedDietOptions: diet,
                                selectedDietaryFocus: focus,
                                selectedRestrictions: selectedRestrictions,
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

                      setState(() {
                        selectedDietOptions.clear();
                        selectedDietaryFocus.clear();
                        selectedRestrictions.clear();
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


              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                child: ElevatedButton.icon(
                  onPressed: () async{
                    final user = FirebaseAuth.instance.currentUser;
                    if(user == null) return;

                    final providerId = user.providerData.first.providerId;

                    if(providerId == 'password'){
                      final passwordController = TextEditingController();
                      final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Account'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  const Text(
                                    'Are you sure you want to delete your account? '
                                    'This cannot be undone. Please enter your password to confirm.',
                                  ),
                                  const SizedBox(height: AppSizes.spaceBtwItems),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
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
                          },
                      );
                      if(confirmed == true && passwordController.text.isNotEmpty){

                        //loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        final success = await userProfileController.deleteAccount(password: passwordController.text.trim());

                        Navigator.pop(context);

                        if(success){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Your account has been deleted."),
                            ),
                          );
                          Get.offAll(() => const LoginScreen());
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to delete account."),
                            ),
                          );
                        }
                      }
                    }else{
                      //Google Sign In
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
                        },
                      );
                      if(confirmed == true){

                        //loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        final success = await userProfileController.deleteAccount();

                        Navigator.pop(context);

                        if(success){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Your account has been deleted."),
                            ),
                          );
                          Get.offAll(() => const LoginScreen());
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to delete account."),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF960018),
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
