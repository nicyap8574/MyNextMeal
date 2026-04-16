import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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

    @override
    void dispose(){
      //dispose controller when widget is disposed
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Container();
    }
  }
}
