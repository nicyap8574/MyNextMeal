import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {

    late CameraController _controller;
    late Future<void> _initializeControllerFuture;

    @override
    void initState(){
      super.initState();
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();
    }
  }
}
