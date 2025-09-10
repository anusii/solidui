/// A file browser widget for SolidUI.
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
import 'package:solidui/src/utils/file_operations.dart';
import 'package:solidui/src/widgets/solid_file_browser_content.dart';
import 'package:solidui/src/widgets/solid_file_browser_loading_state.dart';
import 'package:solidui/src/widgets/solid_file_empty_directory_view.dart';
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
      // Check for a WebID first.

      final webId = await getWebId();
      if (webId == null || webId.isEmpty) {
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
        return;
      }

      // Check if the user is actually logged in.

      final loggedIn = await checkLoggedIn();
      setState(() {
        isLoggedIn = loggedIn;
      });

      if (isLoggedIn) {
        await refreshFiles();
      } else {
        setState(() {
          isLoading = false;
        });
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
      setState(() => currentPath = pathHistory.last);
      widget.onDirectoryChanged.call(currentPath);
      await refreshFiles();
    }
  }

  /// Refreshes the current directory's contents.

  Future<void> refreshFiles() async {
    if (!isLoggedIn) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Get current directory contents.

      final dirUrl = await getDirUrl(currentPath);
      final resources = await getResourcesInContainer(dirUrl);

      if (!mounted) return;

      // Update directories list.

      setState(() {
        directories = resources.subDirs;
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
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Navigate to a specific path in the file browser.

  void navigateToPath(String path) {
    setState(() {
      currentPath = path;
      refreshFiles();
    });
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
                maxHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Navigation and path display bar (only show if logged in).

                  if (isLoggedIn)
                    PathBar(
                      currentPath: currentPath,
                      pathHistory: pathHistory,
                      onNavigateUp: navigateUp,
                      onRefresh: refreshFiles,
                      isLoading: isLoading,
                      currentDirFileCount: currentDirFileCount,
                      currentDirDirectoryCount: currentDirDirectoryCount,
                      friendlyFolderName: widget.friendlyFolderName,
                      basePath: widget.basePath,
                    ),

                  if (isLoggedIn) const SizedBox(height: 12),

                  // Main content area with conditional rendering.

                  Expanded(
                    child: !isLoggedIn
                        ? _buildNotLoggedInView()
                        : isLoading
                            ? const FileBrowserLoadingState()
                            : directories.isEmpty && files.isEmpty
                                ? const EmptyDirectoryView()
                                : FileBrowserContent(
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
                                  ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the not logged in view.

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display a large account icon with reduced opacity.

          Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),

          const SizedBox(height: 16),

          // Display not logged in message.

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Not connected to any POD',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
