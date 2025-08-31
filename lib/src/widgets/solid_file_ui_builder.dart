/// UI Builder for SolidFile widget.
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

import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/models/file_state.dart';
import 'package:solidui/src/utils/is_text_file.dart';
import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_uploader.dart';

/// UI builder for SolidFile layouts.

class SolidFileUIBuilder {
  /// Builds the wide screen layout with side-by-side browser and uploader.

  static Widget buildWideScreenLayout(
    BuildContext context,
    GlobalKey<SolidFileBrowserState> browserKey,
    String friendlyFolderName,
    String basePath,
    FileState fileState,
    Function(FileState) updateFileState,
    Function(String, String) onFileSelected,
    Function(String, String) onFileDownload,
    Function(String, String) onFileDelete,
    Function(String, String) onImportCsv,
    Function(String) onDirectoryChanged,
    Future<void> Function() onUpload,
    void Function(String?) onFilePickerSelected,
    Function(String) onPreviewRequested,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File browser on the left.

        Expanded(
          flex: 2,
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(right: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SolidFileBrowser(
                key: browserKey,
                browserKey: browserKey,
                friendlyFolderName: friendlyFolderName,
                basePath: basePath,
                onFileSelected: onFileSelected,
                onFileDownload: onFileDownload,
                onFileDelete: onFileDelete,
                onImportCsv: onImportCsv,
                onDirectoryChanged: onDirectoryChanged,
              ),
            ),
          ),
        ),

        // Upload section on the right.

        Expanded(
          flex: 1,
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(left: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SolidFileUploader(
                fileState: fileState,
                basePath: basePath,
                onUpload: onUpload,
                onFileSelected: onFilePickerSelected,
                onPreviewRequested: onPreviewRequested,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the narrow screen layout with stacked browser and uploader.

  static Widget buildNarrowScreenLayout(
    BuildContext context,
    GlobalKey<SolidFileBrowserState> browserKey,
    String friendlyFolderName,
    String basePath,
    FileState fileState,
    Function(FileState) updateFileState,
    Function(String, String) onFileSelected,
    Function(String, String) onFileDownload,
    Function(String, String) onFileDelete,
    Function(String, String) onImportCsv,
    Function(String) onDirectoryChanged,
    Future<void> Function() onUpload,
    void Function(String?) onFilePickerSelected,
    Function(String) onPreviewRequested,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File browser for narrow screen.

        SizedBox(
          height: 300,
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: SolidFileBrowser(
              key: browserKey,
              browserKey: browserKey,
              friendlyFolderName: friendlyFolderName,
              basePath: basePath,
              onFileSelected: onFileSelected,
              onFileDownload: onFileDownload,
              onFileDelete: onFileDelete,
              onImportCsv: onImportCsv,
              onDirectoryChanged: onDirectoryChanged,
            ),
          ),
        ),

        // Upload section for narrow screen.

        Expanded(
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SolidFileUploader(
                fileState: fileState,
                basePath: basePath,
                onUpload: onUpload,
                onFileSelected: onFilePickerSelected,
                onPreviewRequested: onPreviewRequested,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles file selection with preview generation.

  static Future<void> handleFileSelection(
    String name,
    String filePath,
    BuildContext context,
    FileState fileState,
    Function(FileState) updateFileState,
    Function(String, String)? onFileSelected,
  ) async {
    try {
      // Read file content for preview.

      final content = await readPod(
        filePath,
        context,
        Container(),
      );
      String preview;

      if (isTextFile(name)) {
        // For text files, show the first 500 characters.

        preview =
            content.length > 500 ? '${content.substring(0, 500)}...' : content;
      } else {
        // For binary files, show basic info.

        preview = 'Binary file\n'
            'Size: ${(content.length / 1024).toStringAsFixed(2)} KB\n'
            'Type: ${path.extension(name)}';
      }

      updateFileState(
        fileState.copyWith(
          downloadFile: filePath,
          filePreview: preview,
          remoteFileName: path.basename(name),
        ),
      );

      onFileSelected?.call(name, filePath);
    } catch (e) {
      debugPrint('Preview error: $e');
      updateFileState(
        fileState.copyWith(
          downloadFile: filePath,
          filePreview: 'Error loading preview',
          remoteFileName: path.basename(name),
        ),
      );
    }
  }

  /// Shows confirmation dialog for file deletion.

  static Future<bool> showDeleteConfirmation(
    BuildContext context,
    String fileName,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          title: Text(
            'Confirm Delete',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete "$fileName"?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirm == true;
  }
}
