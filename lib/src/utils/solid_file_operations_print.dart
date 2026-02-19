/// Print operations for SolidUI.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Tony Chen

library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

// Top-level functions for compute().

/// Generates a paginated text PDF in a background isolate.

Future<Uint8List> _generateTextPdf(_TextPdfParams p) async {
  final headerFont = p.headerFontBytes.isNotEmpty
      ? pw.Font.ttf(p.headerFontBytes.buffer.asByteData())
      : pw.Font.helvetica();

  final contentFont = p.contentFontBytes.isNotEmpty
      ? pw.Font.ttf(p.contentFontBytes.buffer.asByteData())
      : pw.Font.courier();

  final format = PdfPageFormat(
    p.pageWidth,
    p.pageHeight,
    marginTop: p.marginTop,
    marginBottom: p.marginBottom,
    marginLeft: p.marginLeft,
    marginRight: p.marginRight,
  );

  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      header: (pw.Context ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          p.fileName,
          style: pw.TextStyle(
            font: headerFont,
            color: PdfColors.grey600,
            fontSize: 10,
          ),
        ),
      ),
      build: (pw.Context ctx) => [
        pw.Text(
          p.content,
          style: pw.TextStyle(
            font: contentFont,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );

  return await doc.save();
}

/// Generates a single-page image PDF in a background isolate.

Future<Uint8List> _generateImagePdf(_ImagePdfParams p) async {
  final format = PdfPageFormat(
    p.pageWidth,
    p.pageHeight,
    marginTop: p.marginTop,
    marginBottom: p.marginBottom,
    marginLeft: p.marginLeft,
    marginRight: p.marginRight,
  );

  final doc = pw.Document();
  final image = pw.MemoryImage(p.imageBytes);

  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (pw.Context ctx) => pw.Center(
        child: pw.Image(image, fit: pw.BoxFit.contain),
      ),
    ),
  );

  return await doc.save();
}

// Parameter classes for compute().

class _TextPdfParams {
  final String content;
  final String fileName;
  final double pageWidth;
  final double pageHeight;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  final Uint8List headerFontBytes;
  final Uint8List contentFontBytes;

  const _TextPdfParams({
    required this.content,
    required this.fileName,
    required this.pageWidth,
    required this.pageHeight,
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
    required this.headerFontBytes,
    required this.contentFontBytes,
  });
}

class _ImagePdfParams {
  final Uint8List imageBytes;
  final double pageWidth;
  final double pageHeight;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  const _ImagePdfParams({
    required this.imageBytes,
    required this.pageWidth,
    required this.pageHeight,
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
  });
}

// Public APIs.

/// Print operations for the SolidUI file browser.

class SolidFilePrintOperations {
  const SolidFilePrintOperations._();

  // Google Fonts CDN URLs (mirrored from PdfGoogleFonts generated code).

  static const _notoSansUrl = 'https://fonts.gstatic.com/s/notosans/v36/'
      'o-0mIpQlx3QUlC5A4PNB6Ryti20_6n1iPHjcz6L1SoM-jCpoiyD9A99d41P6zHtY.ttf';

  static const _notoSansMonoUrl =
      'https://fonts.gstatic.com/s/notosansmono/v30/'
      'BngrUXNETWXI6LwhGYvaxZikqZqK6fBq6kPvUce2oAZcdthSBUsYck4-_FNJ49rXVEQQL8Y.ttf';

  /// Downloads font bytes via the printing package's built-in cache, avoiding
  /// repeated network requests.

  static Future<Uint8List> _loadFontBytes(String name, String url) async {
    return PdfBaseCache.defaultCache.resolve(
      name: name,
      uri: Uri.parse(url),
    );
  }

  // Main entry point.

  /// Fetches and prints a single file from the POD.
  ///
  /// Handles decryption for files within the current app's data folder and
  /// warns the user when attempting to print files from other app folders
  /// where decryption may not be possible.

