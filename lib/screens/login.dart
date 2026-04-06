import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mynextmeal/common/styles/spacing_styles.dart';
import 'package:mynextmeal/screens/signup.dart';
import 'package:mynextmeal/utils/helpers/helper_functions.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/image_strings.dart';
import '../utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,

        body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              //Logo, Title, and sub title
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    height: 150,
                    image: AssetImage(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo),
                  ),

                  const SizedBox(height: AppSizes.sm),

                  Text(
                    'Welcome to MyNextMeal',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              //Form
              Form(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
                child: Column(
                  children:[

                    //Email
                    TextFormField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                        labelText: "Email Address"
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwInputFields),

                    //Password
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          suffixIcon: Icon(Icons.visibility_off),
                      ),
                    ),

                    const SizedBox(height: AppSizes.sm),


                    //Remember me and forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        //remember me
                        Row(
                          children:[
                            SizedBox(width: 24, height: 24, child: Checkbox(value: true, onChanged: (value){})),
                            const Text("Remember Me"),
                          ],
                        ),

                        //forgot password
                        TextButton(
                          onPressed: (){},
                          child: const Text("Forgot Password?"),
                        )
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    //sign in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: (){}, child: const Text("Sign In")),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwInputFields),


                    //create account button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(onPressed: () => Get.to(() => const SignUpScreen()), child: const Text("Create Account")),
                    ),


                    const SizedBox(height: AppSizes.spaceBtwSections),


                  ],
                ),
              ),
              ),

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
          )
        ),
      ),
    );
  }
}