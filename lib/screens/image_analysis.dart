import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../data/repositories/image_analysis/image_analysis_repository.dart';
import '../utils/constants/sizes.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.put(ImageAnalysisRepository());

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: ElevatedButton(
                  onPressed: () => repo.generateText(),
                  child: const Text("Generate Text")
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            Obx((){
              if(repo.isLoading.value == true){
                return Text("Response is loading...");
              }else{
                return Text(repo.response.value);
              }
            })
          ]
        )
      )
    );
  }
}
