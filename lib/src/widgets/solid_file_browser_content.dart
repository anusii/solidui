/// A content widget for the file browser.
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

import 'package:solidui/src/models/file_item.dart';
import 'package:solidui/src/widgets/solid_file_directory_list.dart';
import 'package:solidui/src/widgets/solid_file_list.dart';

/// Content widget for the file browser.

class FileBrowserContent extends StatelessWidget {
  /// List of subdirectories in the current directory.

  final List<String> directories;

  /// List of files in the current directory.

  final List<FileItem> files;

  /// Map of directory names to their file counts.

  final Map<String, int> directoryCounts;

  /// The current directory path.

  final String currentPath;

  /// Set of currently selected item keys (e.g. "dir:folderName", "file:name").

  final Set<String> selectedItems;

  /// Function to handle directory navigation.

  final Function(String) onDirectorySelected;

  /// Function to handle file selection for viewing/opening.

  final Function(String, String) onFileSelected;

  /// Callback to toggle selection of an item by its key.

  final Function(String) onToggleSelection;

  /// Callback to add or remove a batch of item keys in one operation.

  final void Function(List<String> keys, {required bool selected})
  onBatchSetSelection;

  const FileBrowserContent({
    super.key,
    required this.directories,
    required this.files,
    required this.directoryCounts,
    required this.currentPath,
    required this.selectedItems,
    required this.onDirectorySelected,
    required this.onFileSelected,
    required this.onToggleSelection,
    required this.onBatchSetSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Background colour intentionally omitted. The ListTile widgets
        // inside DirectoryList set their own tileColor, and Flutter
        // asserts when a ListTile is inside a DecoratedBox with a
        // background — it hides ink splashes on the Material ancestor.
        // The rounded border is kept for visual grouping.
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: directories.isEmpty && files.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No files or folders found in this directory',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // Directory list with selection support.
                DirectoryList(
                  directories: directories,
                  directoryCounts: directoryCounts,
                  selectedItems: selectedItems,
                  onDirectorySelected: onDirectorySelected,
                  onToggleSelection: onToggleSelection,
                  onBatchSetSelection: onBatchSetSelection,
                ),

                // Add visual separator if both directories and files exist.
                if (directories.isNotEmpty && files.isNotEmpty)
                  Divider(height: 24, color: Theme.of(context).dividerColor),

                // File list with selection support.
                FileList(
                  files: files,
                  currentPath: currentPath,
                  selectedItems: selectedItems,
                  onFileSelected: onFileSelected,
                  onToggleSelection: onToggleSelection,
                  onBatchSetSelection: onBatchSetSelection,
                ),
              ],
            ),
    );
  }
}
