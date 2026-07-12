import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
import 'package:mynextmeal/screens/text_input.dart';
import '../common/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'camera_screen.dart';
import 'food_analysis_results.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(ImageAnalysisController());

    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Meal Analysis'),
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.transparent : AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0,4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                    onPressed: () async{

                      final imageChosen = await controller.pickImage();

                      if(!imageChosen){
                        return;
                      }

                      Get.to(() => const FoodAnalysisResults());
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ?  const Color(0xFF221E19) : AppColors.apricotCream100,
                      side: BorderSide(color: dark ? Colors.white.withOpacity(0.08) : AppColors.primary, width: 1),
                      elevation: 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primary,
                            ),
                          child: Icon(
                              Icons.add_photo_alternate,
                              size: 40.0
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceBtwItems),
                        Text("Upload Image", style: TextStyle(color: AppColors.primary, fontSize: 20.0, fontWeight: FontWeight.w800)),
                      ],
                    ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.transparent : AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0,4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final cameras = await availableCameras();
                    final firstCamera = cameras.first;
                    Get.to(() => CameraScreen(camera: firstCamera));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ?  const Color(0xFF221E19) : AppColors.apricotCream100,
                    side: BorderSide(color: dark ? Colors.white.withOpacity(0.08) : AppColors.primary, width: 1),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            Icons.photo_camera,
                            size: 40.0
                          ),
                      ),
                      SizedBox(height: AppSizes.spaceBtwItems),
                      Text("Open Camera", style: TextStyle(color: AppColors.primary, fontSize: 20.0, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.transparent : AppColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0,4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async{
                    Get.to(() => const TextInput());
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ?  const Color(0xFF221E19) : AppColors.apricotCream100,
                    side: BorderSide(color: dark ? Colors.white.withOpacity(0.08) : AppColors.primary, width: 1),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            Icons.keyboard,
                            size: 40.0,
                          ),
                      ),
                      SizedBox(height: AppSizes.spaceBtwItems),
                      Text("Text Input", style: TextStyle(color: AppColors.primary, fontSize: 20.0, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical:15, horizontal:10),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF221E19) : AppColors.white,
                  border: Border.all(
                      color: dark ? Colors.white.withOpacity(0.08) : AppColors.apricotCream100,
                      width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for best results',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: AppSizes.sm),

                    Text(
                      '• Center the dish and fill the frame',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: AppSizes.sm),

                    Text(
                      '• Use good lighting and avoid heavy shadows',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: AppSizes.sm),

                    Text(
                      '• Review and correct AI results before saving',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
              ),
            ]
          ),
        )
      )
    );
  }
}
