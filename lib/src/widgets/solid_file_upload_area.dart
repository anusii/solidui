/// A comprehensive file upload area widget with data operations.
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

import 'package:path/path.dart' as path;

import 'package:solidui/src/widgets/solid_format_info_card.dart';

import 'solid_file_preview_card.dart';
import 'solid_file_upload_buttons.dart';
import 'solid_file_upload_config.dart';

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

  /// Callback when preview is closed.

  final VoidCallback? onClosePreview;

  const SolidFileUploadArea({
    super.key,
    required this.config,
    required this.callbacks,
    required this.state,
    this.header,
    this.footer,
    this.padding,
    this.onClosePreview,
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
          if (header != null) ...[header!, const SizedBox(height: 16)],

          // Title.
          const Text(
            'Upload Files',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Display preview card if enabled.
          _buildPreviewCard(),
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
          if (footer != null) ...[const SizedBox(height: 16), footer!],
        ],
      ),
    );
  }

  /// Builds a preview card UI to show content or info of selected file.

  Widget _buildPreviewCard() {
    if (!state.showPreview || state.filePreview == null) {
      return const SizedBox.shrink();
    }

    return SolidFilePreviewCard(
      content: state.filePreview!,
      onClose: onClosePreview,
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
      Expanded(
        child: SolidFileUploadButtons.buildUploadButton(
          context: context,
          config: config,
          state: state,
          onPressed: callbacks.onUpload,
        ),
      ),
    ];

    // Add CSV buttons.

    if (config.showCsvButtons) {
      if (callbacks.onImportCsv != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: SolidFileUploadButtons.buildCsvImportButton(
              context: context,
              state: state,
              onPressed: callbacks.onImportCsv,
            ),
          ),
        );
      }

      if (callbacks.onExportCsv != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: SolidFileUploadButtons.buildCsvExportButton(
              context: context,
              state: state,
              onPressed: callbacks.onExportCsv,
            ),
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
            child: SolidFileUploadButtons.buildProfileImportButton(
              context: context,
              state: state,
              onPressed: callbacks.onImportProfile,
            ),
          ),
        );
      }

      if (callbacks.onExportProfile != null) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(
          Expanded(
            child: SolidFileUploadButtons.buildProfileExportButton(
              context: context,
              state: state,
              onPressed: callbacks.onExportProfile,
            ),
          ),
        );
      }
    }

    return Row(children: buttons);
  }

  Widget _buildAdditionalButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Add Visualise POD JSON button.

    if (config.showJsonButtons && callbacks.onVisualiseJson != null) {
      buttons.add(
        SolidFileUploadButtons.buildFullWidthButton(
          context: context,
          state: state,
          onPressed: callbacks.onVisualiseJson,
          icon: Icons.add_chart,
          label: 'Visualise JSON from POD',
          tooltip: '''

**Visualise JSON from POD**: Tap here to select and visualise a JSON file from 
your Solid POD.

''',
        ),
      );
    }

    // Add Visualise Local JSON button.

    if (config.showJsonButtons && callbacks.onSelectLocalJson != null) {
      buttons.add(
        SolidFileUploadButtons.buildFullWidthButton(
          context: context,
          state: state,
          onPressed: callbacks.onSelectLocalJson,
          icon: Icons.folder_open,
          label: 'Visualise Local JSON',
          tooltip: '''

**Visualise Local JSON**: Tap here to select and visualise a JSON file from 
your local device.

''',
        ),
      );
    }

    // Add Preview File button (when file is uploaded).

    if (state.uploadedFilePath != null &&
        config.showPreviewButtons &&
        callbacks.onPreviewFile != null) {
      buttons.add(
        SolidFileUploadButtons.buildFullWidthButton(
          context: context,
          state: state,
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
        SolidFileUploadButtons.buildFullWidthButton(
          context: context,
          state: state,
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
}
