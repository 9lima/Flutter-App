import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
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
import 'package:flutter_application_1/bloc/repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CameraPage());
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final cameraCubit = CameraCubit();
  Future<void>? buildPreview;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Run immediately on app start

    // fetchKey(Variables.randomstr(), Variables.generateHkdfNonce()).then((res) {
    //   Variables.pubKey = res.pubKey;
    //   print(res.pubKey);
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
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
                      onPressed: () {
                        openGallery().then((image) {
                          Variables.updateImage(image);
                        });
                      },
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
                      onPressed: () {
                        setState(() {
                          buildPreview = openCamera(); // Re-trigger the future
                        });
                      },
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
                    StreamBuilder<bool>(
                      stream: Variables.upButtonStream,
                      builder: (context, snapshot) {
                        // Case 1: stream says "Upload"
                        if (snapshot.hasData && snapshot.data == true) {
                          return ElevatedButton(
                            onPressed: () async {
                              await encrypt(
                                serverPubKeyString: Variables.pubKey!,
                                stream: Variables.imageAsBytes,
                                hkdfNonce: Variables.hkdfNonce,
                                clientKeyPair: Variables.clientKeyPair,
                              ).then((body) async {
                                await postdata(body);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Upload",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        // Case 2: image exists → show "Done"
                        else if (Variables.capturedImage != null) {
                          return ElevatedButton(
                            onPressed: () async {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        // Case 3: show nothing (no empty space)
                        else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
                BlocBuilder<CameraCubit, CameraState>(
                  bloc: cameraCubit,
                  builder: (context, state) {
                    if (state is CameraInitial) {
                      return ElevatedButton(
                        onPressed: () => cameraCubit.openCamera(),
                        child: const Text("Camera"),
                      );
                    }

                    if (state is CameraPreviewState) {
                      return Column(
                        children: [
                          Expanded(
                            child: CameraPreview(cameraCubit.controller!),
                          ),
                          ElevatedButton(
                            onPressed: () => cameraCubit.captureImage(),
                            child: const Text("Capture"),
                          ),
                        ],
                      );
                    }

                    if (state is CameraCapturedState) {
                      return Column(
                        children: [
                          Image.file(File(state.image.path)),
                          ElevatedButton(
                            onPressed: () => cameraCubit.closeCamera(),
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    }

                    if (state is CameraErrorState) {
                      return Center(child: Text("Error: ${state.message}"));
                    }

                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 10),

                /// CAMERA PREVIEW
                FutureBuilder<void>(
                  future: buildPreview,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      // If the Future is complete, display the preview.

                      return Stack(
                        children: [
                          CameraPreview(Variables.controller!),
                          Center(
                            child: Positioned(
                              left: 0,
                              right: 0,
                              bottom: 220,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  setState(() {
                                    Variables.controller?.dispose();
                                  });
                                  takePicture().then((image) {
                                    Variables.updateImage(image);
                                  });
                                },
                                child: const Icon(Icons.camera_alt),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
