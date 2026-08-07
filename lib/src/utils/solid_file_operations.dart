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

import 'package:solidpod/solidpod.dart' show PathType;

import 'package:solidui/src/utils/solid_file_operations_delete.dart';
import 'package:solidui/src/utils/solid_file_operations_download.dart';
import 'package:solidui/src/utils/solid_file_operations_upload.dart';

/// Unified interface for file operations in SolidUI widgets.

class SolidFileOperations {
  const SolidFileOperations._();

  /// Download a file from the POD to local storage.
  ///
  /// [pathType] defaults to [PathType.relativeToPod]; pass
  /// [PathType.absoluteUrl] to read straight from an absolute resource URL.

  static Future<void> downloadFile(
    BuildContext context,
    String fileName,
    String filePath, {
    PathType pathType = PathType.relativeToPod,
  }) => SolidFileDownloadOperations.downloadFile(
    context,
    fileName,
    filePath,
    pathType: pathType,
  );

  /// Delete a file from the POD.
  ///
  /// [pathType] defaults to [PathType.relativeToPod]; pass
  /// [PathType.absoluteUrl] to delete by an absolute resource URL.

  static Future<void> deletePodFile(
    BuildContext context,
    String fileName,
    String filePath, {
    VoidCallback? onSuccess,
    PathType pathType = PathType.relativeToPod,
  }) => SolidFileDeleteOperations.deletePodFile(
    context,
    fileName,
    filePath,
    onSuccess: onSuccess,
    pathType: pathType,
  );

  /// Delete a mixed batch of files and/or directories from the POD.

  static Future<void> deleteMultipleItems(
    BuildContext context, {
    required String currentPath,
    List<String> fileNames = const [],
    List<String> directoryNames = const [],
    VoidCallback? onSuccess,
  }) => SolidFileDeleteOperations.deleteMultipleItems(
    context,
    currentPath: currentPath,
    fileNames: fileNames,
    directoryNames: directoryNames,
    onSuccess: onSuccess,
  );

  /// Download a mixed batch of files and/or directories as a zip archive.

  static Future<void> downloadMultipleItems(
    BuildContext context, {
    required String currentPath,
    List<String> fileNames = const [],
    List<String> directoryNames = const [],
    required String zipFileName,
  }) => SolidFileDownloadOperations.downloadMultipleItems(
    context,
    currentPath: currentPath,
    fileNames: fileNames,
    directoryNames: directoryNames,
    zipFileName: zipFileName,
  );

  /// Upload a file to the POD.
  ///
  /// When [allowedExtensions] is non-null and non-empty, only files with the
  /// listed extensions (case-insensitive, leading dots optional) may be
  /// selected. This restriction is honoured by every caller that delegates to
  /// this method, so a single allow list applies to all upload entry points.
  ///
  /// [pathType] defaults to [PathType.relativeToPod]; pass
  /// [PathType.absoluteUrl] to upload into an absolute directory URL.

  static Future<void> uploadFile(
    BuildContext context,
    String currentPath, {
    VoidCallback? onSuccess,
    List<String>? allowedExtensions,
    PathType pathType = PathType.relativeToPod,
  }) => SolidFileUploadOperations.uploadFile(
    context,
    currentPath,
    onSuccess: onSuccess,
    allowedExtensions: allowedExtensions,
    pathType: pathType,
  );
}
