import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.labels);

  final List<ImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    // To design paragraph
    final paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 23,
        textDirection: TextDirection.ltr,
      ),
    );

    // To define text style
    paragraphBuilder.pushStyle(
      ui.TextStyle(
        color: Colors.white,
      ),
    );

    // Add text to paragraph builder.
    for (final label in labels) {
      paragraphBuilder.addText(
        'Label: ${label.label}, Confidence: '
        '${label.confidence.toStringAsFixed(2)}%\n',
      );
    }
    paragraphBuilder.pop();

    // Add paragraph to canvas.
    canvas.drawParagraph(
      paragraphBuilder.build()
        ..layout(
          ui.ParagraphConstraints(
            width: size.width,
          ),
        ),
      const Offset(0, 0),
    );
  }

  @override
  bool shouldRepaint(covariant LabelDetectorPainter oldDelegate) {
    return oldDelegate.labels != labels;
  }
}
