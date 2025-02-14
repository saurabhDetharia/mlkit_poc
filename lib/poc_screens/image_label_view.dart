import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../utils.dart';
import '../widgets/camera_view.dart';
import '../widgets/label_detector_painter.dart';

class ImageLabelView extends StatefulWidget {
  const ImageLabelView({super.key});

  @override
  State<ImageLabelView> createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  // To handle scanning process.
  bool _canProcess = false;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _imageLabelViewPainter;

  // Used to interpret images and get labels.
  late ImageLabeler _imageLabeler;

  @override
  void initState() {
    super.initState();
    _initialiseLabeler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        customPainter: CustomPaint(
          painter: _imageLabelViewPainter,
        ),
        onImageReceived: _processImage,
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the image label detector and release its resources.
    _imageLabeler.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final result = await _imageLabeler.processImage(image);

    if (result.isNotEmpty) {
      _imageLabelViewPainter = LabelDetectorPainter(result);
      if (!mounted) return;
      setState(() {});
    } else {
      if (!mounted) return;
      setState(() {});
    }

    // Re-enable the processing.
    _isBusy = false;
  }

  Future<void> _initialiseLabeler() async {
    // To use default model
    // _imageLabeler = ImageLabeler(
    //   options: ImageLabelerOptions(),
    // );

    // To use a local model
    const path = 'assets/ml/object_labeler.tflite';
    final modelPath = await getAssetPath(path);
    final options = LocalLabelerOptions(modelPath: modelPath);
    _imageLabeler = ImageLabeler(options: options);

    // To start processing.
    _canProcess = true;
  }
}
