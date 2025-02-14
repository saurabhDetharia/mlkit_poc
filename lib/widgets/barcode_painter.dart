import 'dart:ui' as ui;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../coordinates_translator.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(
    this.barcodes,
    this.imageSize,
    this.rotation,
  );

  final List<Barcode> barcodes;
  final Size imageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    var framePainter = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber
      ..strokeWidth = 4;

    for (final barcode in barcodes) {
      final left = translateX(
        barcode.boundingBox.left,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      final top = translateX(
        barcode.boundingBox.top,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      final bottom = translateX(
        barcode.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      final right = translateX(
        barcode.boundingBox.right,
        size,
        imageSize,
        rotation,
        CameraLensDirection.back,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        framePainter,
      );
      var paragraphBuilder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr,
        ),
      )
        ..pushStyle(
          ui.TextStyle(
            color: Colors.lightGreenAccent,
            background: Paint()..color = const Color(0x99000000),
          ),
        )
        ..addText('${barcode.displayValue}')
        ..pop();

      canvas.drawParagraph(
        paragraphBuilder.build()
          ..layout(ParagraphConstraints(
            width: (right - left).abs(),
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.barcodes != barcodes;
  }
}
