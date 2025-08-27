/// A content widget for the file browser.
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

import 'package:solidui/src/models/file_item.dart';
import 'package:solidui/src/widgets/directory_list.dart';
import 'package:solidui/src/widgets/file_list.dart';

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
