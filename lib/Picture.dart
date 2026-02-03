import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_application_1/encrypt.dart';
import 'package:flutter_application_1/Picture.dart';
import 'package:flutter_application_1/flags.dart';
import 'dart:typed_data';

Future<void> openCamera() async {
  try {
    // Variables.controller = null;
    Variables.controller?.dispose();
    Variables.clearImage();

    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    Variables.controller = CameraController(
      backCamera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await Variables.controller!.initialize();
    Variables.camera = true;
  } on CameraException catch (e) {
    debugPrint("Camera error: ${e.description}");
  }
}

Future takePicture() async {
  if (!Variables.controller!.value.isInitialized) {
    await Variables.controller!.initialize();
  }
  final image = await Variables.controller!.takePicture();
  Variables.capturedImage = image;
  Variables.updateUpButton(true);

  if (Variables.capturedImage == null) return;
  Variables.imageAsBytes = await Variables.capturedImage!.readAsBytes();
  Variables.controller?.dispose();

  return Variables.capturedImage;
}

// Take From Gallery
Future openGallery() async {
  Variables.controller?.dispose();
  Variables.clearImage();

  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: null,
    requestFullMetadata: false,
  );
  if (image == null && Variables.capturedImage != null) {
    return Variables.capturedImage!;
  }
  if (image == null) return;
  Variables.capturedImage = image;
  Variables.updateUpButton(true);
  Variables.streamImage = Stream<List<int>>.fromFuture(
    Variables.capturedImage!.readAsBytes().then((b) => b.toList()),
  );

  if (kIsWeb && Variables.capturedImage != null) {
    Variables.imageAsBytes = await Variables.capturedImage!.readAsBytes();
  }

  return Variables.capturedImage!;
}
