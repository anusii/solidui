/// Default callback implementations for SolidFile widget.
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

import 'package:solidui/src/utils/solid_file_operations.dart';
import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// Helper class for creating default SolidFile upload callbacks.

class SolidFileDefaultCallbacks {
  /// Creates default upload callbacks with working file operations.

  static SolidFileUploadCallbacks createUploadCallbacks(
    BuildContext context,
    String currentPath,
    GlobalKey<SolidFileBrowserState> browserKey,
  ) {
    return SolidFileUploadCallbacks(
      onUpload: () {
        SolidFileOperations.uploadFile(
          context,
          currentPath,
          onSuccess: () {
            // Refresh the file browser after successful upload.

            browserKey.currentState?.refreshFiles();
          },
        );
      },
      onVisualiseJson: () {
        // Show a placeholder message for POD JSON preview.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('POD JSON preview feature coming soon'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onSelectLocalJson: () {
        // Show a placeholder message for local JSON selection.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Local JSON selection feature coming soon'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onPreviewFile: () {
        // Show a placeholder message for file preview.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File preview feature coming soon'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onConvertToJson: () {
        // Show a placeholder message for JSON conversion.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF to JSON conversion feature coming soon'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onImportCsv: () {
        // Show a placeholder message for CSV import.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CSV import: please implement custom handler'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onExportCsv: () {
        // Show a placeholder message for CSV export.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CSV export: please implement custom handler'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onImportProfile: () {
        // Show a placeholder message for profile import.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile import: please implement custom handler',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onExportProfile: () {
        // Show a placeholder message for profile export.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile export: please implement custom handler',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
