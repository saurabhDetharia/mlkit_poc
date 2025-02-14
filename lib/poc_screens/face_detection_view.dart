import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';
import 'package:ml_kit_poc/widgets/face_point_painter.dart';

class FaceDetectionView extends StatefulWidget {
  const FaceDetectionView({super.key});

  @override
  State<FaceDetectionView> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // To draw paths of the face.
  List<Offset> points = [];
  Rect? rectPoints;

  FaceOutlinePainter? _faceOutlinePainter;

  // Handles image processing to get face detection from it.
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraView(
            onImageReceived: _onImageReceived,
            customPainter: CustomPaint(
              painter: _faceOutlinePainter,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the face detector and release its resources.
    _faceDetector.close();
    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _onImageReceived(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    final result = await _faceDetector.processImage(image);
    if (result.isNotEmpty) {
      _faceOutlinePainter = FaceOutlinePainter(
        faces: result,
        imageSize: image.metadata!.size,
        rotation: image.metadata!.rotation,
      );
      if (!mounted) return;
      setState(() {});
    } else {
      _faceOutlinePainter = null;
      if (!mounted) return;
      setState(() {});
    }

    _isBusy = false;
  }
}
