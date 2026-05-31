import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
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
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkerGrey.withOpacity(0.3),
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
                      backgroundColor: AppColors.apricotCream100,
                      side: BorderSide(color: Colors.transparent, width: 0),
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
                            child: SvgPicture.asset("assets/icons/add_photo_alternate_secondary.svg", height: 40)
                        ),
                        SizedBox(height: AppSizes.spaceBtwItems),
                        Text("Upload Image", style: TextStyle(color: AppColors.primary, fontSize: 20.0, fontWeight: FontWeight.w800)),
                      ],
                    ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkerGrey.withOpacity(0.3),
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
                      backgroundColor: AppColors.apricotCream100,
                    side: BorderSide(color: Colors.transparent, width: 0),
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
                          child: SvgPicture.asset("assets/icons/photo_camera_secondary.svg", height: 40)
                      ),
                      SizedBox(height: AppSizes.spaceBtwItems),
                      Text("Open Camera", style: TextStyle(color: AppColors.primary, fontSize: 20.0, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ]
          ),
        )
      )
    );
  }
}
