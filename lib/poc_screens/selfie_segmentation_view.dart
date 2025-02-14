import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';

import '../widgets/selfie_segmenter_painter.dart';

class SelfieSegmentationView extends StatefulWidget {
  const SelfieSegmentationView({super.key});

  @override
  State<SelfieSegmentationView> createState() => _SelfieSegmentationViewState();
}

class _SelfieSegmentationViewState extends State<SelfieSegmentationView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _selfieSegmentationPainter;

  // To process image to separate selfie.
  final _selfieSegmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onImageReceived: _processImage,
        customPainter: CustomPaint(
          painter: _selfieSegmentationPainter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the pose detector and release its resources.
    _selfieSegmenter.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final mask = await _selfieSegmenter.processImage(image);

    if (mask != null && image.metadata != null) {
      _selfieSegmentationPainter = SelfieSegmenterPainter(
        mask: mask,
        imageSize: image.metadata!.size,
        rotation: image.metadata!.rotation,
      );
    } else {
      _selfieSegmentationPainter = null;
    }

    // To update the result view.
    if (!mounted) return;
    setState(() {});

    // Re-enable the processing.
    _isBusy = false;
  }
}
