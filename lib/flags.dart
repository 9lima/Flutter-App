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
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_application_1/bloc/repository.dart';

class Variables {
  static late SimpleKeyPair clientKeyPair;
  static late String clientPublicKeyBase64;
  static bool uploaded = false;
  static String randomString = '';
  static Uint8List imageAsBytes = Uint8List(0);
  static List<int>? myModifiableList;
  static Stream<List<int>>? streamImage;
  // static String? ownerId;
  static String? pubKey;
  // static String? jwt;
  static CameraController? cameraController;
  static Uint8List? webImage;
  static XFile? capturedImage;
  static bool showCamera = false;
  static int? statusCode;
  static CameraController? controller;
  static Future<Res>? futureKey;
  // static Future<void>? buildPreview;
  static bool camera = false;
  static double? height = Variables.controller?.value.previewSize!.height;

  //
  static final StreamController<XFile?> _imageStreamController =
      StreamController<XFile?>.broadcast();

  static Stream<XFile?> get imageStream => _imageStreamController.stream;

  static void updateImage(XFile? image) {
    _imageStreamController.add(image);
  }

  static void clearImage() {
    _imageStreamController.add(null);
  }

  //
  //
  static final StreamController<bool> _upButtonStream =
      StreamController<bool>.broadcast();
  static Stream<bool> get upButtonStream => _upButtonStream.stream;
  static void updateUpButton(bool State) {
    _upButtonStream.add(State);
  }

  //
  static String randomstr({int length = 7}) {
    const String chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#\$%&\'()*+,-./:;<=>?[\\]^_`{|}~ ';
    Random random = Random();

    final String result = String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    Variables.randomString = result;
    return result;
  }

  //
  static List<int> hkdfNonce = [];
  static List<int> generateHkdfNonce() {
    final random = Random.secure();
    hkdfNonce = <int>[];
    for (int i = 0; i < 16; i++) {
      hkdfNonce.add(random.nextInt(256));
    }
    Variables.hkdfNonce = hkdfNonce;
    return Variables.hkdfNonce;
  }
}

class Res {
  final String ownerId;
  final dynamic pubKey;
  final String jwt;

  const Res({required this.ownerId, required this.pubKey, required this.jwt});

  factory Res.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'owner_id': String ownerId,
        'pub_key': dynamic pubKey,
        'jwt': String jwt,
      } =>
        Res(ownerId: ownerId, pubKey: pubKey, jwt: jwt),
      _ => throw const FormatException('Failed to load Server Response.'),
    };
  }
}
