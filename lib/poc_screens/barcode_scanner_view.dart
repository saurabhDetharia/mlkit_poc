import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:ml_kit_poc/widgets/barcode_painter.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScannerView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  /// Handles image processing to get barcode from it.
  final _barcodeScanner = BarcodeScanner();

  BarcodeDetectorPainter? painter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onImageReceived: _onImageReceived,
        onCameraReady: () {},
        customPainter: CustomPaint(
          painter: painter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the scanner and release its resources.
    _barcodeScanner.close();
    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _onImageReceived(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    final barcode = await _barcodeScanner.processImage(image);

    if (barcode.isNotEmpty) {
      debugPrint('Barcode: ${barcode.first.rawValue}');
      painter = BarcodeDetectorPainter(
        barcode,
        image.metadata!.size,
        image.metadata!.rotation,
      );
      if (!mounted) return;
      setState(() {});
    } else {
      painter = null;
      if (!mounted) return;
      setState(() {});
    }
    _isBusy = false;
  }
}
