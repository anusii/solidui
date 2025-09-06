/// A comprehensive file upload area widget with data operations.
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
import 'package:path/path.dart' as path;

import 'package:solidui/src/models/data_format_config.dart';
import 'package:solidui/src/widgets/solid_format_info_card.dart';

/// Configuration for the file upload area.

class SolidFileUploadConfig {
  /// Whether to show CSV import/export buttons.

  final bool showCsvButtons;

  /// Whether to show Profile import/export buttons.

  final bool showProfileButtons;

  /// Whether to show JSON operations.

  final bool showJsonButtons;

  /// Whether to show file preview options.

  final bool showPreviewButtons;

  /// The data format configuration to display.

  final DataFormatConfig? formatConfig;

  /// Custom upload button text.

  final String uploadButtonText;

  /// Custom upload tooltip message.

  final String? uploadTooltip;

  const SolidFileUploadConfig({
    this.showCsvButtons = false,
    this.showProfileButtons = false,
    this.showJsonButtons = true,
    this.showPreviewButtons = true,
    this.formatConfig,
    this.uploadButtonText = 'Upload File',
    this.uploadTooltip,
  });
}

/// Callbacks for file upload area operations.

class SolidFileUploadCallbacks {
  /// Callback for file upload.

  final VoidCallback? onUpload;

  /// Callback for CSV import.

  final VoidCallback? onImportCsv;

  /// Callback for CSV export.

  final VoidCallback? onExportCsv;

  /// Callback for Profile import.

  final VoidCallback? onImportProfile;

  /// Callback for Profile export.

  final VoidCallback? onExportProfile;

  /// Callback for JSON visualisation.

  final VoidCallback? onVisualiseJson;

  /// Callback for file preview.

  final VoidCallback? onPreviewFile;

  /// Callback for PDF to JSON conversion.

  final VoidCallback? onConvertToJson;

  const SolidFileUploadCallbacks({
    this.onUpload,
    this.onImportCsv,
    this.onExportCsv,
    this.onImportProfile,
    this.onExportProfile,
    this.onVisualiseJson,
    this.onPreviewFile,
    this.onConvertToJson,
  });
}

/// State information for the upload area.

class SolidFileUploadState {
  /// Whether upload is in progress.

  final bool uploadInProgress;

  /// Whether import is in progress.

  final bool importInProgress;

  /// Whether export is in progress.

  final bool exportInProgress;

  /// Path to uploaded file.

  final String? uploadedFilePath;

  /// Whether upload is done.

  final bool uploadDone;

  /// File preview content.

  final String? filePreview;

  /// Whether to show preview.

  final bool showPreview;

  const SolidFileUploadState({
    this.uploadInProgress = false,
    this.importInProgress = false,
    this.exportInProgress = false,
    this.uploadedFilePath,
    this.uploadDone = false,
    this.filePreview,
    this.showPreview = false,
  });

  SolidFileUploadState copyWith({
    bool? uploadInProgress,
    bool? importInProgress,
    bool? exportInProgress,
    String? uploadedFilePath,
    bool? uploadDone,
    String? filePreview,
    bool? showPreview,
  }) {
    return SolidFileUploadState(
      uploadInProgress: uploadInProgress ?? this.uploadInProgress,
      importInProgress: importInProgress ?? this.importInProgress,
      exportInProgress: exportInProgress ?? this.exportInProgress,
      uploadedFilePath: uploadedFilePath ?? this.uploadedFilePath,
      uploadDone: uploadDone ?? this.uploadDone,
      filePreview: filePreview ?? this.filePreview,
      showPreview: showPreview ?? this.showPreview,
    );
  }
}

/// A comprehensive file upload area with data operation buttons.

class SolidFileUploadArea extends StatelessWidget {
  /// Configuration for the upload area.

  final SolidFileUploadConfig config;

  /// Callbacks for various operations.

  final SolidFileUploadCallbacks callbacks;

  /// Current state of the upload area.

  final SolidFileUploadState state;

  /// Optional custom widget to display above the buttons.

  final Widget? header;

  /// Optional custom widget to display below the buttons.

  final Widget? footer;

  /// Padding around the entire upload area.

  final EdgeInsets? padding;

