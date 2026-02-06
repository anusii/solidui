/// Download operations for SolidUI.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/utils/solid_pod_helpers.dart';

/// Download operations for SolidUI widgets.

class SolidFileDownloadOperations {
  const SolidFileDownloadOperations._();

  /// Checks if a file is within the current app's data folder.
  ///
  /// Returns `true` if the file path starts with the app's data directory path,
  /// indicating that the current app can decrypt this file.
  /// Returns `false` if the file is from another app's folder, meaning
  /// decryption may fail as the security key is not available.

  static Future<bool> _isFileInCurrentAppFolder(String filePath) async {
    try {
      // Validate that the file path is a POD-relative path rather than an
      // absolute URL or empty string.

      if (filePath.trim().isEmpty) {
        debugPrint('Cannot check app folder ownership: file path is empty.');
        return false;
      }

      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        debugPrint(
          'Cannot check app folder ownership: expected a POD-relative '
              'path but received an absolute URL: $filePath',
        );
        return false;
      }

      final appDataPath = await getDataDirPath();
      if (appDataPath.isEmpty) {
        // If no app data path is available, we cannot determine ownership.

        return false;
      }

      // Normalise the file path by removing leading slashes for comparison.

      final normalisedFilePath =
      filePath.startsWith('/') ? filePath.substring(1) : filePath;

      return normalisedFilePath.startsWith(appDataPath);
    } catch (e) {
      debugPrint('Error checking app folder ownership: $e');
      return false;
    }
  }

  /// Shows a warning dialogue when attempting to download an encrypted file
  /// from another app's data folder.
  ///
  /// Returns `true` if the user chooses to proceed with the download.
  /// Returns `false` if the user cancels.

  static Future<bool> _showCrossAppDecryptionWarning(
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
            Expanded(child: Text('Decryption Warning')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This encrypted file belongs to another application\'s data '
                  'folder.',
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
              'Since this file was encrypted by a different application, '
                  'the security key required to decrypt it is not available. '
                  'The downloaded file will likely be unreadable or corrupted.',
            ),
            SizedBox(height: 16),
            Text(
              'Do you still wish to proceed with the download?',
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
            child: const Text('Download Anyway'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Default file download implementation.

  static Future<void> downloadFile(
      BuildContext context,
      String fileName,
      String filePath, {
        PathType? pathType,
      }) async {
    try {
      // Check if the file is an encrypted file from another app's folder.
      // If so, warn the user that decryption may not be possible.

      final isEncryptedFile = fileName.endsWith('.enc.ttl');

      if (isEncryptedFile) {
        final isInCurrentAppFolder = await _isFileInCurrentAppFolder(filePath);

        if (!isInCurrentAppFolder) {
          if (!context.mounted) return;

          final shouldProceed = await _showCrossAppDecryptionWarning(context);

          if (!shouldProceed) {
            return;
          }
        }
      }

      if (!context.mounted) return;

      // Let user choose where to save the file.

      final cleanFileName = fileName.replaceAll('.enc.ttl', '');
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file as:',
        fileName: cleanFileName,
      );

      if (outputFile == null) return;

      if (!context.mounted) return;

      // Show loading dialog.

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Downloading'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Please wait...'),
            ],
          ),
        ),
      );

      try {
        // Get security key if required.

        if (!context.mounted) return;

        await getKeyFromUserIfRequired(
          context,
          const Text('Please enter your security key to download the file'),
        );

        if (!context.mounted) return;

        // Read file content from POD.

        // dc 20260107: the `basePath` is heavily involved in the file-browsing
        // codebase, and this leads to a leading forward slash in `filePath`,
        // e.g., /myapp/encryption/ind-keys.ttl.
        // This format triggers an error when extracting data from the turtle
        // content due to double `//` in the subject of triples.
        // Below is a temporary workaround but a better solution is needed to
        // fully resolve this issue (e.g., refactor the file-browsing code to
        // use `PathType` instead of `basePath`).

        final fileContent = await readPod(
          [
            filePath.startsWith('/') ? filePath.substring(1) : filePath,
            fileName,
          ].join('/'),
          pathType: pathType ?? PathType.relativeToPod,
        );

        if (!context.mounted) return;

        // Close loading dialog.

        Navigator.of(context).pop();

        if (fileContent == SolidFunctionCallStatus.fail.toString() ||
            fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
          throw Exception(
            'Download failed - please check your connection and permissions',
          );
        }

        // Save decrypted content to file.

        await _saveDecryptedContent(fileContent, outputFile);

        if (!context.mounted) return;

        // Show success message.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded successfully to $outputFile'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog if still open.

          Navigator.of(context).pop();

          // Show error message.

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Save decrypted content to a file.

  static Future<void> _saveDecryptedContent(
      String content,
      String outputPath,
      ) async {
    final file = File(outputPath);

    try {
      // Try to decode as base64 (for binary files).

      final bytes = base64Decode(content);
      await file.writeAsBytes(bytes);
    } catch (e) {
      // If base64 decode fails, treat as text content.

      await file.writeAsString(content);
    }
  }
}
