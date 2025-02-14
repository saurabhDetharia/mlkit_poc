import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../coordinates_translator.dart';

class ObjectDetectionPainter extends CustomPainter {
  final List<DetectedObject> detectedObjects;
  final Size imageSize;
  final InputImageRotation rotation;

  const ObjectDetectionPainter(
    this.detectedObjects,
    this.imageSize,
    this.rotation,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Paint style for stroke.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green;

    for (final object in detectedObjects) {
      // To draw labels
      final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr,
        ),
      );
      paragraphBuilder.pushStyle(
        ui.TextStyle(
          color: Colors.green,
          background: Paint()..color = const Color(0x99000000),
        ),
      );
      if (object.labels.isNotEmpty) {
        final label = object.labels.reduce(
          (a, b) => a.confidence > b.confidence ? a : b,
        );
        paragraphBuilder.addText(
          '${label.text} ${label.confidence}\n',
        );
      }
      // paragraphBuilder.pop();

      final rect = object.boundingBox;

      final left = translateX(
        rect.left,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final right = translateX(
        rect.right,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final top = translateY(
        rect.top,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final bottom = translateY(
        rect.bottom,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        paragraphBuilder.build()
          ..layout(
            ParagraphConstraints(
              width: (right - left).abs(),
            ),
          ),
        Offset(Platform.isAndroid ? left : left, top),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ObjectDetectionPainter oldDelegate) {
    return oldDelegate.detectedObjects != detectedObjects;
  }
}
