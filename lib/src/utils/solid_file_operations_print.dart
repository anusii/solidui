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
import 'package:solidui/src/utils/loading_dialog_controller.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

// Printable file type constants.

/// File extensions supported for printing.

const Set<String> printableExtensions = {
  '.md',
  '.txt',
  '.json',
  '.yaml',
  '.yml',
  '.log',
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.pdf',
};

/// Text-based extensions rendered as formatted text.

const Set<String> textPrintableExtensions = {
  '.md',
  '.txt',
  '.json',
  '.yaml',
  '.yml',
  '.log',
};

/// Image-based extensions.

const Set<String> imagePrintableExtensions = {'.jpg', '.jpeg', '.png', '.gif'};

// Printable file type queries.

/// Returns the effective file extension after stripping the `.enc.ttl` suffix
/// used by solidpod for encrypted files.

String getEffectiveExtension(String fileName) {
  final clean = fileName.replaceAll('.enc.ttl', '');
  final dotIndex = clean.lastIndexOf('.');
  if (dotIndex == -1) return '';

  return clean.substring(dotIndex).toLowerCase();
}

/// Whether [fileName] has a printable file extension.

bool isPrintableFile(String fileName) {
  return printableExtensions.contains(getEffectiveExtension(fileName));
}

/// Whether [fileName] is a text-based printable file.

bool isTextPrintableFile(String fileName) {
  return textPrintableExtensions.contains(getEffectiveExtension(fileName));
}

/// Whether [fileName] is an image-based printable file.

bool isImagePrintableFile(String fileName) {
  return imagePrintableExtensions.contains(getEffectiveExtension(fileName));
}

/// Whether [fileName] is a PDF file.

bool isPdfFile(String fileName) {
  return getEffectiveExtension(fileName) == '.pdf';
}

// Content helpers.

/// Tries to base64-decode [content]; falls back to raw UTF-8 bytes.

Uint8List decodeContentBytes(String content) {
  try {
    return base64Decode(content);
  } on FormatException {
    return Uint8List.fromList(utf8.encode(content));
  }
}

// Google Fonts CDN URLs (from PdfGoogleFonts generated code).

/// Noto Sans Regular – used for page headers in printed documents.

const String notoSansFontUrl = 'https://'
    'fonts.gstatic.com/s/notosans/v36/'
    'o-0mIpQlx3QUlC5A4PNB6Ryti20_6n1iPHjcz6L1SoM-jCpoiyD9A99d41P6zHtY.ttf';

/// Font cache key for Noto Sans Regular.

const String notoSansFontName = 'NotoSans-Regular';

/// Noto Sans Mono Regular – used for body text in printed documents.

const String notoSansMonoFontUrl = 'https://'
    'fonts.gstatic.com/s/notosansmono/v30/'
    'BngrUXNETWXI6LwhGYvaxZikqZqK6fBq6kPvUce2oAZcdthSBUsYck4-_FNJ49rXVEQQL8Y.ttf';

/// Font cache key for Noto Sans Mono Regular.

const String notoSansMonoFontName = 'NotoSansMono-Regular';

// PDF generation parameter classes – all fields are isolate-safe so the
// objects can be sent across isolate boundaries by compute().

/// Parameters for [generateTextPdf].

class TextPdfParams {
  /// The text content to render.

  final String content;

  /// File name shown in the page header.

  final String fileName;

  /// Page dimensions and margins.

  final double pageWidth;
  final double pageHeight;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  /// Raw TTF bytes for the header font. Empty means use a built-in fallback.

  final Uint8List headerFontBytes;

  /// Raw TTF bytes for the body font. Empty means use a built-in fallback.

  final Uint8List contentFontBytes;

  const TextPdfParams({
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

/// Parameters for [generateImagePdf].

class ImagePdfParams {
  /// Raw image bytes (JPEG, PNG, or GIF).

  final Uint8List imageBytes;

  /// Page dimensions and margins.

  final double pageWidth;
  final double pageHeight;
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  const ImagePdfParams({
    required this.imageBytes,
    required this.pageWidth,
    required this.pageHeight,
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
  });
}

// Top-level PDF generation functions for compute().

/// Generates a paginated text PDF.
///
/// This is a top-level function so it can be called from a background isolate
/// via [compute]. Font bytes are reconstructed into [pw.Font] objects inside
/// the isolate; when empty the built-in Latin-1 fonts are used as a fallback.

Future<Uint8List> generateTextPdf(TextPdfParams p) async {
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
      build: (pw.Context ctx) {
        final style = pw.TextStyle(font: contentFont, fontSize: 10);

        // Split into individual lines so MultiPage can paginate between
        // them. A single pw.Text holding the entire content would exceed
        // the page height for long files and is not a SpanningWidget.

        return p.content.split('\n').map((line) {
          return pw.Text(line.isEmpty ? ' ' : line, style: style);
        }).toList();
      },
    ),
  );

  return await doc.save();
}

/// Generates a single-page image PDF.
///
/// This is a top-level function so it can be called from a background isolate
/// via [compute].

Future<Uint8List> generateImagePdf(ImagePdfParams p) async {
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
      build: (pw.Context ctx) =>
          pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
    ),
  );

  return await doc.save();
}

// Main print UI operations.

/// Print operations for the SolidUI file browser.

class SolidFilePrintOperations {
  const SolidFilePrintOperations._();

  /// Downloads font bytes via the printing package's built-in cache, avoiding
  /// repeated network requests.

  static Future<Uint8List> _loadFontBytes(String name, String url) {
    return PdfBaseCache.defaultCache.resolve(name: name, uri: Uri.parse(url));
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

    // Use a [LoadingDialogController] so the dialog can always be torn
    // down via its captured context, even if the originating context
    // becomes unmounted while the asynchronous work is in flight.

    final loading = LoadingDialogController.show(
      context: context,
      title: 'Preparing to Print',
      child: ValueListenableBuilder<String>(
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
    );

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

      // Tear down the loading dialogue before opening the system print
      // preview, so the two modal layers do not stack.

      loading.close();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: cleanName,
        dynamicLayout: false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: ActionColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always tear down the loading dialogue and release the progress
      // notifier, even if we returned early because the originating
      // context became unmounted. [LoadingDialogController.close] is
      // idempotent, so calling it again here is safe.

      loading.close();
      progress.dispose();
    }
  }

  /// Shows a warning when printing a file from another app's data folder.
  ///
  /// Returns `true` if the user chooses to proceed, `false` otherwise.

  static Future<bool> _showCrossAppPrintWarning(BuildContext context) async {
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
