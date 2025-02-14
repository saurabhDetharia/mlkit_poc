import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

import '../../widgets/activity_indicator.dart';

class EntityExtractionView extends StatefulWidget {
  const EntityExtractionView({super.key});

  @override
  State<EntityExtractionView> createState() => _EntityExtractionViewState();
}

class _EntityExtractionViewState extends State<EntityExtractionView> {
  // For extraction service
  EntityExtractor? _entityExtractor;

  // To handle language model.
  final _modelManager = EntityExtractorModelManager();

  // To control the input field.
  late TextEditingController _extractorInputTextController;

  // Indicates selected language.
  late EntityExtractorLanguage _selectedLanguage;

  // List of the entities once extracted from the content.
  final _entities = <EntityAnnotation>[];

  @override
  void initState() {
    super.initState();

    // Set English as default language.
    _selectedLanguage = EntityExtractorLanguage.english;

    // Initialise the extraction service instance.
    _initialiseExtractor();

    // Initialise input field controller.
    _extractorInputTextController = TextEditingController(
      text: 'Meet me at 1600 Amphitheatre Parkway, Mountain View, CA, 94043 '
          'Let’s organize a meeting to discuss.'
          'The CEO of Apple , Tim Cook, announced today that the company will '
          'be releasing a new iPhone model in the upcoming fall season, '
          'which will be manufactured in China. Call the restaurant at '
          '555-555-1234 to pay for dinner. My card number is 4111-1111-1111-1111.',
    );
  }

  @override
  void dispose() {
    // Close the entity extractor service instance and release it.
    _entityExtractor?.close();

    // Release text controller
    _extractorInputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Entity Extractor',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Space - 32px
              _getSpaceVertically32,

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    'Enter text (${_selectedLanguage.name})',
                  ),

                  // Language selection drop-down.
                  _buildDropdown,
                ],
              ),

              // Input field
              _getExtractionContentInputWidget,

              // Space - 8px
              _getSpaceVertically8,

              // Extract button
              _getExtractorButtonWidget,

              // Space - 8px
              _getSpaceVertically8,

              // Check model
              _getCheckModelButtonWidget,

              // Space - 8px
              _getSpaceVertically8,

              // Model actions view
              _getModelActionsViewWidget,

              // Space - 8px
              _getSpaceVertically8,

              // Results
              _getResultsView,
            ],
          ),
        ),
      ),
    );
  }

  /// Widgets --->

  /// Used to space vertically of 32px
  Widget get _getSpaceVertically32 {
    return const SizedBox(
      height: 32,
    );
  }

  /// Used to space vertically of 16px
  Widget get _getSpaceVertically8 {
    return const SizedBox(
      height: 8,
    );
  }

  /// Used to get content for extractor.
  Widget get _getExtractionContentInputWidget {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
        ),
      ),
      child: TextField(
        controller: _extractorInputTextController,
        decoration: const InputDecoration(border: InputBorder.none),
        maxLines: null,
      ),
    );
  }

  /// Used to show the language selection drop-down.
  Widget get _buildDropdown {
    return DropdownButton<EntityExtractorLanguage>(
      value: _selectedLanguage,
      items: EntityExtractorLanguage.values.map(
        (language) {
          return DropdownMenuItem(
            value: language,
            child: Text(language.name),
          );
        },
      ).toList(),
      onChanged: (EntityExtractorLanguage? selectedLang) {
        if (selectedLang != null) {
          // Update the Selected language.
          _selectedLanguage = selectedLang;

          // Re-initialises translator with new selected languages.
          _initialiseExtractor();

          setState(() {});
        }
      },
    );
  }

  /// Used as a extract entities button.
  Widget get _getExtractorButtonWidget {
    return ElevatedButton(
      onPressed: _extractEntities,
      child: const Text('Extract Entities'),
    );
  }

  /// Used as a button to check model exists.
  Widget get _getCheckModelButtonWidget {
    return ElevatedButton(
      onPressed: _isModelDownloaded,
      child: const Text('Check Model'),
    );
  }

  /// Used as a row of buttons to download or delete models.
  Widget get _getModelActionsViewWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Download button
        ElevatedButton(
          onPressed: _downloadModel,
          child: const Text('Download Model'),
        ),

        // Download button
        ElevatedButton(
          onPressed: _deleteModel,
          child: const Text('Delete Model'),
        ),
      ],
    );
  }

  /// Used to show the results.
  Widget get _getResultsView {
    // If no results found, do not show anything.
    if (_entities.isEmpty) {
      return const Text('--');
    }

    // List of all entities
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Result',
          style: TextStyle(fontSize: 20),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entities.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              collapsedBackgroundColor: Colors.grey.withAlpha(50),
              title: Text(
                _entities[index].text,
              ),
              children: _entities[index].entities.map(
                (e) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.toString(),
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  /// <---

  /// Support Methods --->

  /// Below is used to re-initialise the Entity
  /// extractor instance for the selected language.
  Future<void> _initialiseExtractor() async {
    // Closes the current extractor.
    if (_entityExtractor != null) {
      await _entityExtractor!.close();
    }

    // Check the model exists, download if not.
    final isModelExist = await _modelManager.isModelDownloaded(
      _selectedLanguage.name,
    );

    // If model doesn't exist, download model.
    if (!isModelExist) {
      await _downloadModel();
    }

    // Re-initialise extractor with selected language.
    _entityExtractor = EntityExtractor(language: _selectedLanguage);
  }

  /// This will be used to download model and show it's status accordingly.
  Future<void> _downloadModel() async {
    Toast().show(
      'Downloading model...',
      _modelManager.downloadModel(_selectedLanguage.name).then(
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
  Future<void> _isModelDownloaded() async {
    Toast().show(
      'Checking if model is downloaded...',
      _modelManager.isModelDownloaded(_selectedLanguage.name).then(
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
      _modelManager.deleteModel(_selectedLanguage.name).then(
        (value) {
          return value ? 'success' : 'failed';
        },
      ),
      context,
      this,
    );
  }

  /// This will be used to extract the entities from the input.
  Future<void> _extractEntities() async {
    // Removes focus from the input field.
    FocusScope.of(context).unfocus();

    // extract the entities.
    final result = await _entityExtractor!.annotateText(
      _extractorInputTextController.text,
    );

    // Clear the results list and show results on UI.
    setState(() {
      _entities
        ..clear()
        ..addAll(result);
    });
  }

  /// <---}
}
