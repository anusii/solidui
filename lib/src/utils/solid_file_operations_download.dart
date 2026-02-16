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

import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

/// Download operations for SolidUI widgets.

class SolidFileDownloadOperations {
  const SolidFileDownloadOperations._();

  /// Checks if a file is within the current app's folder on the POD.
  ///
  /// Returns `true` if the file belongs to the current app, indicating that
  /// the current app can decrypt this file.
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

      // Resolve the relative file path into a full URL for reliable
      // comparison.

      final normalisedPath = PathUtils.normalise(filePath);
      final fileUrl = await getFileUrl(normalisedPath);

      // Derive the current app name from getDataDirPath(), which returns
      // "APP_NAME/data". The first segment is the app name.

      final appDataPath = await getDataDirPath();
      if (appDataPath.isEmpty) return false;

      final currentAppName = appDataPath.split('/').first;
      if (currentAppName.isEmpty) return false;

      // Build the current app's root directory URL and check whether the
      // file URL falls under it. getDirUrl appends a trailing slash, which
      // prevents false positives (e.g., "myapp2" matching "myapp").

      final appRootUrl = await getDirUrl(currentAppName);

      return fileUrl.startsWith(appRootUrl);
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

  static Future<bool> _showCrossAppDownloadWarning(
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
            Expanded(child: Text('Cross-App Download Warning')),
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
              'The file content may be encrypted by the other application. '
              'If so, the security key required to decrypt it is not '
              'available, and the downloaded file might be unreadable.',
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
    String filePath,
  ) async {
    try {
      // Check if the file belongs to another app's folder. If so, warn the
      // user that the file content may be encrypted.

      final isInCurrentAppFolder = await _isFileInCurrentAppFolder(filePath);

      if (!isInCurrentAppFolder) {
        if (!context.mounted) return;

        final shouldProceed = await _showCrossAppDownloadWarning(context);

        if (!shouldProceed) {
          return;
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

        // Read file content from POD. All paths are relative to the Pod
        // root, so we always use PathType.relativeToPod.

        final normalisedPath = PathUtils.combine(filePath, fileName);
        final fileContent = await readPod(
          normalisedPath,
          pathType: PathType.relativeToPod,
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
