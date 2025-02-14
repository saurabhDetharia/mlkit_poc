import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class SignaturePainter extends CustomPainter {
  const SignaturePainter({
    required this.ink,
  });

  final Ink ink;

  @override
  void paint(Canvas canvas, Size size) {
    // Painting properties for canvas.
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    // Get the strokes defined within ink.
    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];

        canvas.drawLine(
          Offset(p1.x.toDouble(), p1.y.toDouble()),
          Offset(p2.x.toDouble(), p2.y.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return true;
  }
}
