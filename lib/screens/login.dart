import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mynextmeal/common/styles/spacing_styles.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/image_strings.dart';
import '../utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celadon700,
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              //Logo, Title, and sub title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    height: 150,
                    image: AssetImage(AppImages.AppLogo),
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
                            Checkbox(value: false, onChanged: (value){}),
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

                    //create account button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(onPressed: (){}, child: const Text("Create Account")),
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
                  Divider(color: AppColors.darkerGrey, thickness: 0.5),
                ],
              )

            ],
          )
        ),
      ),
    );
  }
}