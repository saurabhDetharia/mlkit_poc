import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../coordinates_translator.dart';

class PoseDetectionPainter extends CustomPainter {
  PoseDetectionPainter({
    required this.poses,
    required this.rotation,
    required this.imageSize,
  });

  final List<Pose> poses;
  final InputImageRotation rotation;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..color = Colors.pink;

    final paintLine = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Colors.grey;

    for (final pose in poses) {
      if (pose.landmarks.isNotEmpty) {
        pose.landmarks.forEach((_, landmark) {
          // Draw body points
          canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                CameraLensDirection.back,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                CameraLensDirection.back,
              ),
            ),
            1,
            paint,
          );

          // Draw lines body
          void drawLine(
            PoseLandmarkType landmarkType1,
            PoseLandmarkType landmarkType2,
            Paint paint,
          ) {
            final landmark1 = pose.landmarks[landmarkType1]!;
            final landmark2 = pose.landmarks[landmarkType2]!;

            canvas.drawLine(
              Offset(
                translateX(
                  landmark1.x,
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
                translateY(
                  landmark1.y,
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
              ),
              Offset(
                translateX(
                  landmark2.x,
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
                translateY(
                  landmark2.y,
                  size,
                  imageSize,
                  rotation,
                  CameraLensDirection.back,
                ),
              ),
              paint,
            );
          }

          // Left side
          drawLine(
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.leftElbow,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.leftElbow,
            PoseLandmarkType.leftWrist,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.leftHip,
            PoseLandmarkType.leftKnee,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.leftKnee,
            PoseLandmarkType.leftAnkle,
            paintLine,
          );

          // Right side
          drawLine(
            PoseLandmarkType.rightShoulder,
            PoseLandmarkType.rightWrist,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.rightWrist,
            PoseLandmarkType.rightElbow,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.rightHip,
            PoseLandmarkType.rightKnee,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.rightKnee,
            PoseLandmarkType.rightAnkle,
            paintLine,
          );

          // Body
          drawLine(
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.rightShoulder,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.leftHip,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.rightShoulder,
            PoseLandmarkType.rightHip,
            paintLine,
          );
          drawLine(
            PoseLandmarkType.leftHip,
            PoseLandmarkType.rightHip,
            paintLine,
          );
        });
      }
    }
  }

  @override
  bool shouldRepaint(covariant PoseDetectionPainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}
