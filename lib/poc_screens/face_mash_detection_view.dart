import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';

import '../widgets/face_mesh_detection_painter.dart';

class FaceMeshDetectionView extends StatefulWidget {
  const FaceMeshDetectionView({super.key});

  @override
  State<FaceMeshDetectionView> createState() => _FaceMeshDetectionViewState();
}

class _FaceMeshDetectionViewState extends State<FaceMeshDetectionView> {
  // To handle scanning process.
  bool _canProcess = false;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _faceMeshDetectionPainter;

  // Used to interpret images.
  final _faceMeshDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onImageReceived: _processImage,
        customPainter: CustomPaint(
          painter: _faceMeshDetectionPainter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the image label detector and release its resources.
    _faceMeshDetector.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final result = await _faceMeshDetector.processImage(image);

    // To remove the previous drawing.
    if (result.isEmpty || image.metadata == null) {
      _faceMeshDetectionPainter = null;
    } else {
      _faceMeshDetectionPainter = FaceMashDetectionPainter(
        faceMeshes: result,
        imageSize: image.metadata!.size,
        rotation: image.metadata!.rotation,
      );
    }

    setState(() {});

    // Re-enable the processing.
    _isBusy = false;
  }
}
