/// Unified interface for file operations in SolidUI.
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
