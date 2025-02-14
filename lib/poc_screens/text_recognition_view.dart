import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ml_kit_poc/widgets/camera_view.dart';

class TextRecognitionView extends StatefulWidget {
  const TextRecognitionView({super.key});

  @override
  State<TextRecognitionView> createState() => _TextRecognitionViewState();
}

class _TextRecognitionViewState extends State<TextRecognitionView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // Responsible to process the image and recognizes the text within it.
  final _textRecognizer = TextRecognizer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraView(
        onImageReceived: _processImage,
      ),
    );
  }

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the recognizer and release its resources.
    _textRecognizer.close();
    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Parse the image and get the text.
    final recognizedText = await _textRecognizer.processImage(image);
    if (recognizedText.blocks.isNotEmpty) {
      for (final block in recognizedText.blocks) {
        debugPrint('Text: ${block.text}');
      }
    }

    // Re-enable the processing.
    _isBusy = false;
  }
}
