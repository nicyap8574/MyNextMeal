import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../common/styles/spacing_styles.dart';
import '../features/controllers/forgot_password_controller.dart';
import '../utils/constants/sizes.dart';
import '../utils/validator/validator.dart';

class ForgotPasswordSheet extends StatelessWidget {
  const ForgotPasswordSheet({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Padding(
      padding: AppSpacingStyle.paddingWithAppBarHeight,
      child: Form(
        key: controller.forgotPasswordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections/2),

            Text(
              "We'll send you a link to the email address to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),


            TextFormField(
              controller: controller.email,
              autofocus: true,
              validator: (value) => AppValidator.validateEmail(value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email Address"
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.sendPasswordResetEmail(),
                child: const Text("Send reset link")
              ),
            ),
          ],
        ),
      )
    );
  }
}
