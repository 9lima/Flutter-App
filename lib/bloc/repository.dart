import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CameraStatus { off, preview, captured }

enum UploadButtonStatus { hide, show, done }

enum CapturedImage { none, picked }

class CameraStatusCubit extends Cubit<CameraStatus> {
  CameraStatusCubit() : super(CameraStatus.off);

  void setCameraStatus(CameraStatus status) => emit(status);
}

class UploadButtonStatusCubit extends Cubit<UploadButtonStatus> {
  UploadButtonStatusCubit() : super(UploadButtonStatus.hide);

  void setUploadButtonStatus(UploadButtonStatus status) => emit(status);
}

class CapturedImageCubit extends Cubit<CapturedImage> {
  CapturedImageCubit() : super(CapturedImage.none);

  void setCapturedImage(CapturedImage status) => emit(status);
}
// /////////////////////////////////////////////

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraPreviewState extends CameraState {}

class CameraCapturedState extends CameraState {
  final XFile image;
  CameraCapturedState(this.image);
}

class CameraErrorState extends CameraState {
  final String message;
  CameraErrorState(this.message);
}

class CameraCubit extends Cubit<CameraState> {
  CameraController? controller;

  CameraCubit() : super(CameraInitial());

  // Open Camera Preview
  Future<void> openCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller!.initialize();
      emit(CameraPreviewState());
    } catch (e) {
      emit(CameraErrorState("Failed to capture image: $e"));
    }
  }

  Future<void> captureImage() async {
    if (controller == null) return;
    try {
      final image = await controller!.takePicture();
      emit(CameraCapturedState(image));
    } catch (e) {
      emit(CameraErrorState("Failed to capture image: $e"));
    }
  }

  Future<void> closeCamera() async {
    try {
      await controller?.dispose();
      controller = null;
      emit(CameraInitial());
    } catch (e) {
      emit(CameraErrorState("Failed to close camera: $e"));
    }
  }
}