  static Future<void> printFile(
    BuildContext context, {
    required String fileName,
    required String currentPath,
  }) async {
    debugPrint('[Print] printFile called: fileName=$fileName, '
        'currentPath=$currentPath');

    if (!isPrintableFile(fileName)) {
      final ext = getEffectiveExtension(fileName);
      debugPrint('[Print] File not printable (ext=$ext), aborting');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot print files with "$ext" format. '
            'Supported formats: md, txt, json, yaml, log, jpg, png, gif, pdf.',
          ),
          backgroundColor: ActionColors.error,
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    }

    debugPrint('[Print] File is printable, checking isPathInCurrentApp…');

    final fullPath = PathUtils.combine(currentPath, fileName);
    final isInCurrentApp = await isPathInCurrentApp(fullPath);

    debugPrint('[Print] isPathInCurrentApp=$isInCurrentApp for $fullPath');

    if (!isInCurrentApp) {
      if (!context.mounted) return;

      debugPrint('[Print] Showing cross-app warning dialogue');
      final shouldProceed = await _showCrossAppPrintWarning(context);
      debugPrint('[Print] Cross-app warning result: proceed=$shouldProceed');

      if (!shouldProceed) return;
    }

    if (!context.mounted) {
      debugPrint('[Print] Context not mounted after isPathInCurrentApp check');
      return;
    }

    // Use a ValueNotifier so we can update the progress message while the
    // loading dialogue is visible.

    final progress = ValueNotifier<String>('Loading file content…');
    var loadingShowing = false;

    debugPrint('[Print] Showing loading dialogue');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Preparing to Print'),
        content: ValueListenableBuilder<String>(
          valueListenable: progress,
          builder: (_, message, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
    loadingShowing = true;

    try {
      if (!context.mounted) {
        debugPrint('[Print] Context not mounted before getKeyFromUser');
        return;
      }

      debugPrint('[Print] Calling getKeyFromUserIfRequired…');

      await getKeyFromUserIfRequired(
        context,
        const Text('Please enter your security key to print the file'),
      );

      debugPrint('[Print] getKeyFromUserIfRequired completed');

      if (!context.mounted) {
        debugPrint('[Print] Context not mounted after getKeyFromUser');
        return;
      }

      final normalisedPath = PathUtils.combine(currentPath, fileName);
      debugPrint('[Print] Reading file from POD: $normalisedPath');

      final fileContent = await readPod(
        normalisedPath,
        pathType: PathType.relativeToPod,
      );

      debugPrint('[Print] readPod completed, '
          'content length=${fileContent.length}');

      if (!context.mounted) {
        debugPrint('[Print] Context not mounted after readPod');
        return;
      }

      if (fileContent == SolidFunctionCallStatus.fail.toString() ||
          fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        throw Exception(
          'Failed to read file – please check your connection and permissions',
        );
      }

      final cleanName = cleanEncryptedFileName(fileName);

      debugPrint('[Print] cleanName=$cleanName, '
          'isText=${isTextPrintableFile(fileName)}, '
          'isImage=${isImagePrintableFile(fileName)}, '
          'isPdf=${isPdfFile(fileName)}');

      // Load fonts / decode content whilst the loading dialogue is still
      // visible so the user sees progress.

      // Pre-generate the PDF bytes in a background isolate while the
      // loading dialogue is still visible. This avoids a deadlock that
      // occurs when compute() is called inside Printing.layoutPdf's
      // onLayout callback (the native print system blocks the main
      // thread waiting for onLayout, while compute() needs the main
      // isolate to receive the result).

      Uint8List pdfBytes;

      if (isTextPrintableFile(fileName)) {
        progress.value = 'Loading fonts…';
        debugPrint('[Print] Downloading font bytes…');

        final fonts = await _loadTextFonts();

        debugPrint('[Print] Font bytes ready '
            '(header=${fonts.$1.length}, content=${fonts.$2.length})');

        progress.value = 'Generating PDF…';
        debugPrint('[Print] Generating text PDF in background isolate…');

        pdfBytes = await compute(
          _generateTextPdf,
          _TextPdfParams(
            content: fileContent,
            fileName: cleanName,
            pageWidth: PdfPageFormat.a4.width,
            pageHeight: PdfPageFormat.a4.height,
            marginTop: PdfPageFormat.a4.marginTop,
            marginBottom: PdfPageFormat.a4.marginBottom,
            marginLeft: PdfPageFormat.a4.marginLeft,
            marginRight: PdfPageFormat.a4.marginRight,
            headerFontBytes: fonts.$1,
            contentFontBytes: fonts.$2,
          ),
        );

        debugPrint('[Print] Text PDF generated, ${pdfBytes.length} bytes');
      } else if (isImagePrintableFile(fileName)) {
        progress.value = 'Decoding image…';

        final imageBytes = _decodeContentBytes(fileContent);

        debugPrint('[Print] Image decoded: ${imageBytes.length} bytes');

        progress.value = 'Generating PDF…';
        debugPrint('[Print] Generating image PDF in background isolate…');

        pdfBytes = await compute(
          _generateImagePdf,
          _ImagePdfParams(
            imageBytes: imageBytes,
            pageWidth: PdfPageFormat.a4.width,
            pageHeight: PdfPageFormat.a4.height,
            marginTop: PdfPageFormat.a4.marginTop,
            marginBottom: PdfPageFormat.a4.marginBottom,
            marginLeft: PdfPageFormat.a4.marginLeft,
            marginRight: PdfPageFormat.a4.marginRight,
          ),
        );

        debugPrint('[Print] Image PDF generated, ${pdfBytes.length} bytes');
      } else if (isPdfFile(fileName)) {
        progress.value = 'Decoding PDF…';
        pdfBytes = _decodeContentBytes(fileContent);
        debugPrint('[Print] PDF decoded: ${pdfBytes.length} bytes');
      } else {
        throw Exception('Unsupported printable file type');
      }

      progress.value = 'Opening print preview…';

      if (!context.mounted) return;

      Navigator.of(context).pop();
      loadingShowing = false;

      debugPrint('[Print] Opening native print dialogue…');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          debugPrint('[Print] onLayout called, returning pre-generated '
              'PDF (${pdfBytes.length} bytes)');

          return pdfBytes;
        },
        name: cleanName,
        dynamicLayout: false,
      );

      debugPrint('[Print] Printing.layoutPdf returned');

      debugPrint('[Print] printFile completed successfully');
    } catch (e, stackTrace) {
      debugPrint('[Print] ERROR: $e');
      debugPrint('[Print] Stack trace:\n$stackTrace');

      if (context.mounted) {
        if (loadingShowing) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: ActionColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      progress.dispose();
    }
  }

