import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

import '../coordinates_translator.dart';

class FaceMashDetectionPainter extends CustomPainter {
  const FaceMashDetectionPainter({
    required this.faceMeshes,
    required this.imageSize,
    required this.rotation,
    this.cameraLensDirection = CameraLensDirection.back,
  });

  final List<FaceMesh> faceMeshes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = Colors.white;

    // To draw all face mesh points
    for (final faceMesh in faceMeshes) {
      // Rectangle bounding box points of the meshes.
      final left = translateX(
        faceMesh.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        faceMesh.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        faceMesh.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        faceMesh.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // Draw rectangle box of the mesh.
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paintBorder,
      );

      // Used to draw triangle of the face mesh.
      void drawTriangle(FaceMeshTriangle faceMeshTriangle) {
        // Corner points of the triangles.
        final List<Offset> cornerPoints = <Offset>[];

        for (final point in faceMeshTriangle.points) {
          // Scale points according to canvas size and image size.
          final dx = translateX(
            point.x.toDouble(),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          );
          final dy = translateX(
            point.y.toDouble(),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          );

          cornerPoints.add(
            Offset(dx, dy),
          );
        }

        // Add the first point to close the polygon.
        cornerPoints.add(cornerPoints.first);

        // Draw polygon using points.
        canvas.drawPoints(PointMode.polygon, cornerPoints, paint);
      }

      // Triangles of the meshes.
      for (final faceMeshTriangle in faceMesh.triangles) {
        drawTriangle(faceMeshTriangle);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceMashDetectionPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.faceMeshes != faceMeshes;
  }
}
