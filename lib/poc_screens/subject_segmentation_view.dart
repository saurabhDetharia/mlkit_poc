import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';

import '../widgets/subject_segmentation_painter.dart';

class SubjectSegmentationView extends StatefulWidget {
  const SubjectSegmentationView({super.key});

  @override
  State<SubjectSegmentationView> createState() =>
      _SubjectSegmentationViewState();
}

class _SubjectSegmentationViewState extends State<SubjectSegmentationView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _selfieSegmentationPainter;

  // Subject segmenter service instance
  final _subjectSegmenter = SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundConfidenceMask: false,
      enableForegroundBitmap: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: true,
        enableSubjectBitmap: true,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CameraView(
      onImageReceived: _processImage,
      customPainter: CustomPaint(
        painter: _selfieSegmentationPainter,
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the subject detector and release its resources.
    _subjectSegmenter.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final result = await _subjectSegmenter.processImage(image);

    // Used to draw painting on the segmented area.
    _selfieSegmentationPainter = SubjectSegmentationPainter(
      result,
      image.metadata!.size,
      image.metadata!.rotation,
    );

    // To update the result view.
    if (!mounted) return;
    setState(() {});

    // Re-enable the processing.
    _isBusy = false;
  }
}
