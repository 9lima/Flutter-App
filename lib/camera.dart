import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPicture extends StatefulWidget {
  const CameraPicture({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<CameraPicture> createState() => _CameraPictureState();
}

class _CameraPictureState extends State<CameraPicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
