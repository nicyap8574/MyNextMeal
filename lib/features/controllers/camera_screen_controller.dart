import 'package:camera/camera.dart';

class CameraScreenController{
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;

  Future<void> initCamera(CameraDescription camera) async{
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    initializeControllerFuture = cameraController.initialize();
  }

  Future<XFile> uploadCameraImage() async{
    return await cameraController.takePicture();
  }
}