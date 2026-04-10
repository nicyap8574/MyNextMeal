import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../common/styles/spacing_styles.dart';
import '../data/repositories/image_analysis/image_analysis_repository.dart';
import '../utils/constants/sizes.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.put(ImageAnalysisRepository());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Analysis'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: ElevatedButton(
                    onPressed: () => repo.pickImage(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                    ),
                    child: const Text("Upload Image")
                ),
              ),
          
              const SizedBox(height: AppSizes.spaceBtwSections),
          
              Obx((){
                final imageFile = repo.foodImage.value;
          
                if(repo.isLoading.value != true && imageFile != null){
                  return Column(
                    children: [
                      Image.file(
                        imageFile,
                        height: 300,
                        fit: BoxFit.cover
                      ),
                    ],
                  );
                }else{
                  return const SizedBox.shrink();
                }
              }),
          
              const SizedBox(height: AppSizes.spaceBtwSections),
          
              Obx((){
                if(repo.isLoading.value == true){
                  return Text("Response is loading...");
                }else{
                  return Text(repo.response.value);
                }
              }),
            ]
          ),
        )
      )
    );
  }
}
