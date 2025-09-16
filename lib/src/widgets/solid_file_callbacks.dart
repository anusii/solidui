/// Default callback implementations for SolidFile widget.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
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
            content:
                const Text('Profile import: please implement custom handler'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onExportProfile: () {
        // Show a placeholder message for profile export.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Profile export: please implement custom handler'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
