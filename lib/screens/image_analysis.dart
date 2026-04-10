import 'package:flutter/material.dart';

import '../data/repositories/image_analysis/image_analysis_repository.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: ElevatedButton(onPressed: (){}, child: const Text("Upload Image")),
            ),

            Text(ImageAnalysisRepository.response)
          ]
        )
      )
    );
  }
}
