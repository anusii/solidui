/// File operations utility class for handling file system interactions.
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

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/models/file_item.dart';

/// A utility class for performing file system operations in the POD.

class FileOperations {
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
    for (var fileName in resources.files) {
      // Skip non-TTL files. Include both .enc.ttl and .ttl files.

      if (!fileName.endsWith('.enc.ttl') && !fileName.endsWith('.ttl')) {
        continue;
      }

      // Construct full path.

      final relativePath = '$currentPath/$fileName';

      if (!context.mounted) continue;

      // Read file metadata.

      final metadata = await readPod(
        relativePath,
        context,
        const Text('Reading file info'),
      );

      // Add valid files to the processed list.

      if (metadata != SolidFunctionCallStatus.fail.toString() &&
          metadata != SolidFunctionCallStatus.notLoggedIn.toString()) {
        processedFiles.add(
          FileItem(
            name: fileName,
            path: relativePath,
            dateModified: DateTime.now(),
          ),
        );
      }
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
      // Get directory contents and count files.

      final dirUrl = await getDirUrl(dirPath);
      final resources = await getResourcesInContainer(dirUrl);
      return resources.files
          .where((f) => f.endsWith('.enc.ttl') || f.endsWith('.ttl'))
          .length;
    } catch (e) {
      debugPrint('Error counting files in directory: $e');
      return 0;
    }
  }
}
