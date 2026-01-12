/// File operations utility class for handling file system interactions.
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
/// Authors: Tony Chen (migrated from MovieStar)

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/models/file_item.dart';

/// A utility class for performing file system operations in the POD.

class FileOperations {
  /// Extracts the resource name (file or directory) from a URL, path, or plain
  /// name.
  ///
  /// Handles three cases:
  /// - Full URLs (containing `://`): Extracts the last path segment
  /// - Relative paths (containing `/`): Extracts the last component
  /// - Plain names: Returns as-is
  ///
  /// Parameters:
  /// - [resourceUrl]: The URL, path, or name to process
  ///
  /// Returns the extracted resource name. If parsing fails, returns the
  /// original input.
  ///
  /// Examples:
  /// ```dart
  /// extractResourceName('file.txt') // Returns: 'file.txt'
  /// extractResourceName('folder/file.txt') // Returns: 'file.txt'
  /// extractResourceName('https://example.com/path/file.txt') // Returns:
  /// 'file.txt'
  /// ```

  static String extractResourceName(String resourceUrl) {
    try {
      if (resourceUrl.contains('://')) {
        // It's a full URL.

        final uri = Uri.parse(resourceUrl);
        return uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : resourceUrl;
      } else if (resourceUrl.contains('/')) {
        // It's a relative path, extract the last component.

        return resourceUrl.split('/').last;
      } else {
        // It's just a resource name.

        return resourceUrl;
      }
    } catch (e) {
      // If parsing fails, use the original as resource name.

      debugPrint('Error parsing resourceUrl $resourceUrl: $e');
      return resourceUrl;
    }
  }

  /// Retrieves and processes files from the specified directory.
  ///
  /// Parameters:
  /// - [currentPath]: The directory path to process.
  /// - [context]: Build context for UI operations.
  ///
  /// Returns a list of processed [FileItem] objects.

  static Future<List<FileItem>> getFiles(
    String currentPath,
    BuildContext context,
  ) async {
    // Get directory URL and contents.

    final dirUrl = await getDirUrl(currentPath);
    final resources = await getResourcesInContainer(dirUrl);

    // Process each file in the directory.

    final processedFiles = <FileItem>[];
    for (var fileUrl in resources.files) {
      // Extract the file name from the URL/path.

      final fileName = extractResourceName(fileUrl);

      // Skip ACL files and metadata files, but include all other file types
      // (TTL, JSON, CSV, TXT, etc.)
      if (fileName.endsWith('.acl') || fileName.endsWith('.meta')) {
        continue;
      }

      // Construct full path.

      final relativePath = [currentPath, fileName].join('/');

      if (!context.mounted) continue;

      // Read file metadata using relative path from pod root.
      // Note: currentPath already contains the full path from pod root
      // (e.g., "healthpod/data/pathology"), so we use relativeToPod to avoid
      // path duplication.

      // dc 20260107: It is unnecessary to read the content of file as contents
      // are not stored in `processedFiles`.
      //
      // final metadata = await readPod(
      //   relativePath,
      //   pathType: PathType.relativeToPod,
      // );

      // Add valid files to the processed list.

      // if (metadata != SolidFunctionCallStatus.fail.toString() &&
      //     metadata != SolidFunctionCallStatus.notLoggedIn.toString()) {

      processedFiles.add(
        FileItem(
          name: fileName,
          path: relativePath,
          dateModified: DateTime.now(),
        ),
      );
      // }
    }
    return processedFiles;
  }

  /// Gets the file count for each subdirectory.
  ///
  /// Parameters:
  /// - [currentPath]: The parent directory path.
  /// - [directories]: List of subdirectory names to process.
  ///
  /// Returns a map of directory names to their file counts.

  static Future<Map<String, int>> getDirectoryCounts(
    String currentPath,
    List<String> directories,
  ) async {
    // Count files in each subdirectory.

    final counts = <String, int>{};
    for (var dir in directories) {
      counts[dir] = await getDirectoryFileCount('$currentPath/$dir');
    }
    return counts;
  }

  /// Counts the number of files in a directory.
  ///
  /// Parameters:
  /// - [dirPath]: The directory path to count files in.
  ///
  /// Returns the number of files in the directory, or 0 if an error occurs.

  static Future<int> getDirectoryFileCount(String dirPath) async {
    try {
      // Get directory contents and count files (exclude ACL and metadata files).

      final dirUrl = await getDirUrl(dirPath);
      final resources = await getResourcesInContainer(dirUrl);
      return resources.files
          .where((f) => !f.endsWith('.acl') && !f.endsWith('.meta'))
          .length;
    } catch (e) {
      debugPrint('Error counting files in directory: $e');
      return 0;
    }
  }
}
