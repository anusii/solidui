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
import 'package:solidui/src/utils/path_utils.dart';
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

  /// Optional initial path for the browser to start from.
  ///
  /// If provided, the browser will start from this path instead of the
  /// default app data directory path. Use an empty string to start from
  /// the POD root.

  final String? initialPath;

  /// Optional map of directory basenames to display names.
  ///
  /// When provided, these overrides are used to display user-friendly folder
  /// names in the path bar. Entries not found in the map fall back to generic
  /// formatting.

  final Map<String, String>? folderNameOverrides;

  const SolidFileBrowser({
    super.key,
    required this.onFileSelected,
    required this.onFileDownload,
    required this.onFileDelete,
    required this.browserKey,
    required this.onImportCsv,
    required this.onDirectoryChanged,
    required this.friendlyFolderName,
    this.initialPath,
    this.folderNameOverrides,
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

  /// The home path resolved from [getDataDirPath].

  String _homePath = '';

  @override
  void initState() {
    super.initState();
    _resolveHomePath();
  }

  /// Resolves the home path internally via [getDataDirPath].
  ///
  /// If [widget.initialPath] is provided, it is used as both the starting
  /// path and the home path for navigation. This allows browsing from any
  /// location on the POD, including the root.

  Future<void> _resolveHomePath() async {
    if (widget.initialPath != null) {
      // Use the explicitly provided initial path as both the home path and
      // the starting path. This ensures the "back to root" navigation and
      // path history work correctly for non-default starting locations.

      _homePath = PathUtils.normalise(widget.initialPath!);
    } else {
      try {
        final appDataPath = await getDataDirPath();
        _homePath = PathUtils.normalise(appDataPath);
      } catch (e) {
        debugPrint(
          'Failed to get app data path, falling back to POD root: $e',
        );
        _homePath = '';
      }
    }

    currentPath = _homePath;
    pathHistory = [currentPath];
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
      // Use PathUtils.combine to ensure consistent path joining without
      // double slashes.

      currentPath = PathUtils.combine(currentPath, dirName);
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
    // Normalise the target path to ensure consistent comparison and prevent
    // issues with leading slashes.

    final normalisedPath = PathUtils.normalise(path);

    setState(() {
      currentPath = normalisedPath;
      if (normalisedPath == _homePath || normalisedPath.isEmpty) {
        pathHistory = [_homePath];
      } else {
        if (pathHistory.isEmpty || pathHistory.last != normalisedPath) {
          // Check if the path is under the home path.

          if (_homePath.isEmpty || normalisedPath.startsWith('$_homePath/')) {
            pathHistory = [_homePath];
            final relativePath =
                PathUtils.relativeTo(normalisedPath, _homePath);
            if (relativePath.isNotEmpty) {
              final segments =
                  relativePath.split('/').where((s) => s.isNotEmpty);
              var currentBuildPath = _homePath;
              for (final segment in segments) {
                currentBuildPath = PathUtils.combine(currentBuildPath, segment);
                pathHistory.add(currentBuildPath);
              }
            }
          } else {
            pathHistory.add(normalisedPath);
          }
        }
      }
      refreshFiles();
    });
    widget.onDirectoryChanged.call(normalisedPath);
  }

  /// Gets the effective friendly folder name based on the current path.
  /// Uses SolidFileOperations for consistent title generation.

  String _getEffectiveFriendlyFolderName() {
    return SolidFileOperations.getFriendlyFolderName(
      currentPath,
      _homePath,
      widget.folderNameOverrides,
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
