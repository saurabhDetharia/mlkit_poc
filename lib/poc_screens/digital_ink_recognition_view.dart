import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:ml_kit_poc/widgets/signature_painter.dart';

import '../widgets/activity_indicator.dart';

class DigitalInkRecognitionView extends StatefulWidget {
  const DigitalInkRecognitionView({super.key});

  @override
  State<DigitalInkRecognitionView> createState() =>
      _DigitalInkRecognitionViewState();
}

class _DigitalInkRecognitionViewState extends State<DigitalInkRecognitionView> {
  // Codes from https://developers.google.com/ml-kit/vision/digital-ink-recognition/base-models?hl=en#text
  final _languageOptions = [
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'pt',
    'ru',
    'zh-Hani',
  ];

  // Selected language
  late String _selectedLanguageCode;

  // Digital ink recognizer
  late DigitalInkRecognizer _digitalInkRecogniser;

  // A subclass of [ModelManager] that manages
  // [DigitalInkRecognitionModel] required to process the image.
  final _modelManager = DigitalInkRecognizerModelManager();

  // Digital ink
  /// Ref: Represents the user input as a collection of [Stroke] and
  /// serves as input for the handwriting recognition task.
  final _ink = Ink();

  // Detected text
  String _recognizedText = '';

  // To draw stroke points.
  List<StrokePoint> _points = [];

  @override
  void initState() {
    super.initState();

    // Set English as default selected language.
    _selectedLanguageCode = 'en';

    // Initialises recognizer with default language.
    _initialiseRecognizer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Ink Recognition',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Space - 8px
            _verticalSpace,

            // Model
            _getModelOptionsView,

            // Space - 8px
            _verticalSpace,

            // Ink pad options
            _getInkPadOptionsView,

            // Space - 8px
            _verticalSpace,

            // Drawing pad
            _getDrawingPadView,

            // This will be shown when the text detected
            // in the digital pad.
            if (_recognizedText.isNotEmpty)
              Text(
                'Candidates: $_recognizedText',
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Release recognizer and resources.
    _releaseRecognizer();

    super.dispose();
  }

  /// Widgets ---->

  /// This will be used for 8px Vertical Space.
  SizedBox get _verticalSpace => const SizedBox(
        height: 8,
      );

  /// Used to show different options for selected model.
  Widget get _getModelOptionsView {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageOptionsDropdown,
          ElevatedButton(
            onPressed: _isModelDownloaded,
            child: const Text('Check Model'),
          ),
          ElevatedButton(
            onPressed: _downloadModel,
            child: const Icon(Icons.download),
          ),
          ElevatedButton(
            onPressed: _deleteModel,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  /// Used to show the language options dropdown.
  Widget get _buildLanguageOptionsDropdown {
    return DropdownButton<String>(
      value: _selectedLanguageCode,
      onChanged: (lang) {
        if (lang != null) {
          _selectedLanguageCode = lang;
          _releaseRecognizer();
          _initialiseRecognizer();
          setState(() {});
        }
      },
      items: _languageOptions.map<DropdownMenuItem<String>>(
        (language) {
          return DropdownMenuItem(
            value: language,
            child: Text(language),
          );
        },
      ).toList(),
    );
  }

  /// Used to show Ink pad options
  Widget get _getInkPadOptionsView {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _recogniseText,
            child: const Text('Read Text'),
          ),
          ElevatedButton(
            onPressed: _clearPad,
            child: const Text('Clear Pad'),
          ),
        ],
      ),
    );
  }

  /// Used to show Ink pad
  Widget get _getDrawingPadView {
    return Expanded(
      child: ColoredBox(
        color: Colors.grey.shade200,
        child: GestureDetector(
          onPanStart: (DragStartDetails details) {
            _ink.strokes.add(Stroke());
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              final RenderObject? object = context.findRenderObject();
              final localPosition =
                  (object as RenderBox?)?.globalToLocal(details.localPosition);
              if (localPosition != null) {
                _points = List.from(_points)
                  ..add(StrokePoint(
                    x: localPosition.dx,
                    y: localPosition.dy,
                    t: DateTime.now().millisecondsSinceEpoch,
                  ));
              }
              if (_ink.strokes.isNotEmpty) {
                _ink.strokes.last.points = _points.toList();
              }
            });
          },
          onPanEnd: (DragEndDetails details) {
            _points.clear();
            setState(() {});
          },
          child: CustomPaint(
            painter: SignaturePainter(
              ink: _ink,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  /// <----

  /// Supportive functions ---->

  /// This will be used to check whether the model is
  /// downloaded or not and show it's status accordingly.
  Future<void> _isModelDownloaded() async {
    Toast().show(
      'Checking if model is downloaded...',
      _modelManager.isModelDownloaded(_selectedLanguageCode).then(
        (value) {
          return value ? 'downloaded' : 'not downloaded';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to delete model and show it's status accordingly.
  Future<void> _deleteModel() async {
    Toast().show(
      'Deleting model...',
      _modelManager.deleteModel(_selectedLanguageCode).then(
        (value) {
          return value ? 'success' : 'failed';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to download model and show it's status accordingly.
  Future<void> _downloadModel() async {
    Toast().show(
      'Downloading model...',
      _modelManager.downloadModel(_selectedLanguageCode).then(
        (value) {
          return value ? 'success' : 'failed';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to initialise the digital ink recognizer.
  void _initialiseRecognizer() {
    _digitalInkRecogniser = DigitalInkRecognizer(
      languageCode: _selectedLanguageCode,
    );
  }

  /// This will be used to close the recognizer and release its resources.
  void _releaseRecognizer() {
    _digitalInkRecogniser.close();
  }

  /// This will be used to occupy the screen while processing image
  /// and recognise the text.
  Future<void> _recogniseText() async {
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderCtx) {
        return const AlertDialog(
          title: Text('Recognizing'),
        );
      },
    );

    try {
      // Process the ink
      final candidates = await _digitalInkRecogniser.recognize(_ink);

      // Clears previous text and appends new texts.
      _recognizedText = '';
      for (final candidate in candidates) {
        _recognizedText += '${candidate.text},';
      }
    } catch (e) {
      Toast().showMessage(
        e.toString(),
        context,
      );
    }

    // Closes dialog
    if (mounted) {
      Navigator.pop(context);
      setState(() {});
    }
  }

  /// This will be used to clear the drawing pad.
  void _clearPad() {
    _ink.strokes.clear();
    _recognizedText = '';
    setState(() {});
  }

  /// <----
}
