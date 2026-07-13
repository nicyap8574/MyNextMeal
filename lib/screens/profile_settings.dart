import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/auth/forgot_password_controller.dart';
import 'package:mynextmeal/screens/physical_metrics.dart';

import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'activity_level.dart';
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

  // Set<int> selectedDietOptions = {}; //stores selected diet options
  // Set<int> selectedDietaryFocus = {}; //stores selected dietary focus
  List<String> selectedDietOptions = []; //stores selected diet options
  List<String> selectedDietaryFocus = []; //stores selected dietary focus
  List<String> selectedRestrictions = [];
  List<String> selectedNutritionalGoals = []; //stores selected nutritional goals

  //collapsible sections
  bool _isDietaryGoalsExpanded = false;
  bool _isDietaryFocusExpanded = false;
  bool _isNutritionGoalsExpanded = false;
  bool _isDietaryRestrictionsExpanded = false;


  final TextEditingController usernameController = TextEditingController();
  final TextEditingController goalsController = TextEditingController();
  final TextEditingController focusController = TextEditingController();
  final TextEditingController restrictionController = TextEditingController();
  final TextEditingController nutritionController = TextEditingController();

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
    'Gain Weight',
    'Muscle Gain',
    'General Health'
  ];

  final List<String> nutritionalGoals = [
    'High protein',
    'Low carb',
    'Low fat',
    'High fiber',
    'Balanced diet',
    'Reduced sugar intake',
    'Reduce sodium'
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
    goalsController.dispose();
    focusController.dispose();
    restrictionController.dispose();
    nutritionController.dispose();
    super.dispose();
  }

  //Show previously-selected diet and focus options (get from database)
  Future<void> loadUserData() async{
    final data = await userProfileController.getUserDetails();

    if(data != null){

      final List<dynamic> diet = data['dietOptions'] ?? [];
      final List<dynamic> focus = data['dietaryFocus'] ?? [];
      final List<dynamic> goals = data['nutritionalGoals'] ?? [];
      final List<dynamic> restrictions = data['dietaryRestrictions'] ?? [];
      final String username = data['username'] ?? '';

      //pre-selects ChoiceChip
      setState((){
        usernameController.text = username; //populate textfield

        // selectedDietOptions = diet.map((item) => dietOptions
        //     .indexOf(item)) //converts String to index (read by ChoiceChip)
        //     .toSet(); //converts List to Set
        //
        // selectedDietaryFocus = focus.map((item) => dietaryFocus
        //     .indexOf(item))
        //     .toSet();

        selectedDietOptions = List<String>.from(diet);
        selectedDietaryFocus = List<String>.from(focus);
        selectedNutritionalGoals = List<String>.from(goals);
        selectedRestrictions = List<String>.from(restrictions);
      });
    }
  }
  void addCustomDietaryGoals(String input){
    final trimmedInput = input.trim();
    if(trimmedInput.isNotEmpty){
      setState(() {
        if(!selectedDietOptions.contains(trimmedInput)){
          selectedDietOptions.add(trimmedInput);
        }
        goalsController.clear();
      });
    }
  }

  void addCustomDietaryFocus(String input){
    final trimmedInput = input.trim();
    if(trimmedInput.isNotEmpty){
      setState(() {
        if(!selectedDietaryFocus.contains(trimmedInput)){
          selectedDietaryFocus.add(trimmedInput);
        }
        focusController.clear();
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

  void addCustomNutritionalGoals(String input){
    final trimmedInput = input.trim();
    if(trimmedInput.isNotEmpty){
      setState(() {
        if(!selectedNutritionalGoals.contains(trimmedInput)){
          selectedNutritionalGoals.add(trimmedInput);
        }
        nutritionController.clear();
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
                        InkWell(
                          onTap: () => setState(() => _isDietaryGoalsExpanded = !_isDietaryGoalsExpanded),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dietary Goals',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSizeLg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isDietaryGoalsExpanded ? Icons.expand_less : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if(_isDietaryGoalsExpanded) ...[
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
                            children: dietOptions.map((goals){
                              final isSelected = selectedDietOptions.contains(goals);

                              return ChoiceChip(
                                  label: Text(goals),
                                  selected: isSelected,
                                  onSelected: (bool selected){
                                    setState((){
                                      if (isSelected){
                                        selectedDietOptions.remove(goals);
                                      }else{
                                        selectedDietOptions.add(goals);
                                      }
                                    });
                                  }
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwSections-6),

                          //custom dietary goals
                          if(selectedDietOptions.any((g) => !dietOptions.contains(g))) ...[
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedDietOptions
                                  .where((g) => !dietOptions.contains(g))
                                  .map((goal){
                                return InputChip(
                                  label: Text(goal),
                                  onDeleted: (){
                                    setState(() {
                                      selectedDietOptions.remove(goal);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSizes.spaceBtwItems),
                          ],

                          //text field for typing custom dietary goals
                          Row(
                            children:[
                              Expanded(
                                child: TextField(
                                  controller: goalsController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type custom dietary goals',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onSubmitted: addCustomDietaryGoals,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                                onPressed: () => addCustomDietaryGoals(goalsController.text),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        InkWell(
                          onTap: () => setState(() => _isDietaryFocusExpanded = !_isDietaryFocusExpanded),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dietary Focus',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSizeLg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isDietaryFocusExpanded ? Icons.expand_less : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if(_isDietaryFocusExpanded) ...[
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
                            children: dietaryFocus.map((focus){
                              final isSelected = selectedDietaryFocus.contains(focus);

                              return ChoiceChip(
                                  label: Text(focus),
                                  selected: isSelected,
                                  onSelected: (bool selected){
                                    setState((){
                                      if (isSelected){
                                        selectedDietaryFocus.add(focus);
                                      }else{
                                        selectedDietaryFocus.remove(focus);
                                      }
                                    });
                                  }
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwSections-6),

                          //custom dietary focus
                          if(selectedDietaryFocus.any((f) => !dietaryFocus.contains(f))) ...[
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedDietaryFocus
                                  .where((f) => !dietaryFocus.contains(f))
                                  .map((focus){
                                return InputChip(
                                  label: Text(focus),
                                  onDeleted: (){
                                    setState(() {
                                      selectedDietaryFocus.remove(focus);
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
                                  controller: focusController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type custom dietary focus',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onSubmitted: addCustomDietaryFocus,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                                onPressed: () => addCustomDietaryFocus(focusController.text),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        InkWell(
                          onTap: () => setState(() => _isNutritionGoalsExpanded = !_isNutritionGoalsExpanded),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dietary Focus',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSizeLg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isNutritionGoalsExpanded ? Icons.expand_less : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if(_isNutritionGoalsExpanded) ...[
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
                            children: nutritionalGoals.map((goals){
                              final isSelected = selectedNutritionalGoals.contains(goals);
                              return ChoiceChip(
                                  label: Text(goals),
                                  selected: isSelected,
                                  onSelected: (bool selected){
                                    setState((){
                                      if (selected){
                                        selectedNutritionalGoals.add(goals);
                                      }else{
                                        selectedNutritionalGoals.remove(goals);
                                      }
                                    });
                                  }
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppSizes.spaceBtwSections-6),

                          //custom nutritional goals
                          if(selectedNutritionalGoals.any((n) => !nutritionalGoals.contains(n))) ...[
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedNutritionalGoals
                                  .where((n) => !nutritionalGoals.contains(n))
                                  .map((nutrition){
                                return InputChip(
                                  label: Text(nutrition),
                                  onDeleted: (){
                                    setState(() {
                                      selectedNutritionalGoals.remove(nutrition);
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
                                  controller: nutritionController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type custom nutritional goals',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onSubmitted: addCustomNutritionalGoals,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                                onPressed: () => addCustomNutritionalGoals(nutritionController.text),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        InkWell(
                          onTap: () => setState(() => _isDietaryRestrictionsExpanded = !_isDietaryRestrictionsExpanded),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dietary Restrictions',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSizeLg,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isDietaryRestrictionsExpanded ? Icons.expand_less : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if(_isDietaryRestrictionsExpanded) ...[

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

                          const SizedBox(height: AppSizes.spaceBtwSections-6),

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
                        ],

                        const SizedBox(height: AppSizes.spaceBtwSections),

                        //manage physical metrics
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => const PhysicalMetrics()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dark ? Colors.black : AppColors.apricotCream200,
                              foregroundColor: dark ? Colors.white : Colors.black,
                            ),
                            child: const Text("Edit Physical Metrics"),
                          ),
                        ),

                        const SizedBox(height: 8),

                        //manage activity levels button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => const ActivityLevel()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dark ? Colors.black : AppColors.apricotCream200,
                              foregroundColor: dark ? Colors.white : Colors.black,
                            ),
                            child: const Text("Manage Activity Level"),
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceBtwItems),

                        //save changes button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (){
                              userProfileController.saveChanges(
                                context: context,
                                username: usernameController.text.trim(),
                                selectedDietOptions: selectedDietOptions,
                                selectedDietaryFocus: selectedDietaryFocus,
                                selectedNutritionalGoals: selectedNutritionalGoals,
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

                child: Column(
                  children: [
                    ElevatedButton.icon(
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
                            selectedNutritionalGoals.clear();
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
                        backgroundColor: dark ? AppColors.apricotCream600 : AppColors.apricotCream700,
                        side: BorderSide.none,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      label: const Text("Reset Meal Preferences"),
                      icon: const Icon(
                        Icons.restart_alt,
                        size: 22,
                      ),
                    ),

                    SizedBox(height: AppSizes.spaceBtwItems),

                    ElevatedButton.icon(
                      onPressed: () async{
                        final user = FirebaseAuth.instance.currentUser;
                        if(user == null) return;

                        final providerId = user.providerData.first.providerId;

                        if(providerId == 'password'){
                          final passwordController = TextEditingController();
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              final hidePassword = true.obs;
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
                                    Obx(
                                      () => TextField(
                                        controller: passwordController,
                                        obscureText: hidePassword.value,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            onPressed: () => hidePassword.value = !hidePassword.value,
                                            icon: Icon(hidePassword.value ? Icons.visibility_off : Icons.visibility),
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
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
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide.none,
                      ),
                      label: const Text('Delete Account'),
                      icon: const Icon(
                        Icons.delete,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}