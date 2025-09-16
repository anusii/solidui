/// File browser builder for SolidFile widget.
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

/// Helper class for building file browser with default callbacks.

class SolidFileBrowserBuilder {
  /// Builds a file browser widget with default implementations.

  static Widget build({
    required GlobalKey<SolidFileBrowserState> browserKey,
    required String basePath,
    required String friendlyFolderName,
    Function(String fileName, String filePath)? onFileSelected,
    Function(String fileName, String filePath)? onFileDownload,
    Function(String fileName, String filePath)? onFileDelete,
    Function(String fileName, String filePath)? onImportCsv,
    required Function(String path) onDirectoryChanged,
    SolidFileUploadCallbacks? uploadCallbacks,
  }) {
    return SolidFileBrowser(
      key: browserKey,
      browserKey: browserKey,
      basePath: basePath,
      friendlyFolderName: friendlyFolderName,
      onFileSelected: onFileSelected ??
          (fileName, filePath) {
            debugPrint('File selected: $fileName at $filePath');
          },
      onFileDownload: onFileDownload ??
          (fileName, filePath) {
            SolidFileOperations.downloadFile(
              browserKey.currentContext!,
              fileName,
              filePath,
              basePath: basePath,
            );
          },
      onFileDelete: onFileDelete ??
          (fileName, filePath) {
            SolidFileOperations.deletePodFile(
              browserKey.currentContext!,
              fileName,
              filePath,
              basePath: basePath,
              onSuccess: () {
                // Refresh the browser after successful deletion.

                browserKey.currentState?.refreshFiles();
              },
            );
          },
      onImportCsv: uploadCallbacks?.onImportCsv != null
          ? (String fileName, String filePath) {
              uploadCallbacks!.onImportCsv!();
            }
          : onImportCsv ??
              (String fileName, String filePath) {
                debugPrint('Import CSV: $fileName at $filePath');
              },
      onDirectoryChanged: onDirectoryChanged,
    );
  }
}
