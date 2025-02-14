import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';

import '../coordinates_translator.dart';

class SubjectSegmentationPainter extends CustomPainter {
  final SubjectSegmentationResult mask;
  final Size imageSize;
  final InputImageRotation rotation;

  SubjectSegmentationPainter(
    this.mask,
    this.imageSize,
    this.rotation,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Painter configuration.
    final paint = Paint()..style = PaintingStyle.fill;

    // Get subjects from the masks.
    final maskSubjects = mask.subjects;

    for (final subject in maskSubjects) {
      // Starting position
      final int startX = subject.startX;
      final int startY = subject.startY;

      // Subject dimensions
      final int subjectWidth = subject.width;
      final int subjectHeight = subject.height;

      // Get confidences for masks.
      final List<double> confidences = subject.confidenceMask ?? [];

      for (int y = 0; y < subjectHeight; y++) {
        for (int x = 0; y < subjectWidth; x++) {
          // Get absolute positions
          final tx = translateX(
            startX.toDouble(),
            size,
            Size(imageSize.width.toDouble(), imageSize.height.toDouble()),
            rotation,
            CameraLensDirection.back,
          );

          final ty = translateY(
            startY.toDouble(),
            size,
            Size(imageSize.width.toDouble(), imageSize.height.toDouble()),
            rotation,
            CameraLensDirection.back,
          );

          // Get the opacity based on the positions of the canvas.
          final opacity = confidences[(y * subjectWidth) + x] * 0.5;

          // Get the color opacity
          paint.color = Colors.blue.withOpacity(opacity);

          // Draw pixels on the canvas.
          canvas.drawCircle(
            Offset(tx.toDouble(), ty.toDouble()),
            2,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SubjectSegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
