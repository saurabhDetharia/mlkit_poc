import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';
import 'package:ml_kit_poc/widgets/pose_detection_painter.dart';

class PoseDetectionView extends StatefulWidget {
  const PoseDetectionView({super.key});

  @override
  State<PoseDetectionView> createState() => _PoseDetectionViewState();
}

class _PoseDetectionViewState extends State<PoseDetectionView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _poseDetectionPainter;

  // To process image to detect Pose
  final _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onImageReceived: _processImage,
        customPainter: CustomPaint(
          painter: _poseDetectionPainter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the pose detector and release its resources.
    _poseDetector.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final result = await _poseDetector.processImage(image);

    if (result.isNotEmpty && image.metadata != null) {
      _poseDetectionPainter = PoseDetectionPainter(
        poses: result,
        rotation: image.metadata!.rotation,
        imageSize: image.metadata!.size,
      );
    } else {
      _poseDetectionPainter = null;
    }

    // To update the result view.
    if (!mounted) return;
    setState(() {});

    // Re-enable the processing.
    _isBusy = false;
  }
}