  const SolidFileUploadArea({
    super.key,
    required this.config,
    required this.callbacks,
    required this.state,
    this.header,
    this.footer,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom header.

          if (header != null) ...[
            header!,
            const SizedBox(height: 16),
          ],

          // Title.

          const Text(
            'Upload Files',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Display preview card if enabled.

          _buildPreviewCard(context),
          if (state.showPreview) const SizedBox(height: 16),

          // Show selected file info.

          if (state.uploadedFilePath != null) ...[
            _buildSelectedFileCard(context),
            const SizedBox(height: 16),
          ],

          // Upload and operation buttons row.

          _buildMainButtonsRow(context),

          // Display format information card.

          if (config.formatConfig != null) ...[
            const SizedBox(height: 16),
            SolidFormatInfoCard(config: config.formatConfig!),
          ],

          // Additional buttons (Visualise JSON, Preview File, Convert to JSON).

          if (config.showJsonButtons ||
              (state.uploadedFilePath != null &&
                  config.showPreviewButtons)) ...[
            const SizedBox(height: 12),
            _buildAdditionalButtons(context),
          ],

          // Custom footer.

          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }

  /// Builds a preview card UI to show content or info of selected file.

  Widget _buildPreviewCard(BuildContext context) {
    if (!state.showPreview || state.filePreview == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(10),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: MarkdownTooltip(
                    message: '''

**Close Preview:** Tap here to close the file preview panel.

''',
                    child: const Icon(Icons.close, size: 20),
                  ),
                  onPressed: () {
                    // This would need to be handled by the parent widget
                    // For now, we'll just ignore the close action.
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                state.filePreview!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a card to display selected file information.

  Widget _buildSelectedFileCard(BuildContext context) {
    if (state.uploadedFilePath == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.file_present,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              path.basename(state.uploadedFilePath!),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (state.uploadDone)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  /// Builds the main buttons row (Upload + CSV/Profile buttons).

  Widget _buildMainButtonsRow(BuildContext context) {
    final buttons = <Widget>[
      // Main upload button.

      Expanded(child: _buildUploadButton(context)),
    ];

    // Add CSV buttons.

    if (config.showCsvButtons) {
      if (callbacks.onImportCsv != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: _buildCsvImportButton(context),
          ),
        );
      }

      if (callbacks.onExportCsv != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: _buildCsvExportButton(context),
          ),
        );
      }
    }

    // Add Profile buttons.

    if (config.showProfileButtons) {
      if (callbacks.onImportProfile != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: _buildProfileImportButton(context),
          ),
        );
      }

      if (callbacks.onExportProfile != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: _buildProfileExportButton(context),
          ),
        );
      }
    }

    return Row(children: buttons);
  }

  Widget _buildUploadButton(BuildContext context) {
    final uploadButton = ElevatedButton.icon(
      onPressed: state.uploadInProgress ? null : callbacks.onUpload,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

  Widget _buildCsvImportButton(BuildContext context) {
    return MarkdownTooltip(
      message: '''

**Import CSV:** Tap here to import data from a CSV file:

- Select a CSV file from your device;

- The data will be processed and added to your health records;

- Please ensure the CSV follows the required format.


''',
      child: ElevatedButton.icon(
        onPressed: state.importInProgress ? null : callbacks.onImportCsv,
        icon: const Icon(Icons.table_chart),
        label: const Text('Import CSV'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCsvExportButton(BuildContext context) {
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
        onPressed: state.exportInProgress ? null : callbacks.onExportCsv,
        icon: const Icon(Icons.download),
        label: const Text('Export CSV'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: state.importInProgress ? null : callbacks.onImportProfile,
      icon: const Icon(Icons.person),
      label: const Text('Import Profile'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildProfileExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: state.exportInProgress ? null : callbacks.onExportProfile,
      icon: const Icon(Icons.download),
      label: const Text('Export Profile'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAdditionalButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Add Visualise JSON button.

    if (config.showJsonButtons && callbacks.onVisualiseJson != null) {
      buttons.add(
        _buildTextButton(
          context: context,
          onPressed: callbacks.onVisualiseJson,
          icon: Icons.analytics,
          label: 'Visualise JSON',
          tooltip: '''

**Visualise JSON**: Tap here to select and visualise a JSON file from your local machine.

''',
        ),
      );
    }

    // Add Preview File button (when file is uploaded).

    if (state.uploadedFilePath != null &&
        config.showPreviewButtons &&
        callbacks.onPreviewFile != null) {
      buttons.add(
        _buildTextButton(
          context: context,
          onPressed: callbacks.onPreviewFile,
          icon: Icons.preview,
          label: 'Preview File',
          tooltip: '''

**Preview File**: Tap here to preview the recently uploaded file.

''',
        ),
      );
    }

    // Add Convert to JSON button (when file is uploaded).

    if (state.uploadedFilePath != null &&
        config.showPreviewButtons &&
        callbacks.onConvertToJson != null) {
      buttons.add(
        _buildTextButton(
          context: context,
          onPressed: callbacks.onConvertToJson,
          icon: Icons.code,
          label: 'Convert to JSON',
          tooltip: '''

**Convert to JSON**: Tap here to convert the PDF file to JSON format and upload both files.
This will extract text from the PDF, structure it as JSON data, and upload both files to your POD.

''',
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: buttons
          .expand((widget) => [widget, const SizedBox(height: 12)])
          .take(buttons.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildTextButton({
    required BuildContext context,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(160, 40),
      ),
    );

    return MarkdownTooltip(
      message: tooltip,
      child: textButton,
    );
  }
}
