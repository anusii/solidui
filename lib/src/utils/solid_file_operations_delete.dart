/// Delete operations for SolidUI.
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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/utils/loading_dialog_controller.dart';
import 'package:solidui/src/utils/path_utils.dart';

/// Delete operations for SolidUI widgets.

class SolidFileDeleteOperations {
  const SolidFileDeleteOperations._();

  /// Default file deletion implementation.
  ///
  /// The [filePath] should be a directory path relative to the Pod root,
  /// e.g., `myapp/data` or `myapp/data/subfolder`.
  ///
  /// [pathType] controls how [filePath] is interpreted. It defaults to
  /// [PathType.relativeToPod], so existing callers are unaffected. When set to
  /// [PathType.absoluteUrl], [filePath] is treated as an absolute directory
  /// URL and the file at `filePath/<fileName>` is deleted by that URL directly.

  static Future<void> deletePodFile(
    BuildContext context,
    String fileName,
    String filePath, {
    VoidCallback? onSuccess,
    PathType pathType = PathType.relativeToPod,
  }) async {
    try {
      // Show confirmation dialog.

      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete "$fileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (!context.mounted || confirm != true) return;

      // Show loading dialog via a controller, so it can always be torn
      // down in the `finally` block — even if the originating context
      // becomes unmounted while the deletion is in flight.

      final loading = LoadingDialogController.show(
        context: context,
        title: 'Deleting',
      );

      try {
        // Resolve the absolute URL of the file to delete. For an absolute URL
        // the directory URL is joined verbatim (preserving the scheme);
        // otherwise the relative path is combined and resolved to a URL. Use
        // PathUtils to ensure no leading slashes, which would cause double
        // slashes in the generated URL.

        final String fileUrl = pathType == PathType.absoluteUrl
            ? PathUtils.combineUrl(filePath, fileName)
            : await getFileUrl(PathUtils.combine(filePath, fileName));

        // Delete the file (this also handles the ACL file automatically).

        try {
          await deleteFile(fileUrl: fileUrl);
        } catch (e) {
          // Only rethrow if it's not a 404 error.

          if (!e.toString().contains('404') &&
              !e.toString().contains('NotFoundHttpError')) {
            rethrow;
          }
        }

        if (!context.mounted) return;

        // Show success message.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File "$fileName" deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Call success callback if provided.

        onSuccess?.call();
      } catch (e) {
        if (context.mounted) {
          final message = e.toString().contains('404') ||
                  e.toString().contains('NotFoundHttpError')
              ? 'File not found or already deleted'
              : 'Delete failed: ${e.toString()}';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
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
            content: Text('Delete error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Delete a mixed batch of files and/or directories from the POD.
  ///
  /// Shows a unified confirmation dialog listing every item, a progress
  /// indicator during the operation, and a result summary afterwards.
  ///
  /// [currentPath] is the directory path relative to the Pod root where
  /// the items reside (e.g. `myapp/data`).
  ///
  /// [fileNames] is the list of file names to delete.
  ///
  /// [directoryNames] is the list of directory names to delete.
  ///
  /// [onSuccess] is called once the operation completes (even partially).

  static Future<void> deleteMultipleItems(
    BuildContext context, {
    required String currentPath,
    List<String> fileNames = const [],
    List<String> directoryNames = const [],
    VoidCallback? onSuccess,
  }) async {
    final totalCount = fileNames.length + directoryNames.length;
    if (totalCount == 0) return;

    // Build a concise description for the confirmation dialog.  When a
    // single item is selected show its name; otherwise just show the count.

    final isSingle = totalCount == 1;
    final singleName = isSingle
        ? (fileNames.isNotEmpty
            ? fileNames.first
            : '${directoryNames.first} (folder)')
        : '';
    final subject = isSingle ? '"$singleName"' : '$totalCount items';

    // Compose a brief breakdown when multiple items are selected so the
    // user knows how many files vs folders are involved.

    final breakdownParts = <String>[
      if (fileNames.isNotEmpty)
        '${fileNames.length} file${fileNames.length > 1 ? 's' : ''}',
      if (directoryNames.isNotEmpty)
        '${directoryNames.length} folder${directoryNames.length > 1 ? 's' : ''}',
    ];

    // Show confirmation dialog.

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete $subject?'),
              if (!isSingle) ...[
                const SizedBox(height: 8),
                Text(
                  '(${breakdownParts.join(" and ")})',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              if (directoryNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Folders and all their contents will be permanently '
                  'removed.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Show a progress dialog that updates as items are deleted. We use a
    // [LoadingDialogController] so the dialog can be torn down reliably
    // in the `finally` block, even when the originating context becomes
    // unmounted while the batch deletion is in flight.

    final progressNotifier = ValueNotifier<double>(0);

    final loading = LoadingDialogController.show(
      context: context,
      title: 'Deleting $subject',
      child: ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (_, progress, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 12),
              Text(
                '${(progress * totalCount).round()} / $totalCount',
              ),
            ],
          );
        },
      ),
    );

    try {
      final result = await deleteItems(
        parentPath: currentPath,
        fileNames: fileNames,
        directoryNames: directoryNames,
        onProgress: (completed, total) {
          progressNotifier.value = completed / total;
        },
      );

      if (!context.mounted) return;

      // Show a result snackbar.

      if (result.allSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSingle
                  ? '$singleName deleted successfully.'
                  : '${result.succeeded.length} items deleted successfully.',
            ),
            backgroundColor: ActionColors.success,
          ),
        );
      } else if (result.succeeded.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete: ${result.failed.keys.join(", ")}',
            ),
            backgroundColor: ActionColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.succeeded.length} deleted, '
              '${result.failed.length} failed: '
              '${result.failed.keys.join(", ")}',
            ),
            backgroundColor: ActionColors.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      onSuccess?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batch delete error: ${e.toString()}'),
            backgroundColor: ActionColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always tear down the progress dialogue and release the
      // notifier, even if we returned early because the originating
      // context became unmounted.

      loading.close();
      progressNotifier.dispose();
    }
  }
}
