import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as devtools;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   final firstCamera = cameras.first;

//   runApp(MyApp(camera: firstCamera));
// }

// class MyApp extends StatelessWidget {
//   final CameraDescription camera;
//   const MyApp({super.key, required this.camera});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Poultry Disease Detection',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: HomePage(camera: camera),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final CameraDescription camera;
//   const HomePage({super.key, required this.camera});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CameraView(camera: camera),
//               ),
//             );
//           },
//           child: const Text('Proceed to Detection'),
//         ),
//       ),
//     );
//   }
// }

class CameraView extends StatefulWidget {
  final CameraDescription camera;
  const CameraView({super.key, required this.camera});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _tfLteInit();
    _initializeControllerFuture.then((_) {
      _controller.startImageStream((CameraImage img) {
        _runModelOnStreamFrames(img);
      });
    });
  }

  Future<void> _runModelOnStreamFrames(CameraImage img) async {
    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) => plane.bytes).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 0.0,
        imageStd: 255.0,
        rotation: 90,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );

      if (recognitions == null || recognitions.isEmpty) {
        devtools.log("No recognitions");
        return;
      }
      devtools.log("Recognitions: $recognitions");
      setState(() {
        confidence = (recognitions[0]['confidence'] * 100);
        label = recognitions[0]['label'].toString();
      });
    } catch (e) {
      devtools.log("Error running model on frame: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poultry Disease Detection'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.teal,
                  elevation: 20,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          Container(
                            height: 80,
                            width: 280,
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
