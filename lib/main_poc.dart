import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ml_kit_poc/poc_screens/barcode_scanner_view.dart';
import 'package:ml_kit_poc/poc_screens/digital_ink_recognition_view.dart';
import 'package:ml_kit_poc/poc_screens/documents_scanner_view.dart';
import 'package:ml_kit_poc/poc_screens/face_detection_view.dart';
import 'package:ml_kit_poc/poc_screens/face_mash_detection_view.dart';
import 'package:ml_kit_poc/poc_screens/image_label_view.dart';
import 'package:ml_kit_poc/poc_screens/nlp_detector/entity_extraction_view.dart';
import 'package:ml_kit_poc/poc_screens/nlp_detector/language_identification_view.dart';
import 'package:ml_kit_poc/poc_screens/nlp_detector/language_translator_view.dart';
import 'package:ml_kit_poc/poc_screens/nlp_detector/smart_reply_view.dart';
import 'package:ml_kit_poc/poc_screens/object_detection_view.dart';
import 'package:ml_kit_poc/poc_screens/pose_detection_view.dart';
import 'package:ml_kit_poc/poc_screens/selfie_segmentation_view.dart';
import 'package:ml_kit_poc/poc_screens/subject_segmentation_view.dart';
import 'package:ml_kit_poc/poc_screens/text_recognition_view.dart';

class MainPoc extends StatefulWidget {
  const MainPoc({super.key, required this.title});

  final String title;

  @override
  State<MainPoc> createState() => _MainPocState();
}

class _MainPocState extends State<MainPoc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 16,
              ),

              const Text(
                'Vision APIs:',
              ),

              // Barcode scanner
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const BarcodeScannerView(),
                  );
                },
                child: const Text('Barcode Scanner'),
              ),

              // Text Recognizer
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const TextRecognitionView(),
                  );
                },
                child: const Text('Text Recognizer'),
              ),

              // Face Detector
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const FaceDetectionView(),
                  );
                },
                child: const Text('Face Detector'),
              ),

              // Image labeling
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const ImageLabelView(),
                  );
                },
                child: const Text('Image Labeling'),
              ),

              // Object Detection
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const ObjectDetectionView(),
                  );
                },
                child: const Text('Object Detection'),
              ),

              // Pose Detection
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const PoseDetectionView(),
                  );
                },
                child: const Text('Pose Detection'),
              ),

              // Selfie Segmenter
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const SelfieSegmentationView(),
                  );
                },
                child: const Text('Selfie Segmenter'),
              ),

              // Digital Ink Recognition
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const DigitalInkRecognitionView(),
                  );
                },
                child: const Text('Digital Ink Recognition'),
              ),

              // Below services are only available for Android.
              if (Platform.isAndroid) ...[
                // FaceMesh Detection
                ElevatedButton(
                  onPressed: () {
                    _navigateTo(
                      const FaceMeshDetectionView(),
                    );
                  },
                  child: const Text('FaceMash Detection'),
                ),

                // Document Scanner
                ElevatedButton(
                  onPressed: () {
                    _navigateTo(
                      const DocumentsScannerView(),
                    );
                  },
                  child: const Text('Document Scanner'),
                ),

                // Subject Segmentation
                ElevatedButton(
                  onPressed: () {
                    _navigateTo(
                      const SubjectSegmentationView(),
                    );
                  },
                  child: const Text('Subject Segmentation'),
                ),
              ],

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Natural Language APIs:',
              ),

              // Language ID Identification
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const LanguageIdentificationView(),
                  );
                },
                child: const Text('Language ID'),
              ),

              // On Device translation
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const LanguageTranslatorView(),
                  );
                },
                child: const Text('On-Device translation'),
              ),

              // Smart-Reply View
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const SmartReplyView(),
                  );
                },
                child: const Text('Smart Reply'),
              ),

              // Entity Extractor View
              ElevatedButton(
                onPressed: () {
                  _navigateTo(
                    const EntityExtractionView(),
                  );
                },
                child: const Text('Entity Extractor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// This redirects to the [child] widget/screen.
  void _navigateTo(Widget child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builderCtx) {
          return child;
        },
      ),
    );
  }
}
