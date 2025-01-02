import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'dart:developer' as dev;

import '../../common_widgets/bounding_box_painter.dart';


class SearchObjectTab extends StatefulWidget {
  const SearchObjectTab({super.key});

  @override
  State<SearchObjectTab> createState() => _SearchObjectTabState();
}

class _SearchObjectTabState extends State<SearchObjectTab> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;

  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;

  CameraImage? cameraImage;

  bool isLoaded = false;
  bool isDetecting = false;

  // ** Funciones para la camara e imagenes
  init() async {
    _cameras = await availableCameras();
    vision = FlutterVision();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: false);
    await _cameraController.initialize();
    await loadYoloModel();
    setState(() {
      isLoaded = true;
      isDetecting = false;
      yoloResults = [];
    });
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    vision = FlutterVision();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
      //setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        dev.log(" * ERROR al iniciar camara: $e");
      }
    });
  }


  // ** Funciones para reconocimiento del modelo
  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/models/objetos_giuseppe.txt',
        modelPath: 'assets/models/objetos_giuseppe.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 1,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (_cameraController.value.isStreamingImages) return;

    await _cameraController.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.5,
        confThreshold: 0.5,
        classThreshold: 0.6);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
        dev.log("** RESULTADOS: ");
        dev.log(" - $result");
      });
    }
  }


  // * Estados de la APP
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() async {
    _cameraController.dispose();
    await vision.closeYoloModel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    final imageWidth = cameraImage?.width.toDouble() ?? 1.0; // Usar el ancho de la imagen de la cámara
    final imageHeight = cameraImage?.height.toDouble() ?? 1.0; // Usar el alto de la imagen de la cámara
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
          if (isDetecting && yoloResults.isNotEmpty)
            CustomPaint(
              size: Size.infinite,
              painter: BoundingBoxPainter(
                yoloResults,
                imageWidth,
                imageHeight,
                screenWidth,
                screenHeight,
              ),
            ),
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 5, color: Colors.white, style: BorderStyle.solid),
              ),
              child: isDetecting
                  ? IconButton(
                onPressed: stopDetection,
                icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                iconSize: 50,
              )
                  : IconButton(
                onPressed: startDetection,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                iconSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
