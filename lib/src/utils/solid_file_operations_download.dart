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

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/utils/loading_dialog_controller.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

/// Download operations for SolidUI widgets.

class SolidFileDownloadOperations {
  const SolidFileDownloadOperations._();

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
  ///
  /// [pathType] controls how [filePath] is interpreted. It defaults to
  /// [PathType.relativeToPod], so existing callers are unaffected. When set to
  /// [PathType.absoluteUrl], [filePath] is treated as an absolute directory
  /// URL and the file is read straight from `filePath/<fileName>`. In that
  /// case the cross-app encryption warning is skipped, because the caller has
  /// supplied an explicit URL rather than a relative Pod path.

  static Future<void> downloadFile(
    BuildContext context,
    String fileName,
    String filePath, {
    PathType pathType = PathType.relativeToPod,
  }) async {
    try {
      final bool isAbsoluteUrl = pathType == PathType.absoluteUrl;

      // Resolve the full target. For an absolute URL the directory URL is
      // joined verbatim (preserving the scheme); otherwise the path is
      // resolved relative to the Pod root.

      final targetPath = isAbsoluteUrl
          ? PathUtils.combineUrl(filePath, fileName)
          : PathUtils.combine(filePath, fileName);

      // Check if the file belongs to another app's folder. If so, warn the
      // user that the file content may be encrypted. This check only applies
      // to relative Pod paths; an explicit absolute URL is taken at face value.

      if (!isAbsoluteUrl) {
        final isInCurrentAppFolder = await isPathInCurrentApp(targetPath);

        if (!isInCurrentAppFolder) {
          if (!context.mounted) return;

          final shouldProceed = await _showCrossAppDownloadWarning(context);

          if (!shouldProceed) {
            return;
          }
        }
      }

      if (!context.mounted) return;

      // Show loading dialog via a controller, so it can always be torn
      // down in the `finally` block — even if the originating context
      // becomes unmounted while the download is in flight.

      final loading = LoadingDialogController.show(
        context: context,
        title: 'Downloading',
      );

      try {
        // Get security key if required.

        if (!context.mounted) return;

        await getKeyFromUserIfRequired(
          context,
          const Text('Please enter your security key to download the file'),
        );

        if (!context.mounted) return;

        // Read file content from POD using the requested path type.

        final fileContent = await readPod(
          targetPath,
          pathType: pathType,
        );

        if (!context.mounted) return;

        if (fileContent == SolidFunctionCallStatus.fail.toString() ||
            fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
          throw Exception(
            'Download failed - please check your connection and permissions',
          );
        }

        // Save decrypted content to file.
        // Let user choose where to save the file.

        final cleanFileName = fileName.replaceAll('.enc.ttl', '');
        final outputFileUri = await FilePicker.saveFile(
          dialogTitle: 'Save file as:',
          fileName: cleanFileName,
          bytes: utf8.encode(fileContent),
        );

        if (outputFileUri == null) return;

        if (!context.mounted) return;

        // Show success message.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('File downloaded successfully to ${outputFileUri.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
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
      } finally {
        // Always tear down the loading dialog, even if we returned early
        // because the originating context became unmounted.

        loading.close();
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

  // static Future<void> _saveDecryptedContent(
  //   String content,
  //   String outputPath,
  // ) async {
  //   final file = File(outputPath);

  //   try {
  //     // Try to decode as base64 (for binary files).

  //     final bytes = base64Decode(content);
  //     await file.writeAsBytes(bytes);
  //   } catch (e) {
  //     // If base64 decode fails, treat as text content.

  //     await file.writeAsString(content);
  //   }
  // }

  /// Download a mixed batch of files and/or directories from the POD as a
  /// single zip archive.
  ///
  /// When any selected item resides outside the current app's folder the
  /// user is warned that decryption may not be possible and given the
  /// option to cancel.
  ///
  /// [currentPath] is the POD-relative directory path containing the items.
  ///
  /// [fileNames] is the list of file names to include.
  ///
  /// [directoryNames] is the list of directory names to include.
  ///
  /// [zipFileName] is the suggested default name for the saved zip file.

  static Future<void> downloadMultipleItems(
    BuildContext context, {
    required String currentPath,
    List<String> fileNames = const [],
    List<String> directoryNames = const [],
    required String zipFileName,
  }) async {
    final totalCount = fileNames.length + directoryNames.length;
    if (totalCount == 0) return;

    try {
      // Check whether any selected item falls outside the current app's
      // folder. If so we need to warn about possible decryption failure.

      final isInCurrentApp = await isPathInCurrentApp(currentPath);

      if (!isInCurrentApp) {
        if (!context.mounted) return;

        final shouldProceed = await _showCrossAppDownloadWarning(context);

        if (!shouldProceed) return;
      }

      if (!context.mounted) return;

      // Get security key if required.

      await getKeyFromUserIfRequired(
        context,
        const Text('Please enter your security key to download the files'),
      );

      if (!context.mounted) return;

      // Show a progress dialogue while downloading and zipping. We use a
      // [LoadingDialogController] so the dialog can be torn down
      // reliably in the `finally` block, regardless of whether the
      // originating context is still mounted.

      final progressNotifier = ValueNotifier<double>(0);

      final loading = LoadingDialogController.show(
        context: context,
        title: 'Downloading',
        child: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (_, progress, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('Reading files… '
                    '${(progress * 100).round()}%'),
              ],
            );
          },
        ),
      );

      try {
        final result = await downloadItemsAsZip(
          parentPath: currentPath,
          fileNames: fileNames,
          directoryNames: directoryNames,
          onProgress: (completed, total) {
            progressNotifier.value = total > 0 ? completed / total : 0;
          },
        );

        if (!context.mounted) return;

        if (!result.hasContent) {
          // Neither files nor empty directories were added – nothing
          // to save. Show a diagnostic message.

          final msg = result.entriesFound == 0
              ? 'No downloadable content was found.'
              : '${result.entriesFound} file(s) found but none could '
                  'be read. ${result.failed.length} error(s).';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: ActionColors.error,
              duration: const Duration(seconds: 5),
            ),
          );

          return;
        }

        // Write zip to the selected output path.
        // Let the user choose where to save the zip file.

        final outputFileUri = await FilePicker.saveFile(
          dialogTitle: 'Save zip as:',
          fileName: zipFileName,
          bytes: result.zipBytes,
        );

        if (outputFileUri == null) return;

        if (!context.mounted) return;

        // Build a concise success message listing what was included.

        final parts = <String>[];
        if (result.filesAdded > 0) {
          parts.add('${result.filesAdded} file(s)');
        }
        if (result.emptyDirsAdded > 0) {
          parts.add('${result.emptyDirsAdded} empty folder(s)');
        }
        final summary = parts.join(', ');

        final successMsg = result.failed.isEmpty
            ? 'Downloaded $summary to ${outputFileUri.path}'
            : 'Downloaded $summary to ${outputFileUri.path} '
                '(${result.failed.length} could not be read)';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor:
                result.failed.isEmpty ? ActionColors.success : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${e.toString()}'),
              backgroundColor: ActionColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        // Always tear down the progress dialogue and dispose the
        // notifier, even if we returned early because the originating
        // context became unmounted.

        loading.close();
        progressNotifier.dispose();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: ${e.toString()}'),
            backgroundColor: ActionColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
