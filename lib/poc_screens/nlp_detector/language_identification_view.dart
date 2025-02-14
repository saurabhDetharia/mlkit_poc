import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageIdentificationView extends StatefulWidget {
  const LanguageIdentificationView({super.key});

  @override
  State<LanguageIdentificationView> createState() =>
      _LanguageIdentificationViewState();
}

class _LanguageIdentificationViewState
    extends State<LanguageIdentificationView> {
  // Text field controller
  TextEditingController? _controller;

  // Language identified from the text
  String _identifiedLanguage = '';

  // Language Identifier
  final _languageIdentifier = LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Language Identification',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: _controller,
            ),

            // Space - 16px
            const SizedBox(height: 16),

            // Identify language button
            ElevatedButton(
              onPressed: _identifyLanguage,
              child: const Text(
                'Identify Language',
              ),
            ),

            // Space - 16px
            const SizedBox(height: 16),

            // Identify language possibility button
            ElevatedButton(
              onPressed: _identifyPossibleLanguages,
              child: const Text('Identify possible languages'),
            ),

            // Space - 16px
            const SizedBox(height: 16),

            // Identified language
            if (_identifiedLanguage.isNotEmpty) ...[
              Text(
                'Identified Language: $_identifiedLanguage',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Release text field controller
    _controller?.dispose();
    super.dispose();
  }

  /// This will be used to identify language.
  Future<void> _identifyLanguage() async {
    // If no text entered, do not proceed further.
    if (_controller == null || (_controller?.text ?? '') == '') {
      return;
    }

    // Reset text
    _identifiedLanguage = '';

    try {
      _identifiedLanguage =
          await _languageIdentifier.identifyLanguage(_controller!.text);
    } on PlatformException catch (e) {
      if (e.code == _languageIdentifier.undeterminedLanguageCode) {
        _identifiedLanguage = 'error: no language identified!';
      } else {
        _identifiedLanguage = 'error: ${e.code}: ${e.message}';
      }
    } catch (e) {
      _identifiedLanguage = 'error: ${e.toString()}';
    }

    // Refresh UI
    if (mounted) {
      setState(() {});
    }
  }

  /// This will be used to identify languages and it's possibilities.
  Future<void> _identifyPossibleLanguages() async {
    // If no text entered, do not proceed further.
    if (_controller == null || (_controller?.text ?? '') == '') {
      return;
    }

    // Reset text
    _identifiedLanguage = '';

    try {
      final possibleLanguages =
          await _languageIdentifier.identifyPossibleLanguages(
        _controller!.text,
      );

      for (final languageDetails in possibleLanguages) {
        _identifiedLanguage +=
            '${languageDetails.languageTag} ${languageDetails.confidence} \n';
      }
    } on PlatformException catch (e) {
      if (e.code == _languageIdentifier.undeterminedLanguageCode) {
        _identifiedLanguage = 'error: no language identified!';
      } else {
        _identifiedLanguage = 'error: ${e.code}: ${e.message}';
      }
    } catch (e) {
      _identifiedLanguage = 'error: ${e.toString()}';
    }

    // Refresh UI
    if (mounted) {
      setState(() {});
    }
  }
}
