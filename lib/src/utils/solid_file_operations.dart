/// Unified interface for file operations in SolidUI.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
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

import 'package:solidui/src/utils/solid_file_operations_delete.dart';
import 'package:solidui/src/utils/solid_file_operations_download.dart';
import 'package:solidui/src/utils/solid_file_operations_upload.dart';

/// Unified interface for file operations in SolidUI widgets.

class SolidFileOperations {
  const SolidFileOperations._();

  /// Download a file from the POD to local storage.

  static Future<void> downloadFile(
    BuildContext context,
    String fileName,
    String filePath, {
    String? basePath,
  }) =>
      SolidFileDownloadOperations.downloadFile(
        context,
        fileName,
        filePath,
        basePath: basePath,
      );

  /// Delete a file from the POD.

  static Future<void> deletePodFile(
    BuildContext context,
    String fileName,
    String filePath, {
    String? basePath,
    VoidCallback? onSuccess,
  }) =>
      SolidFileDeleteOperations.deletePodFile(
        context,
        fileName,
        filePath,
        basePath: basePath,
        onSuccess: onSuccess,
      );

  /// Upload a file to the POD.

  static Future<void> uploadFile(
    BuildContext context,
    String currentPath, {
    VoidCallback? onSuccess,
  }) =>
      SolidFileUploadOperations.uploadFile(
        context,
        currentPath,
        onSuccess: onSuccess,
      );
}
