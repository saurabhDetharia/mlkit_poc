import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../utils.dart';
import '../widgets/camera_view.dart';
import '../widgets/object_detection_painter.dart';

class ObjectDetectionView extends StatefulWidget {
  const ObjectDetectionView({super.key});

  @override
  State<ObjectDetectionView> createState() => _ObjectDetectionViewState();
}

class _ObjectDetectionViewState extends State<ObjectDetectionView> {
  // To handle scanning process.
  bool _canProcess = true;
  bool _isBusy = false;

  // To show the detected object details.
  CustomPainter? _objectDetectionPainter;

  // To process image to detect Object
  ObjectDetector? _objectDetector;

  int _selectedOption = 0;

  // Object detector options
  final _options = {
    'default': '',
    'object_custom': 'object_labeler.tflite',
    'fruits': 'object_labeler_fruits.tflite',
    'flowers': 'object_labeler_flowers.tflite',
    'birds': 'lite-model_aiy_vision_classifier_birds_V1_3.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/birds_V1/3

    'food': 'lite-model_aiy_vision_classifier_food_V1_1.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/food_V1/1

    'plants': 'lite-model_aiy_vision_classifier_plants_V1_3.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/plants_V1/3

    'mushrooms': 'lite-model_models_mushroom-identification_v1_1.tflite',
    // https://tfhub.dev/bohemian-visual-recognition-alliance/lite-model/models/mushroom-identification_v1/1

    'landmarks':
        'lite-model_on_device_vision_classifier_landmarks_classifier_north_america_V1_1.tflite',
    // https://tfhub.dev/google/lite-model/on_device_vision/classifier/landmarks_classifier_north_america_V1/1
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildDropdown(),
        ],
      ),
      body: CameraView(
        onImageReceived: _processImage,
        onCameraReady: _initialiseDetector,
        customPainter: CustomPaint(
          painter: _objectDetectionPainter,
        ),
      ),
    );
  }

  Widget _buildDropdown() => DropdownButton<int>(
        value: _selectedOption,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.green),
        underline: Container(
          height: 0.5,
          color: Colors.green,
        ),
        onChanged: (int? option) {
          if (option != null) {
            setState(() {
              _selectedOption = option;
              _initialiseDetector();
            });
          }
        },
        items: List<int>.generate(_options.length, (i) => i)
            .map<DropdownMenuItem<int>>(
          (option) {
            return DropdownMenuItem<int>(
              value: option,
              child: Text(_options.keys.toList()[option]),
            );
          },
        ).toList(),
      );

  @override
  void dispose() {
    // To prevent processing.
    _canProcess = false;

    // Close the image label detector and release its resources.
    _objectDetector?.close();

    super.dispose();
  }

  /// Below is used to process image once received.
  Future<void> _processImage(InputImage image) async {
    // If the image cannot be processed or already processing.
    if (!_canProcess || _isBusy) return;

    // To prevent multiple image processing.
    _isBusy = true;

    // Processes image here.
    final result = await _objectDetector!.processImage(image);

    if (result.isNotEmpty) {
      _objectDetectionPainter = ObjectDetectionPainter(
        result,
        image.metadata!.size,
        image.metadata!.rotation,
      );
    } else {
      _objectDetectionPainter = null;
    }

    // To update the result view.
    if (!mounted) return;
    setState(() {});

    // Re-enable the processing.
    _isBusy = false;
  }

  /// Initialise object detector.
  Future<void> _initialiseDetector() async {
    // Prevent process while detector options configured.
    _canProcess = false;

    // Release old detector instance.
    if (_objectDetector != null) {
      _objectDetector?.close();
      _objectDetector = null;
    }

    ObjectDetectorOptions objectDetectionOptions;

    if (_selectedOption == 0) {
      // Use the default model.
      objectDetectionOptions = ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      );
    } else {
      // Use custom model.
      final option = _options[_options.keys.toList()[_selectedOption]] ?? '';
      final modelPath = await getAssetPath('assets/ml/$option');
      print('use custom model path: $modelPath');
      objectDetectionOptions = LocalObjectDetectorOptions(
        mode: DetectionMode.stream,
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
      );
    }

    _objectDetector = ObjectDetector(
      options: objectDetectionOptions,
    );

    _canProcess = true;
  }
}
