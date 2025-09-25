/// Button builder widgets for the file upload area.
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
