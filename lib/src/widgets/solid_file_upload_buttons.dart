/// Button builder widgets for the file upload area.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'solid_file_upload_config.dart';

/// A collection of button builders for file upload operations.

class SolidFileUploadButtons {
  const SolidFileUploadButtons._();

  /// Builds the main upload button.

  static Widget buildUploadButton({
    required BuildContext context,
    required SolidFileUploadConfig config,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
  }) {
    final uploadButton = ElevatedButton.icon(
      onPressed: state.uploadInProgress ? null : onPressed,
      icon: state.uploadInProgress
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.file_upload),
      label: Text(config.uploadButtonText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (config.uploadTooltip != null) {
      return MarkdownTooltip(
        message: config.uploadTooltip!,
        child: uploadButton,
      );
    }

    return uploadButton;
  }

  /// Builds the CSV import button.

  static Widget buildCsvImportButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
  }) {
    return MarkdownTooltip(
      message: '''

**Import CSV:** Tap here to import data from a CSV file:

- Select a CSV file from your device;

- The data will be processed and added to your health records;

- Please ensure the CSV follows the required format.


''',
      child: ElevatedButton.icon(
        onPressed: state.importInProgress ? null : onPressed,
        icon: const Icon(Icons.table_chart),
        label: const Text('Import CSV'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Builds the CSV export button.

  static Widget buildCsvExportButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
  }) {
    return MarkdownTooltip(
      message: '''

**Export CSV:** Tap here to export your health data to a CSV
file:

This button allows you to export your health data to a CSV file:
- Export your vaccination, blood pressure, or diary records

- The data will be saved in a standard CSV format

- You can use this file for backup or analysis

- The export process is quick and efficient

''',
      child: ElevatedButton.icon(
        onPressed: state.exportInProgress ? null : onPressed,
        icon: const Icon(Icons.download),
        label: const Text('Export CSV'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Builds the profile import button.

  static Widget buildProfileImportButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: state.importInProgress ? null : onPressed,
      icon: const Icon(Icons.person),
      label: const Text('Import Profile'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Builds the profile export button.

  static Widget buildProfileExportButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: state.exportInProgress ? null : onPressed,
      icon: const Icon(Icons.download),
      label: const Text('Export Profile'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Builds a generic text button with tooltip.

  static Widget buildTextButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    final textButton = TextButton.icon(
      onPressed: state.uploadInProgress ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(160, 40),
      ),
    );

    return MarkdownTooltip(message: tooltip, child: textButton);
  }

  /// Builds a full-width button with accent background.

  static Widget buildFullWidthButton({
    required BuildContext context,
    required SolidFileUploadState state,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    final textButton = TextButton.icon(
      onPressed: state.uploadInProgress ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: MarkdownTooltip(message: tooltip, child: textButton),
    );
  }
}
