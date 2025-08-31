/// File upload section component for SolidUI.
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
/// Authors: Tony Chen (migrated from MovieStar)

library;

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:solidui/src/models/file_state.dart';
import 'package:solidui/src/widgets/solid_file_uploader_helpers.dart';

/// A widget that handles file upload functionality and preview.

class SolidFileUploader extends StatefulWidget {
  /// The current file state.

  final FileState fileState;

  /// Callback when upload is requested.

  final Future<void> Function() onUpload;

  /// Callback when file is selected.

  final void Function(String?) onFileSelected;

  /// Callback when file preview is requested.

  final void Function(String) onPreviewRequested;

  /// The base path for file operations.

  final String basePath;
  const SolidFileUploader({
    super.key,
    required this.fileState,
    required this.onUpload,
    required this.onFileSelected,
    required this.onPreviewRequested,
    required this.basePath,
  });
  @override
  State<SolidFileUploader> createState() => _SolidFileUploaderState();
}

class _SolidFileUploaderState extends State<SolidFileUploader> {
  String? filePreview;
  bool showPreview = false;
  @override
  void didUpdateWidget(SolidFileUploader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update preview when file state changes.

    if (widget.fileState.filePreview != null &&
        widget.fileState.filePreview != oldWidget.fileState.filePreview) {
      setState(() {
        filePreview = widget.fileState.filePreview;
        showPreview = true;
      });
    }
  }

  /// Handles file preview before upload to display its content or basic info.

  Future<void> handlePreview(String filePath) async {
    try {
      final content =
          await SolidFileUploaderHelpers.generateFilePreview(filePath);
      setState(() {
        filePreview = content;
        showPreview = true;
      });
      widget.onPreviewRequested(content);
    } catch (e) {
      debugPrint('Preview error: $e');
    }
  }

  /// Handles upload button press.

  Future<void> _handleUploadButtonPress() async {
    final filePath = await SolidFileUploaderHelpers.pickFile();
    if (filePath != null) {
      widget.onFileSelected(filePath);
      await handlePreview(filePath);
      if (!context.mounted) return;
      await widget.onUpload();
      widget.onFileSelected(null);
      setState(() {
        filePreview = null;
        showPreview = false;
      });
    }
  }

  /// Handles JSON preview.

  Future<void> _handleJsonPreview() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        await handlePreview(file.path!);
      }
    }
  }

  /// Builds a preview card UI to show content or info of selected file.

  Widget _buildPreviewCard() {
    if (!showPreview) return const SizedBox.shrink();
    return SolidFileUploaderHelpers.buildPreviewCard(
      context,
      filePreview,
      () => setState(() => showPreview = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox(
            width: 250,
            height: 100,
            child: Center(child: Text('Loading uploader...')),
          );
        }
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title.

              Text(
                'Upload Files',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 16),

              // Display preview card if enabled.

              _buildPreviewCard(),
              if (showPreview) const SizedBox(height: 16),

              // Selected file indicator.

              if (widget.fileState.remoteFileName != null &&
                  widget.fileState.remoteFileName != 'remoteFileName')
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      width: 1,
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
                          widget.fileState.cleanFileName ?? '',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ],
                  ),
                ),

              // Upload button.

              ElevatedButton.icon(
                onPressed: widget.fileState.uploadInProgress
                    ? null
                    : _handleUploadButtonPress,
                icon: const Icon(Icons.file_upload, color: Colors.white),
                label: const Text(
                  'Upload',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Visualise JSON button.

              TextButton.icon(
                onPressed: widget.fileState.uploadInProgress
                    ? null
                    : _handleJsonPreview,
                icon: Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'Visualise JSON',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
              ),

              // Preview button.

              if (widget.fileState.uploadFile != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: widget.fileState.uploadInProgress
                      ? null
                      : () => handlePreview(widget.fileState.uploadFile!),
                  icon: Icon(
                    Icons.preview,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Preview File',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
