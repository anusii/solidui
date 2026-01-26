/// A file browser widget for SolidUI.
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
import 'package:solidui/src/utils/file_operations.dart';
import 'package:solidui/src/widgets/solid_file_browser_content.dart';
import 'package:solidui/src/widgets/solid_file_browser_loading_state.dart';
import 'package:solidui/src/widgets/solid_file_browser_not_logged_in.dart';
import 'package:solidui/src/widgets/solid_file_empty_directory_view.dart';
import 'package:solidui/src/widgets/solid_file_operations.dart';
import 'package:solidui/src/widgets/solid_file_path_bar.dart';

/// A file browser widget to interact with files and directories in user's POD.

class SolidFileBrowser extends StatefulWidget {
  /// Callback when a file is selected.

  final Function(String, String) onFileSelected;

  /// Callback when a file is downloaded.

  final Function(String, String) onFileDownload;

  /// Callback when a file is deleted.

  final Function(String, String) onFileDelete;

  /// Callback when the current directory changes.

  final Function(String) onDirectoryChanged;

  /// Callback to handle CSV file imports.

  final Function(String, String) onImportCsv;

  /// Key to access the browser state from outside the widget.

  final GlobalKey<SolidFileBrowserState> browserKey;

  /// Add friendly folder name.

  final String friendlyFolderName;

  /// The base path for the file browser.

  final String basePath;

  const SolidFileBrowser({
    super.key,
    required this.onFileSelected,
    required this.onFileDownload,
    required this.onFileDelete,
    required this.browserKey,
    required this.onImportCsv,
    required this.onDirectoryChanged,
    required this.friendlyFolderName,
    required this.basePath,
  });

  @override
  State<SolidFileBrowser> createState() => SolidFileBrowserState();
}

/// State class for the [SolidFileBrowser] widget.

class SolidFileBrowserState extends State<SolidFileBrowser> {
  /// List of files in the current directory.

  List<FileItem> files = [];

  /// List of subdirectories in the current directory.

  List<String> directories = [];

  /// Map of directory names to their file counts.

  Map<String, int> directoryCounts = {};

  /// Whether the browser is currently loading content.

  bool isLoading = true;

  /// The currently selected file name.

  String? selectedFile;

  /// The current directory path being displayed.

  late String currentPath;

  /// History of visited directories for navigation.

  late List<String> pathHistory;

  /// Number of files in the current directory.

  int currentDirFileCount = 0;

  /// Number of directories in the current directory.

  int currentDirDirectoryCount = 0;

  /// Whether the user is logged in to Solid POD.

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    currentPath = widget.basePath;
    pathHistory = [widget.basePath];
    _checkLoginStatus();
  }

  /// Checks if the user is logged in to the Solid POD.

  Future<void> _checkLoginStatus() async {
    try {
      final webId = await getWebId();
      if (webId == null || webId.isEmpty) {
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
        return;
      }

      final loggedIn = await isUserLoggedIn();
      setState(() => isLoggedIn = loggedIn);

      if (isLoggedIn) {
        await refreshFiles();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  /// Navigates into a subdirectory.

  Future<void> navigateToDirectory(String dirName) async {
    if (!mounted) return;
    setState(() {
      currentPath = '$currentPath/$dirName';
      pathHistory.add(currentPath);
    });
    await refreshFiles();
    widget.onDirectoryChanged.call(currentPath);
  }

  /// Navigates up one directory level.

  Future<void> navigateUp() async {
    if (pathHistory.length > 1) {
      pathHistory.removeLast();
      if (!mounted) return;
      setState(() => currentPath = pathHistory.last);
      widget.onDirectoryChanged.call(currentPath);
      await refreshFiles();
    }
  }

  /// Refreshes the current directory's contents.

  Future<void> refreshFiles() async {
    if (!isLoggedIn) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Get current directory contents.

      final dirUrl = await getDirUrl(currentPath);
      final resources = await getResourcesInContainer(dirUrl);

      if (!mounted) return;

      // Update directories list.

      setState(() {
        directories = resources.subDirs
            .map((dirUrl) => FileOperations.extractResourceName(dirUrl))
            .toList();
        currentDirDirectoryCount = directories.length;
      });

      // Count files in current directory.

      currentDirFileCount = resources.files
          .where((f) => f.endsWith('.enc.ttl') || f.endsWith('.ttl'))
          .length;

      // Get file counts for all subdirectories.

      final counts = await FileOperations.getDirectoryCounts(
        currentPath,
        directories,
      );

      if (!mounted) return;

      // Process and validate files.

      final processedFiles = await FileOperations.getFiles(
        currentPath,
        context,
      );

      if (!mounted) return;

      // Update state with processed data.

      setState(() {
        files = processedFiles;
        directoryCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Navigate to a specific path in the file browser.

  void navigateToPath(String path) {
    setState(() {
      currentPath = path;
      if (path == widget.basePath) {
        pathHistory = [widget.basePath];
      } else {
        if (pathHistory.isEmpty || pathHistory.last != path) {
          if (path.startsWith(widget.basePath)) {
            pathHistory = [widget.basePath];
            final relativePath = path.substring(widget.basePath.length);
            if (relativePath.isNotEmpty && relativePath != '/') {
              final segments =
                  relativePath.split('/').where((s) => s.isNotEmpty);
              var currentBuildPath = widget.basePath;
              for (final segment in segments) {
                currentBuildPath = [currentBuildPath, segment].join('/');
                pathHistory.add(currentBuildPath);
              }
            }
          } else {
            pathHistory.add(path);
          }
        }
      }
      refreshFiles();
    });
    widget.onDirectoryChanged.call(path);
  }

  /// Gets the effective friendly folder name based on the current path.
  /// Uses SolidFileOperations for consistent title generation.

  String _getEffectiveFriendlyFolderName() {
    return SolidFileOperations.getFriendlyFolderName(
      currentPath,
      widget.basePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight <= 0 || constraints.maxWidth <= 0) {
          return const SizedBox(
            width: 200,
            height: 150,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Loading file browser...'),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLoggedIn)
                PathBar(
                  currentPath: currentPath,
                  pathHistory: pathHistory,
                  onNavigateUp: navigateUp,
                  onRefresh: refreshFiles,
                  isLoading: isLoading,
                  currentDirFileCount: currentDirFileCount,
                  currentDirDirectoryCount: currentDirDirectoryCount,
                  friendlyFolderName: _getEffectiveFriendlyFolderName(),
                  basePath: widget.basePath,
                ),
              if (isLoggedIn) const SizedBox(height: 12),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (!isLoggedIn) return const FileBrowserNotLoggedInView();
    if (isLoading) return const FileBrowserLoadingState();
    if (directories.isEmpty && files.isEmpty) return const EmptyDirectoryView();

    return FileBrowserContent(
      directories: directories,
      files: files,
      directoryCounts: directoryCounts,
      currentPath: currentPath,
      selectedFile: selectedFile,
      onDirectorySelected: navigateToDirectory,
      onFileSelected: (name, path) {
        setState(() => selectedFile = name);
        widget.onFileSelected.call(name, path);
      },
      onFileDownload: widget.onFileDownload,
      onFileDelete: widget.onFileDelete,
    );
  }
}
