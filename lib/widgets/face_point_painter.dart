import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../coordinates_translator.dart';

class FaceOutlinePainter extends CustomPainter {
  FaceOutlinePainter({
    required this.faces,
    required this.imageSize,
    required this.rotation,
  });

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final faceBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    faceCounterPointPaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = color;

    final faceLandmarkPointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    for (final face in faces) {
      final faceRect = face.boundingBox;

      final left = translateX(
        faceRect.left,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final right = translateX(
        faceRect.right,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final top = translateX(
        faceRect.top,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );
      final bottom = translateX(
        faceRect.bottom,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        faceBorderPaint,
      );

      void drawCounter(
        FaceContourType counterType,
        Color color,
      ) {
        final faceCounterPoints = face.contours[counterType];

        if (faceCounterPoints != null) {
          for (final point in faceCounterPoints.points) {
            canvas.drawCircle(
              Offset(
                translateX(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
                translateY(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
              ),
              1,
              faceCounterPointPaint(color),
            );
          }
        }
      }

      void drawLandMark(FaceLandmarkType faceLandMarkType) {
        final landMarks = face.landmarks[faceLandMarkType];

        if (landMarks != null) {
          canvas.drawCircle(
            Offset(
              translateX(
                landMarks.position.x.toDouble(),
                size,
                imageSize,
                rotation,
                CameraLensDirection.back,
              ),
              translateY(
                landMarks.position.y.toDouble(),
                size,
                imageSize,
                rotation,
                CameraLensDirection.back,
              ),
            ),
            2,
            faceLandmarkPointPaint,
          );
        }
      }

      for (final faceCounterType in FaceContourType.values) {
        drawCounter(
          faceCounterType,
          Colors.red,
        );
      }

      for (final faceLandMarkType in FaceLandmarkType.values) {
        drawLandMark(faceLandMarkType);
      }
    }
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
