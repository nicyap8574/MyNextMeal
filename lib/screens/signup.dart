import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/screens/login.dart';
import 'package:mynextmeal/utils/validator/validator.dart';
import '../features/controllers/signup_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/image_strings.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/popups/loaders.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              //Title
              Text("Sign Up", style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium),

              const SizedBox(height: AppSizes.spaceBtwSections),

              //Sign up Form
              Form(
                key: controller.signupFormKey,
                child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
                child: Column(
                children: [

                  //Username
                  TextFormField(
                    controller: controller.username,
                    validator: (value) => AppValidator.validateUsername(value),
                    decoration: const InputDecoration(
                        labelText: "Username",
                        prefixIcon: Icon(Icons.person)
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwInputFields),

                  //Email
                  TextFormField(
                    controller: controller.email,
                    validator: (value) => AppValidator.validateEmail(value),
                    decoration: const InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(Icons.email)
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwInputFields),

                  //Password (observer)
                  Obx(
                    () => TextFormField(
                      controller: controller.password,
                      obscureText: controller.hidePassword.value,
                      validator: (value) => AppValidator.validateSignUpPassword(value),
                      decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                              icon: Icon(controller.hidePassword.value ? Icons.visibility_off : Icons.visibility                              ),
                          ),
                      ),
                    ),
                  ),


                  const SizedBox(height: AppSizes.spaceBtwInputFields),

                  //Password confirmation
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPassword,
                      obscureText: controller.hidePassword.value,
                      validator: (value) => AppValidator.validateSignUpPassword(value),
                      decoration: InputDecoration(
                        labelText: "Re-enter Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                          icon: Icon(controller.hidePassword.value ? Icons.visibility_off : Icons.visibility                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  //create account button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (){
                          controller.signup(context: context);
                          AppLoaders.showSnackBar(context,"User created successfully");
                        },
                        child: const Text("Create Account"),),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwInputFields),

                  //back to sign in
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: () => Get.to(() => const LoginScreen()), child: const Text("I already have an account")),
                  ),


                  const SizedBox(height: AppSizes.spaceBtwSections),

                  //Divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Divider(color: dark ? AppColors.darkGrey : AppColors.grey, thickness: 0.5, indent: 60, endIndent: 5)),
                      Text("Or Sign In With", style: Theme.of(context).textTheme.labelMedium),
                      Flexible(child: Divider(color: dark ? AppColors.darkGrey : AppColors.grey, thickness: 0.5, indent: 5, endIndent: 60)),
                    ],
                  ),



                  const SizedBox(height: AppSizes.spaceBtwItems),


                  //Footer
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Container(
                            decoration: BoxDecoration(border: Border.all(color: AppColors.grey), borderRadius: BorderRadius.circular(100)),
                            child: IconButton(
                              onPressed: (){},
                              icon: const Image(
                                width: AppSizes.iconMd,
                                height: AppSizes.iconMd,
                                image: AssetImage(AppImages.googleLogo),
                              ),

                            )
                        )
                      ]
                  )
                ],
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