  // Font loading.

  /// Downloads both header and content font bytes, returning them as a record.
  /// Falls back to empty byte arrays when the network is unavailable; the
  /// isolate will then use built-in PDF fonts instead.

  static Future<(Uint8List, Uint8List)> _loadTextFonts() async {
    try {
      final results = await Future.wait([
        _loadFontBytes('NotoSans-Regular', _notoSansUrl),
        _loadFontBytes('NotoSansMono-Regular', _notoSansMonoUrl),
      ]);

      return (results[0], results[1]);
    } catch (e) {
      debugPrint('[Print] Font download failed ($e), '
          'will use built-in Latin-1 fonts');

      return (Uint8List(0), Uint8List(0));
    }
  }

  // Content helpers.

  /// Tries to base64-decode [content]; falls back to raw UTF-8 bytes.

  static Uint8List _decodeContentBytes(String content) {
    try {
      return base64Decode(content);
    } on FormatException {
      return Uint8List.fromList(utf8.encode(content));
    }
  }

  // Dialogues.

  /// Shows a warning when printing a file from another app's data folder.
  ///
  /// Returns `true` if the user chooses to proceed, `false` otherwise.

  static Future<bool> _showCrossAppPrintWarning(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Cross-App Print Warning')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This file belongs to another application\'s data folder.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              'The file browser can browse files across all app folders in '
              'your POD, but can only decrypt files within the current app\'s '
              'data folder.',
            ),
            SizedBox(height: 12),
            Text(
              'The file content may be encrypted and cannot be decrypted. '
              'Printing may produce unreadable output.',
            ),
            SizedBox(height: 16),
            Text(
              'Do you still wish to proceed?',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Print Anyway'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
