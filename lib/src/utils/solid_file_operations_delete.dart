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

/// Delete operations for SolidUI widgets.

class SolidFileDeleteOperations {
  const SolidFileDeleteOperations._();

  /// Default file deletion implementation.

  static Future<void> deletePodFile(
    BuildContext context,
    String fileName,
    String filePath, {
    String? basePath,
    VoidCallback? onSuccess,
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

      // Show loading dialog.

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Deleting'),
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
        // Construct the full file path by combining directory path and
        // filename. The filePath already contains the full path from pod root
        // (e.g., "healthpod/data/pathology").

        final fullFilePath = [filePath, fileName].join('/');

        // Delete the main file.

        bool mainFileDeleted = false;
        try {
          await deleteFile(fullFilePath);
          mainFileDeleted = true;
        } catch (e) {
          // Only rethrow if it's not a 404 error.

          if (!e.toString().contains('404') &&
              !e.toString().contains('NotFoundHttpError')) {
            rethrow;
          }
        }

        if (!context.mounted) return;

        // Try to delete the ACL file if main file deletion succeeded.

        if (mainFileDeleted) {
          try {
            await deleteFile('$fullFilePath.acl');
          } catch (e) {
            // ACL files are optional and may not exist.
            // We ignore 404 errors for ACL files.

            if (!e.toString().contains('404') &&
                !e.toString().contains('NotFoundHttpError')) {
              debugPrint('Warning: Could not delete ACL file: $e');
            }
          }
        }

        if (!context.mounted) return;

        // Close loading dialog.

        Navigator.of(context).pop();

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
          // Close loading dialog if still open.

          Navigator.of(context).pop();

          // Show error message.

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
}
