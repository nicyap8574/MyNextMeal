import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mynextmeal/features/controllers/camera_screen_controller.dart';

import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraScreenController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(CameraScreenController());
    controller.initCamera(widget.camera);
  }

  //TODO: Dispose camera
  @override
  void dispose(){
    //dispose controller when widget is disposed
    controller.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
        backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Take a picture'),
        ),
      body: FutureBuilder(
        future: controller.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
                children: [
                  SizedBox.expand(
                    child: CameraPreview(
                        controller.cameraController), //shows camera preview
                  ),

                  //Capture button
                  Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: () {
                          //TODO: Send captured image to image_analysis_controller
                          },
                          child: const Icon(Icons.camera),
                        ),
                      )
                  )
                ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    );
  }
}