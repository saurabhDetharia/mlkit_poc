import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../widgets/activity_indicator.dart';

class LanguageTranslatorView extends StatefulWidget {
  const LanguageTranslatorView({super.key});

  @override
  State<LanguageTranslatorView> createState() => _LanguageTranslatorViewState();
}

class _LanguageTranslatorViewState extends State<LanguageTranslatorView> {
  // Selected source language
  TranslateLanguage _selectedSourceLanguage = TranslateLanguage.english;
  TranslateLanguage _selectedTargetLanguage = TranslateLanguage.english;

  // Input field controllers.
  TextEditingController? _sourceContentController;
  TextEditingController? _translatedContentController;

  // Translator service instance
  late OnDeviceTranslator _deviceTranslator;

  // To handle different translator model.
  final _modelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();

    // Initialise controllers.
    _sourceContentController = TextEditingController();
    _translatedContentController = TextEditingController();

    // Initialise translator with default selected languages.
    _initialiseTranslator();
  }

  @override
  void dispose() {
    // Releases input controllers.
    _sourceContentController?.dispose();
    _translatedContentController?.dispose();

    // Release translator instance.
    _releaseTranslator();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Language Translator',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Space - 32px
            _getVerticalSpace32px,

            // Source View
            _getSourceView,

            // Space - 32px
            _getVerticalSpace32px,

            // Target View
            _getTargetView,

            // Space - 32px
            _getVerticalSpace32px,

            // Translate Button
            ElevatedButton(
              onPressed: _translateContent,
              child: const Text(
                'Translate',
              ),
            ),

            // Space - 32px
            _getVerticalSpace32px,

            // Check model buttons
            _getModelAvailabilityButtonsWidget,

            // Space - 32px
            _getVerticalSpace32px,

            // Download model languages buttons
            _getDownloadModelButtonsWidget,

            // Space - 32px
            _getVerticalSpace32px,

            // Delete model languages buttons
            _getDeletedModelButtonsWidget,
          ],
        ),
      ),
    );
  }

  /// Widgets ---->

  /// Used to show the vertical space - 32px.
  Widget get _getVerticalSpace32px {
    return const SizedBox(
      height: 32,
    );
  }

  /// Used to show the vertical space - 16px.
  Widget get _getVerticalSpace16px {
    return const SizedBox(
      height: 16,
    );
  }

  /// Used to show the vertical space - 16px.
  Widget get _getHorizontalSpace16px {
    return const SizedBox(
      width: 16,
    );
  }

  /// Used to show the source view.
  Widget get _getSourceView {
    return Column(
      children: [
        // Title of the source language
        Text(
          'Enter text (Source: ${_selectedSourceLanguage.name})',
        ),

        // Space - 16px
        _getVerticalSpace16px,

        Row(
          children: [
            // Source text input field
            Expanded(
              child: TextField(
                controller: _sourceContentController,
                decoration: _textFieldDecoration,
              ),
            ),

            // Space - 16px
            _getHorizontalSpace16px,

            // Language selection drop down
            _buildDropdown(false),
          ],
        )
      ],
    );
  }

  /// Used to show the target view.
  Widget get _getTargetView {
    return Column(
      children: [
        // Title of the source language
        Text(
          'Translated text (Source: ${_selectedTargetLanguage.name})',
        ),

        // Space - 16px
        _getVerticalSpace16px,

        Row(
          children: [
            // Source text input field
            Expanded(
              child: TextField(
                controller: _translatedContentController,
                readOnly: true,
                decoration: _textFieldDecoration,
              ),
            ),

            // Space - 16px
            _getHorizontalSpace16px,

            // Language selection drop down
            _buildDropdown(true),
          ],
        )
      ],
    );
  }

  /// Used to show the language selection drop-down.
  Widget _buildDropdown(bool isTarget) {
    return DropdownButton<String>(
      value: isTarget
          ? _selectedTargetLanguage.bcpCode
          : _selectedSourceLanguage.bcpCode,
      items: TranslateLanguage.values.map(
        (language) {
          return DropdownMenuItem(
            value: language.bcpCode,
            child: Text(language.name),
          );
        },
      ).toList(),
      onChanged: (String? selectedLangCode) {
        if (selectedLangCode != null) {
          // Get language code from BCP47Code.
          final lang = BCP47Code.fromRawValue(selectedLangCode);

          // Verifies due to any error or for any language,
          // Code is not generated, then it prevents from proceeding.
          if (lang != null) {
            if (isTarget) {
              _selectedTargetLanguage = lang;
            } else {
              _selectedSourceLanguage = lang;
            }

            // Re-initialises translator with new selected languages.
            _initialiseTranslator();

            setState(() {});
          }
        }
      },
    );
  }

  /// Used to check whether the selected languages model are exists.
  Widget get _getModelAvailabilityButtonsWidget {
    return Row(
      children: [
        // Source language
        ElevatedButton(
          onPressed: () => _isModelDownloaded(
            _selectedSourceLanguage.bcpCode,
          ),
          child: const Text(
            "Check Source Language",
          ),
        ),

        // Space - 16px
        _getHorizontalSpace16px,

        // Target language
        ElevatedButton(
          onPressed: () => _isModelDownloaded(
            _selectedTargetLanguage.bcpCode,
          ),
          child: const Text(
            "Check Target Language",
          ),
        ),
      ],
    );
  }

  /// Used to download the selected languages models.
  Widget get _getDownloadModelButtonsWidget {
    return Row(
      children: [
        // Source language
        ElevatedButton(
          onPressed: () => _downloadModel(
            _selectedSourceLanguage.bcpCode,
          ),
          child: const Text(
            "Download Source Language",
          ),
        ),

        // Space - 16px
        _getHorizontalSpace16px,

        // Target language
        ElevatedButton(
          onPressed: () => _downloadModel(
            _selectedTargetLanguage.bcpCode,
          ),
          child: const Text(
            "Download Target Language",
          ),
        ),
      ],
    );
  }

  /// Used to delete the selected languages models.
  Widget get _getDeletedModelButtonsWidget {
    return Row(
      children: [
        // Source language
        ElevatedButton(
          onPressed: () => _deleteModel(
            _selectedSourceLanguage.bcpCode,
          ),
          child: const Text(
            "Download Source Language",
          ),
        ),

        // Space - 16px
        _getHorizontalSpace16px,

        // Target language
        ElevatedButton(
          onPressed: () => _deleteModel(
            _selectedTargetLanguage.bcpCode,
          ),
          child: const Text(
            "Download Target Language",
          ),
        ),
      ],
    );
  }

  /// <----

  /// Supportive functions ---->

  /// Used to decorate input fields, like border.
  InputDecoration get _textFieldDecoration {
    return const InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1,
        ),
      ),
    );
  }

  /// This will initialise On-device translator service based on
  /// selected source and target languages.
  void _initialiseTranslator() {
    _deviceTranslator = OnDeviceTranslator(
      sourceLanguage: _selectedSourceLanguage,
      targetLanguage: _selectedTargetLanguage,
    );
  }

  /// This will be used to release translator.
  void _releaseTranslator() {
    _deviceTranslator.close();
  }

  /// This will translate source content to target language.
  Future<void> _translateContent() async {
    // Removes focus from the current input field and
    // closes key board.
    FocusScope.of(context).unfocus();

    final sourceContent = _sourceContentController!.text;

    // Prevents translation if no content entered.
    if (sourceContent.isEmpty) return;

    // Prevents if selected both languages are same.
    if (_selectedSourceLanguage == _selectedTargetLanguage) {
      Toast().showMessage(
        'Both selected languages are same',
        context,
      );
      return;
    }

    // Translate content
    Toast().show(
      'Translating...',
      _deviceTranslator.translateText(sourceContent).then(
        (result) {
          setState(() {
            _translatedContentController!.text = result;
          });
          return 'Done';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to download model and show it's status accordingly.
  Future<void> _downloadModel(String languageCode) async {
    Toast().show(
      'Downloading model...',
      _modelManager.downloadModel(languageCode).then(
        (value) {
          return value ? 'success' : 'failed';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to check whether the model is
  /// downloaded or not and show it's status accordingly.
  Future<void> _isModelDownloaded(String languageCode) async {
    Toast().show(
      'Checking if model is downloaded...',
      _modelManager.isModelDownloaded(languageCode).then(
        (value) {
          return value ? 'downloaded' : 'not downloaded';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to delete model and show it's status accordingly.
  Future<void> _deleteModel(String languageCode) async {
    Toast().show(
      'Deleting model...',
      _modelManager.deleteModel(languageCode).then(
        (value) {
          return value ? 'success' : 'failed';
        },
      ),
      context,
      this,
    );
  }
}
