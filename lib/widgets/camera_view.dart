import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    required this.onImageReceived,
    this.onCameraReady,
    this.customPainter,
    this.initialCameraLensDirection = CameraLensDirection.back,
    super.key,
  });

  // Default camera lens direction.
  final CameraLensDirection initialCameraLensDirection;

  // To get the image frame from the Camera.
  final Function(InputImage image) onImageReceived;

  // Callback when camera is ready.
  final VoidCallback? onCameraReady;

  final CustomPaint? customPainter;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // All available cameras.
  static List<CameraDescription> _cameras = [];

  // To control the camera.
  CameraController? _cameraController;

  // Default selected camera direction index.
  int _selectedCameraIndex = -1;

  // Request params getter
  CameraLensDirection get _initialCameraLensDirection =>
      widget.initialCameraLensDirection;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();

    // Initialises the camera.
    _initialise();
  }

  @override
  Future<void> dispose() async {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _cameraPreviewWidget,
    );
  }

  /// Camera preview Widget.
  Widget get _cameraPreviewWidget {
    // Check if the camera is whether initialised or not.
    if (_cameras.isEmpty ||
        _cameraController == null ||
        !(_cameraController?.value.isInitialized ?? false)) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera view
        CameraPreview(
          _cameraController!,
          child: widget.customPainter,
        ),

        // Close Icon
        _closeIconWidget,
      ],
    );
  }

  /// Below indicates `Close` icon.
  Widget get _closeIconWidget => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black54,
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

  /// Used to initialise the Camera and
  /// Sets default Camera options.
  Future<void> _initialise() async {
    // Get the list of available cameras.
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    _selectedCameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == _initialCameraLensDirection,
    );

    // If appropriate camera lens direction is selected.
    if (!_selectedCameraIndex.isNegative) {
      _startCamera();
    }
  }

  /// This will be used to initialise the Camera,
  /// and handle it's callbacks.
  _startCamera() {
    final camera = _cameras[_selectedCameraIndex];

    // Create camera controller instance.
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    // Initialise the camera controller.
    _cameraController?.initialize().then((_) {
      // User already left the screen.
      if (!mounted) return;

      // Start streaming camera image.
      _cameraController?.startImageStream((image) {
        return _processCameraImage(image);
      }).then(
        (_) {
          if (widget.onCameraReady != null) {
            widget.onCameraReady!();
          }
        },
      );

      setState(() {});
    });
  }

  /// This will be used to process the image stream
  /// received from the Camera.
  void _processCameraImage(CameraImage cameraImage) {
    // Get InputImage from the CameraImage.
    final inputImage = _getInputImage(cameraImage);

    // debugPrint('Image: ${inputImage == null}');

    if (inputImage == null) return;

    // Send the InputImage as output.
    widget.onImageReceived(inputImage);
  }

  InputImage? _getInputImage(CameraImage image) {
    // If controller not initialised.
    if (_cameraController == null) return null;

    final camera = _cameras[_selectedCameraIndex];

    // Get the orientation of the camera.
    final sensorOrientation = camera.sensorOrientation;

    // debugPrint(
    //   'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation,'
    //   ' ${_cameraController?.value.deviceOrientation} '
    //   '${_cameraController?.value.lockedCaptureOrientation} '
    //   '${_cameraController?.value.isCaptureOrientationLocked}',
    // );

    InputImageRotation? imageRotation;

    // Get required rotation value based on the platform.
    if (Platform.isIOS) {
      imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];

      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      imageRotation =
          InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    // For other platforms or to detect any unexpected factors.
    if (imageRotation == null) return null;

    // Get image format.
    final imageFormat = InputImageFormatValue.fromRawValue(image.format.raw);

    // Check the image is in appropriate format.
    if (imageFormat == null ||
        (Platform.isIOS && imageFormat != InputImageFormat.bgra8888) ||
        (Platform.isAndroid && imageFormat != InputImageFormat.nv21)) {
      return null;
    }

    // As format is constraint to nv21 or bgra8888, both only have one plane.
    if (image.planes.length != 1) return null;
    final imagePlane = image.planes.first;

    return InputImage.fromBytes(
      bytes: imagePlane.bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: imageRotation,
        format: imageFormat,
        bytesPerRow: imagePlane.bytesPerRow,
      ),
    );
  }

  /// To dispose and release camera and resources.
  Future<void> _dispose() async {
    // Stops streaming images.
    await _cameraController?.stopImageStream();

    // Close the camera and release resources.
    await _cameraController?.dispose();

    // Un-assign the camera controller to avoid
    // the re-initialisation exception.
    _cameraController = null;
  }
}
