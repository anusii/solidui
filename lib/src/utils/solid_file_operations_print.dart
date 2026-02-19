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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

/// Print operations for the SolidUI file browser.

class SolidFilePrintOperations {
  const SolidFilePrintOperations._();

  /// Downloads font bytes via the printing package's built-in cache, avoiding
  /// repeated network requests.

  static Future<Uint8List> _loadFontBytes(String name, String url) {
    return PdfBaseCache.defaultCache.resolve(
      name: name,
      uri: Uri.parse(url),
    );
  }

  /// Downloads both header and content font bytes in parallel.
  /// Falls back to empty byte arrays when the network is unavailable; the
  /// isolate will then use built-in PDF fonts instead.

  static Future<(Uint8List, Uint8List)> _loadTextFonts() async {
    try {
      final results = await Future.wait([
        _loadFontBytes(notoSansFontName, notoSansFontUrl),
        _loadFontBytes(notoSansMonoFontName, notoSansMonoFontUrl),
      ]);

      return (results[0], results[1]);
    } catch (_) {
      return (Uint8List(0), Uint8List(0));
    }
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
    if (!isPrintableFile(fileName)) {
      if (!context.mounted) return;

      final ext = getEffectiveExtension(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot print files with "$ext" format. '
            'Supported formats: md, txt, json, yaml, yml, log, jpg, png, gif, '
            'pdf.',
          ),
          backgroundColor: ActionColors.error,
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    }

    // Check whether the file resides in the current app's data folder.

    final fullPath = PathUtils.combine(currentPath, fileName);
    final isInCurrentApp = await isPathInCurrentApp(fullPath);

    if (!isInCurrentApp) {
      if (!context.mounted) return;

      final shouldProceed = await _showCrossAppPrintWarning(context);

      if (!shouldProceed) return;
    }

    if (!context.mounted) return;

    final progress = ValueNotifier<String>('Loading file content…');
    var loadingShowing = false;

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
      if (!context.mounted) return;

      await getKeyFromUserIfRequired(
        context,
        const Text('Please enter your security key to print the file'),
      );

      if (!context.mounted) return;

      final normalisedPath = PathUtils.combine(currentPath, fileName);
      final fileContent = await readPod(
        normalisedPath,
        pathType: PathType.relativeToPod,
      );

      if (!context.mounted) return;

      if (fileContent == SolidFunctionCallStatus.fail.toString() ||
          fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        throw Exception(
          'Failed to read file – please check your connection and permissions',
        );
      }

      final cleanName = cleanEncryptedFileName(fileName);

      // Pre-generate the PDF bytes in a background isolate while the
      // loading dialogue is still visible. This avoids a deadlock that
      // occurs when compute() is called inside Printing.layoutPdf's
      // onLayout callback (the native print system blocks the main
      // thread waiting for onLayout, while compute() needs the main
      // isolate to receive the result).

      Uint8List pdfBytes;

      if (isTextPrintableFile(fileName)) {
        progress.value = 'Loading fonts…';

        final fonts = await _loadTextFonts();

        progress.value = 'Generating PDF…';

        pdfBytes = await compute(
          generateTextPdf,
          TextPdfParams(
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
      } else if (isImagePrintableFile(fileName)) {
        progress.value = 'Decoding image…';

        final imageBytes = decodeContentBytes(fileContent);

        progress.value = 'Generating PDF…';

        pdfBytes = await compute(
          generateImagePdf,
          ImagePdfParams(
            imageBytes: imageBytes,
            pageWidth: PdfPageFormat.a4.width,
            pageHeight: PdfPageFormat.a4.height,
            marginTop: PdfPageFormat.a4.marginTop,
            marginBottom: PdfPageFormat.a4.marginBottom,
            marginLeft: PdfPageFormat.a4.marginLeft,
            marginRight: PdfPageFormat.a4.marginRight,
          ),
        );
      } else if (isPdfFile(fileName)) {
        progress.value = 'Decoding PDF…';
        pdfBytes = decodeContentBytes(fileContent);
      } else {
        throw Exception('Unsupported printable file type');
      }

      progress.value = 'Opening print preview…';

      if (!context.mounted) return;

      Navigator.of(context).pop();
      loadingShowing = false;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: cleanName,
        dynamicLayout: false,
      );
    } catch (e) {
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
