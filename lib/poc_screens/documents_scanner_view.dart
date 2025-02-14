import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentsScannerView extends StatefulWidget {
  const DocumentsScannerView({super.key});

  @override
  State<DocumentsScannerView> createState() => _DocumentsScannerViewState();
}

class _DocumentsScannerViewState extends State<DocumentsScannerView> {
  // Document scanner service instance.
  DocumentScanner? _documentScanner;

  // Document scanner result.
  DocumentScanningResult? _documentScanningResult;

  @override
  void dispose() {
    // Closes the scanner services and releases resources.
    _documentScanner?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Scanner',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show scanner options
            _getScannerOptionsWidget,

            // PDF result view
            _getPdfResultView,

            // Image result view
            _getImageResultView,
          ],
        ),
      ),
    );
  }

  /// Widgets ---->

  /// Below is used to show the scanner options like PDF, JPEG
  Widget get _getScannerOptionsWidget {
    return Row(
      children: [
        // Scan PDF
        ElevatedButton(
          onPressed: () {
            _startScanning(
              DocumentFormat.pdf,
            );
          },
          child: const Text('Scan PDF'),
        ),

        // Scan JPEG
        ElevatedButton(
          onPressed: () {
            _startScanning(
              DocumentFormat.jpeg,
            );
          },
          child: const Text('Scan JPEG'),
        ),
      ],
    );
  }

  /// This will be used to show PDF result.
  Widget get _getPdfResultView {
    // Whether the scanning result is not received or no pdf found.
    if (_documentScanningResult == null ||
        _documentScanningResult!.pdf == null) {
      return const SizedBox.shrink();
    }

    // Used to show the resultant PDF.
    return Column(
      children: [
        // Header view
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
          child: const Text(
            'PDF Document:',
          ),
        ),

        // PDF Viewer.
        SizedBox(
          height: 300,
          child: PDFView(
            filePath: _documentScanningResult!.pdf!.uri,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
          ),
        ),
      ],
    );
  }

  /// This will be used to show JPEG image result.
  Widget get _getImageResultView {
    // Whether the scanning result is not received or no images are found.
    if (_documentScanningResult == null ||
        _documentScanningResult!.images.isEmpty) {
      return const SizedBox.shrink();
    }

    // Used to show the first image from the result.
    return Column(
      children: [
        // Header view
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
          child: const Text(
            'Images [0]:',
          ),
        ),

        // Result Image Viewer.
        SizedBox(
          height: 300,
          child: Image.file(
            File(
              _documentScanningResult!.images.first,
            ),
          ),
        ),
      ],
    );
  }

  /// <---

  /// Supportive methods --->

  /// This will be used to start scanning the document.
  Future<void> _startScanning(DocumentFormat format) async {
    try {
      // Release previous instances and creates a new
      // instance with selected format.
      _initialiseScanner(format);

      // Scan the document.
      _documentScanningResult = await _documentScanner?.scanDocument();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  /// This will be used to initialise scanner with selected document format.
  void _initialiseScanner(DocumentFormat format) {
    // It will release the scanner service instance if already created.
    _documentScanner?.close();

    // Initialise with provided format and default options.
    _documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormat: format,

        // Enable or disable the capability to import
        // from the photo gallery. default = false.
        isGalleryImport: false,

        // Sets the scanner mode which determines what features are enabled,
        // like base, filter or full.
        mode: ScannerMode.full,

        // Sets a page limit for the maximum number of pages that can
        // be scanned in a single scanning session.
        pageLimit: 1,
      ),
    );
  }

  /// <---
}
