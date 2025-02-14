import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import '../coordinates_translator.dart';

class SelfieSegmenterPainter extends CustomPainter {
  SelfieSegmenterPainter({
    required this.mask,
    required this.imageSize,
    required this.rotation,
  });

  final SegmentationMask mask;
  final Size imageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    // Get mask resolutions & details
    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;

    // Painting details to draw on Canvas.
    final paint = Paint()..style = PaintingStyle.fill;

    /**
     * Consider canvas as 2 dimensional. So, `x` represents the
     * co-ordinates of the X-Axis and `y` represents the
     * co-ordinates of the Y-Axis. According to the mask's
     * height and width, the painting will be drawn.
     */
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final tx = translateX(
          x.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          CameraLensDirection.back,
        ).round();
        final ty = translateY(
          y.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          CameraLensDirection.back,
        ).round();

        /**
         * Opacity used to draw segmentation. Where the person/animal
         * detected, the opacity will be greater than 0,
         * where as for the rest of the part, it will be 0.
         */
        final double opacity = confidences[(y * width) + x] * 0.5;

        // Update the color with opacity.
        paint.color = Colors.blue.withOpacity(opacity);

        // Draw x, and y co-ordinates/pixels.
        canvas.drawCircle(
          Offset(tx.toDouble(), ty.toDouble()),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SelfieSegmenterPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}
