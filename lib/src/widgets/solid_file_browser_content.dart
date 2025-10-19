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

  /// The currently selected file name.

  final String? selectedFile;

  /// Function to handle directory selection.

  final Function(String) onDirectorySelected;

  /// Function to handle file selection.

  final Function(String, String) onFileSelected;

  /// Function to handle file download.

  final Function(String, String) onFileDownload;

  /// Function to handle file deletion.

  final Function(String, String) onFileDelete;

  const FileBrowserContent({
    super.key,
    required this.directories,
    required this.files,
    required this.directoryCounts,
    required this.currentPath,
    required this.selectedFile,
    required this.onDirectorySelected,
    required this.onFileSelected,
    required this.onFileDownload,
    required this.onFileDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                // Directory list.
                DirectoryList(
                  directories: directories,
                  directoryCounts: directoryCounts,
                  onDirectorySelected: onDirectorySelected,
                ),

                // Add visual separator if both directories and files exist.
                if (directories.isNotEmpty && files.isNotEmpty)
                  Divider(height: 24, color: Theme.of(context).dividerColor),

                // File list.
                FileList(
                  files: files,
                  currentPath: currentPath,
                  selectedFile: selectedFile,
                  onFileSelected: onFileSelected,
                  onFileDownload: onFileDownload,
                  onFileDelete: onFileDelete,
                ),
              ],
            ),
    );
  }
}
