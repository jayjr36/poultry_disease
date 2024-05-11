// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart' as picker;

void main() {
  runApp(const MyApp());
}

const String ssd = "SSD MobileNet";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TfliteHome(),
    );
  }
}

class TfliteHome extends StatefulWidget {
  const TfliteHome({super.key});

  @override
  TfliteHomeState createState() => TfliteHomeState();
}

class TfliteHomeState extends State<TfliteHome> {
 // final ImagePicker picker = ImagePicker();
  File? _image;

   double _imageHeight = 0.0;
  bool _busy = false;

   List _recognitions = [];

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadModel() async {
  try {
    var interpreter = await Interpreter.fromAsset('assets/model.tflite');
    interpreter.allocateTensors();
    print("Model loaded successfully");
  } catch (e) {
    print("Failed to load the model: $e");
  }
}


selectFromImagePicker() async {
  picker.XFile? xImage = await picker.ImagePicker().pickImage(source: picker.ImageSource.gallery);
  if (xImage == null) return;
  File image = File(xImage.path); // Convert XFile to File
  setState(() {
    _busy = true;
  });
  predictImage(image);
}

  captureFromCamera() async {
    var image = await picker.ImagePicker().pickImage(source: picker.ImageSource.camera);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image as File);
  }


predictImage(File image) async {
  Uint8List bytes = await image.readAsBytes(); // Read image file as bytes
  await ssdMobileNet(bytes);

  var imageHeight = 0.0;
  FileImage(image)
    .resolve(const ImageConfiguration())
    .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        imageHeight = info.image.height.toDouble();
      });
    })));

  setState(() {
    _image = image;
    _imageHeight = imageHeight; // Assign imageHeight to _imageHeight
    _busy = false;
  });
}

ssdMobileNet(Uint8List image) async {
  try {
    var interpreter = await Interpreter.fromAsset('assets/model.tflite');
    var inputShape = interpreter.getInputTensor(0).shape;
    var outputShape = interpreter.getOutputTensor(0).shape;

    var input = image.buffer.asUint8List();

    interpreter.run(input, outputShape);

    var output = interpreter.getOutputTensors();
    // Process the output tensor as needed
    
    interpreter.close();
  } catch (e) {
    print("Error running inference: $e");
  }
}


  List<Widget> renderBoxes(Size screen) {
    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    Color blue = Colors.red;

    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: ((re["confidenceInClass"] > 0.50))
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: blue,
                    width: 3,
                  ),
                ),
                child: Text(
                  "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    background: Paint()..color = blue,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              )
            : Container(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? const Text("No Image Selected") : Image.file(_image!),
    ));

    stackChildren.addAll(renderBoxes(size));

    if (_busy) {
      stackChildren.add(const Center(
        child: CircularProgressIndicator(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detection"),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.red,
            tooltip: "Capture Image from Camera",
            onPressed: captureFromCamera,
            child: const Icon(Icons.camera),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.red,
            tooltip: "Pick Image from Gallery",
            onPressed: selectFromImagePicker,
            child: const Icon(Icons.image),
          ),
        ],
      ),
      body: Stack(
        children: stackChildren,
      ),
    );
  }
}
