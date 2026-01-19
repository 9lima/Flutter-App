import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// late List<CameraDescription> cameras;
// late CameraController _controller;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CameraPage());
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // VARIABLES
  CameraController? _controller;
  Uint8List? _webImage;
  XFile? _capturedImage;
  bool _showCamera = false;
  int? _statusCode;

  // Take from Camera
  Future<void> _openCamera() async {
    try {
      _controller = null;
      _capturedImage = null;
      _webImage = null;
      _showCamera = true;

      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _showCamera = true;
      });
    } on CameraException catch (e) {
      debugPrint("Camera error: ${e.description}");
    }
  }

  Future<void> _takePicture() async {
    final dynamic image = await _controller!.takePicture();

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
        _showCamera = false;
      });
    } else {
      setState(() {
        _capturedImage = image;
        _showCamera = false;
      });
    }
  }

  // Take From Gallery
  Future _openGallery() async {
    _controller = null;
    _capturedImage = null;
    _webImage = null;

    final dynamic image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: null,
      requestFullMetadata: false,
    );

    if (image == null) return;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
        _showCamera = false;
      });
    } else {
      setState(() {
        _capturedImage = image;
        _showCamera = false;
      });
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: const Text(
            'Flutter App',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// GALLERY BUTTON
                    ElevatedButton(
                      onPressed: _openGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Gallery",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// CAMERA BUTTON
                    ElevatedButton(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Camera",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (_capturedImage != null || _webImage != null)
                      ElevatedButton(
                        onPressed: () {
                          {}
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: _statusCode == 200
                            ? const Text(
                                "Done!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Upload",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                /// CAMERA PREVIEW
                if (_showCamera && _controller != null)
                  Stack(
                    children: [
                      CameraPreview(_controller!),

                      /// TAKE BUTTON
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _takePicture,
                          child: const Text(
                            "Take",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),

                /// CAPTURED IMAGE
                if (_capturedImage != null)
                  Image.file(File(_capturedImage!.path), fit: BoxFit.cover)
                else if (kIsWeb && _webImage != null)
                  Image.memory(_webImage!)
                else if (_capturedImage == null &&
                    _webImage == null &&
                    _showCamera == false)
                  const SizedBox(height: 200, child: Text('select the image')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //   Future<Post> _upload(String imageFile) async {
  //     try {
  //       _controller?.dispose();
  //       super.dispose();
  //       var req = http.MultipartRequest(
  //         "POST",
  //         Uri.parse('http://10.0.2.2:5000'),
  //       );
  //       req.files.add(await http.MultipartFile.fromPath('image', imageFile.path),contentType: MediaType('image', 'jpeg'));
  //       response = await req.send();

  //       setState(() {
  //         // _responseData = response.body;
  //         _statusCode = response.statusCode;
  //       });
  //     } catch (e) {
  //       return;
  //     }
  //   }
  // }
}

class Post {
  final Map<String, dynamic> response;

  Post({required this.response});

  factory Post.fromStatus(Map<String, dynamic> json) {
    return Post(response: json['status'] as Map<String, dynamic>);
  }

  factory Post.fromMessage(Map<String, dynamic> json) {
    return Post(response: json['message'] as Map<String, dynamic>);
  }
}
