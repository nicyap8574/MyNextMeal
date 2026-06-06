import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/common/widgets/camera_framing_overlay.dart';
import 'package:mynextmeal/screens/food_analysis_results.dart';
import '../features/meals/camera_screen_controller.dart';
import '../features/meals/image_analysis_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/popups/loaders.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraScreenController controller;
  late ImageAnalysisController imageAnalysisController;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CameraScreenController());
    imageAnalysisController = Get.put(ImageAnalysisController());
    controller.initCamera(widget.camera);
  }

  @override
  void dispose() {
    controller.cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final capturedImage = await controller.uploadCameraImage();
      final analysisController = Get.find<ImageAnalysisController>();
      analysisController.foodImage.value = capturedImage;
      analysisController.analyseFoodImage(capturedImage);
      Get.to(() => const FoodAnalysisResults());
    } catch (e) {
      if (mounted) {
        AppLoaders.showSnackBar(
          context,
          'An error has occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        title: const Text('Capture meal'),
      ),
      body: FutureBuilder(
        future: controller.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller.cameraController),
              const CameraFramingOverlay(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.xl,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tap to capture',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: AppSizes.fontSizeSm,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      GestureDetector(
                        onTap: _isCapturing ? null : _captureImage,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 4,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isCapturing
                                    ? AppColors.grey
                                    : AppColors.primary,
                              ),
                              child: _isCapturing
                                  ? const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/photo_camera_secondary.svg',
                                        height: 28,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
