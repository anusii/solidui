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
import 'package:solidui/src/models/file_sort_option.dart';
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

  /// Callback for creating a new folder in the current directory.
  /// Receives the current path.
  /// Null disables the toolbar button.

  final Function(String currentPath)? onCreateFolder;

  /// Callback for moving selected items.
  /// Receives the current path and the set of selected item keys.
  /// Null disables the toolbar button.

  final Function(String currentPath, Set<String> selectedItems)? onMoveItems;

  /// Callback for copying selected items.
  /// Receives the current path and the set of selected item keys.
  /// Null disables the toolbar button.

  final Function(String currentPath, Set<String> selectedItems)? onCopyItems;

  /// Callback for downloading selected items from the toolbar.
  /// Receives the current path and the set of selected item keys.
  /// Null disables the toolbar button.

  final Function(String currentPath, Set<String> selectedItems)?
      onDownloadItems;

  /// Callback for renaming the selected item from the toolbar.
  /// Receives the current path and the selected item key.
  /// Null disables the toolbar button.

  final Function(String currentPath, String selectedItem)? onRenameItem;

  /// Callback for deleting selected items from the toolbar.
  /// Receives the current path and the set of selected item keys.
  /// Null disables the toolbar button.

  final Function(String currentPath, Set<String> selectedItems)? onDeleteItems;

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
    this.onCreateFolder,
    this.onMoveItems,
    this.onCopyItems,
    this.onDownloadItems,
    this.onRenameItem,
    this.onDeleteItems,
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

  /// The current directory path being displayed.

  late String currentPath;

  /// History of visited directories for navigation.

  late List<String> pathHistory;

  /// Current position within [pathHistory] for back/forward navigation.

  int _historyIndex = 0;

  /// Number of files in the current directory.

  int currentDirFileCount = 0;

  /// Number of directories in the current directory.

  int currentDirDirectoryCount = 0;

  /// Whether the user is logged in to Solid POD.

  bool isLoggedIn = false;

  /// The home path resolved from [getDataDirPath].

  String _homePath = '';

  /// Set of currently selected item keys for multi-selection.
  ///
  /// Keys use a type prefix: "dir:folderName" for directories,
  /// "file:fileName" for files.

  final Set<String> _selectedItems = {};

  /// Unmodifiable view of the currently selected item keys.

  Set<String> get selectedItems => Set.unmodifiable(_selectedItems);

  /// The current sort option for files and directories.

  FileSortOption _currentSortOption = FileSortOption.nameAscending;

  /// Whether the user can navigate back in history.

  bool get canGoBack => _historyIndex > 0;

  /// Whether the user can navigate forward in history.

  bool get canGoForward => _historyIndex < pathHistory.length - 1;

  /// Whether the user can navigate to the parent directory.

  bool get canGoUp => currentPath != _homePath && currentPath.isNotEmpty;

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
    _historyIndex = 0;
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
    final newPath = PathUtils.combine(currentPath, dirName);
    await _navigateTo(newPath);
  }

  /// Navigates back in history (browser-style back).

  Future<void> navigateBack() async {
    if (!canGoBack || !mounted) return;
    _selectedItems.clear();
    setState(() {
      _historyIndex--;
      currentPath = pathHistory[_historyIndex];
    });
    widget.onDirectoryChanged.call(currentPath);
    await refreshFiles();
  }

  /// Navigates forward in history (browser-style forward).

  Future<void> navigateForward() async {
    if (!canGoForward || !mounted) return;
    _selectedItems.clear();
    setState(() {
      _historyIndex++;
      currentPath = pathHistory[_historyIndex];
    });
    widget.onDirectoryChanged.call(currentPath);
    await refreshFiles();
  }

  /// Navigates to the parent directory of the current path.

  Future<void> navigateToParent() async {
    if (!canGoUp || !mounted) return;
    final parentPath = PathUtils.parent(currentPath);
    await _navigateTo(parentPath);
  }

  /// Navigates to the home directory.

  Future<void> navigateHome() async {
    if (!mounted) return;
    await _navigateTo(_homePath);
  }

  /// Navigates up one directory level.
  ///
  /// Kept for backward compatibility. Delegates to [navigateBack].

  Future<void> navigateUp() async {
    await navigateBack();
  }

  /// Toggles the selection state of an item identified by [itemKey].
  ///
  /// Keys follow the format "dir:folderName" or "file:fileName".

  void toggleItemSelection(String itemKey) {
    setState(() {
      if (_selectedItems.contains(itemKey)) {
        _selectedItems.remove(itemKey);
      } else {
        _selectedItems.add(itemKey);
      }
    });
  }

  /// Clears all selected items.

  void clearSelection() {
    if (_selectedItems.isNotEmpty) {
      setState(() => _selectedItems.clear());
    }
  }

  /// Changes the current sort option and re-sorts the displayed items.

  void changeSortOption(FileSortOption option) {
    if (option == _currentSortOption) return;
    setState(() {
      _currentSortOption = option;
      _applySorting();
    });
  }

  /// Sorts [directories] and [files] according to [_currentSortOption].
  ///
  /// Directories are sorted by name for all options except the name-based
  /// ones, since they lack modification dates and type information.

  void _applySorting() {
    switch (_currentSortOption) {
      case FileSortOption.nameAscending:
        directories.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
        files.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case FileSortOption.nameDescending:
        directories.sort(
          (a, b) => b.toLowerCase().compareTo(a.toLowerCase()),
        );
        files.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case FileSortOption.dateModifiedAscending:
        directories.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
        files.sort(
          (a, b) => a.dateModified.compareTo(b.dateModified),
        );
      case FileSortOption.dateModifiedDescending:
        directories.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
        files.sort(
          (a, b) => b.dateModified.compareTo(a.dateModified),
        );
      case FileSortOption.typeAscending:
        directories.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
        files.sort((a, b) {
          final cmp = _fileExtension(a.name).compareTo(
            _fileExtension(b.name),
          );
          // Fall back to name order when extensions match.

          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case FileSortOption.typeDescending:
        directories.sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );
        files.sort((a, b) {
          final cmp = _fileExtension(b.name).compareTo(
            _fileExtension(a.name),
          );
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    }
  }

  /// Extracts the lowercase file extension from a file name.

  static String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? '' : fileName.substring(dotIndex + 1).toLowerCase();
  }

  /// Internal helper that navigates to a given [path], updating the history
  /// and clearing forward entries.

  Future<void> _navigateTo(String path) async {
    if (!mounted) return;
    _selectedItems.clear();
    setState(() {
      // Truncate any forward history entries beyond the current position.

      if (_historyIndex < pathHistory.length - 1) {
        pathHistory.removeRange(_historyIndex + 1, pathHistory.length);
      }
      pathHistory.add(path);
      _historyIndex = pathHistory.length - 1;
      currentPath = path;
    });
    widget.onDirectoryChanged.call(currentPath);
    await refreshFiles();
  }

  /// Refreshes the current directory's contents.
  ///
  /// Fetches resources from the container in a single REST call, then
  /// processes files and defers subdirectory count loading to the background
  /// to minimise the initial number of REST calls.

  Future<void> refreshFiles() async {
    if (!isLoggedIn) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Get current directory contents in a single REST call.

      final dirUrl = await getDirUrl(currentPath);
      final resources = await getResourcesInContainer(dirUrl);

      if (!mounted) return;

      // Extract directory names from the fetched resources.

      final fetchedDirectories = resources.subDirs
          .map((dirUrl) => FileOperations.extractResourceName(dirUrl))
          .toList();

      // Count TTL files from the already-fetched resource list (no extra REST
      // call needed).

      final fileCount = resources.files
          .where((f) => f.endsWith('.enc.ttl') || f.endsWith('.ttl'))
          .length;

      // Process and validate files, reusing the already-fetched file URL list
      // to avoid a duplicate getResourcesInContainer REST call.

      final processedFiles = await FileOperations.getFiles(
        currentPath,
        resources.files,
        context,
      );

      if (!mounted) return;

      // Update state with the fetched data and prune stale selections
      // that reference items no longer present in the directory
      // listing. Directory counts are not yet available and will be loaded
      // in the background.

      setState(() {
        directories = fetchedDirectories;
        currentDirDirectoryCount = fetchedDirectories.length;
        currentDirFileCount = fileCount;
        files = processedFiles;
        directoryCounts = {};
        isLoading = false;

        // Build the set of valid item keys from current directory contents.

        final validKeys = <String>{
          for (final dir in directories) 'dir:$dir',
          for (final file in processedFiles) 'file:${file.name}',
        };
        _selectedItems.removeWhere((key) => !validKeys.contains(key));

        // Apply the current sort option to the newly loaded data.

        _applySorting();
      });

      // Defer subdirectory file count fetching to the background so that the
      // UI is displayed immediately without blocking on N additional REST
      // calls (one per subdirectory).

      _loadDirectoryCountsInBackground(fetchedDirectories);
    } catch (e) {
      debugPrint('Error loading files: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Loads file counts for each subdirectory in the background.
  ///
  /// Updates the UI incrementally as each count becomes available, rather
  /// than blocking the initial render on N REST calls.

  Future<void> _loadDirectoryCountsInBackground(
    List<String> dirs,
  ) async {
    // Capture the path at the time of the request so we can discard stale
    // results if the user has navigated elsewhere.

    final requestPath = currentPath;

    final counts = await FileOperations.getDirectoryCounts(
      requestPath,
      dirs,
    );

    if (!mounted) return;

    // Only apply the results if the user is still viewing the same directory.

    if (currentPath == requestPath) {
      setState(() => directoryCounts = counts);
    }
  }

  /// Navigate to a specific path in the file browser.

  void navigateToPath(String path) {
    // Normalise the target path to ensure consistent comparison and prevent
    // issues with leading slashes.

    final normalisedPath = PathUtils.normalise(path);

    setState(() {
      currentPath = normalisedPath;
      _selectedItems.clear();

      if (normalisedPath == _homePath || normalisedPath.isEmpty) {
        pathHistory = [_homePath];
        _historyIndex = 0;
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
        _historyIndex = pathHistory.length - 1;
      }
      refreshFiles();
    });
    widget.onDirectoryChanged.call(normalisedPath);
  }

  /// Handles the toolbar Download action by invoking [widget.onFileDownload]
  /// for each selected file. If [widget.onDownloadItems] is provided, it is
  /// used instead for custom batch handling.

  void _handleToolbarDownload() {
    if (widget.onDownloadItems != null) {
      widget.onDownloadItems!(currentPath, selectedItems);
      return;
    }

    for (final key in _selectedItems) {
      if (key.startsWith('file:')) {
        final fileName = key.substring(5);
        widget.onFileDownload(fileName, currentPath);
      }
    }
  }

  /// Handles the toolbar Delete action by invoking [widget.onFileDelete]
  /// for each selected file. If [widget.onDeleteItems] is provided, it is
  /// used instead for custom batch handling.
  ///
  /// After deletion, the selection is cleared and the directory is refreshed.

  void _handleToolbarDelete() {
    if (widget.onDeleteItems != null) {
      widget.onDeleteItems!(currentPath, selectedItems);
      return;
    }

    // Take a snapshot of selected items before clearing.

    final items = Set<String>.from(_selectedItems);
    for (final key in items) {
      if (key.startsWith('file:')) {
        final fileName = key.substring(5);
        widget.onFileDelete(fileName, currentPath);
      }
    }
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
                  friendlyFolderName: _getEffectiveFriendlyFolderName(),
                  isLoading: isLoading,
                  currentDirFileCount: currentDirFileCount,
                  currentDirDirectoryCount: currentDirDirectoryCount,
                  canGoBack: canGoBack,
                  canGoForward: canGoForward,
                  canGoUp: canGoUp,
                  selectedCount: _selectedItems.length,
                  onNavigateBack: navigateBack,
                  onNavigateForward: navigateForward,
                  onNavigateUp: navigateToParent,
                  onNavigateHome: navigateHome,
                  onRefresh: refreshFiles,
                  onNewFolder: widget.onCreateFolder != null
                      ? () => widget.onCreateFolder!(currentPath)
                      : null,
                  onMoveTo: widget.onMoveItems != null
                      ? () => widget.onMoveItems!(currentPath, selectedItems)
                      : null,
                  onCopyTo: widget.onCopyItems != null
                      ? () => widget.onCopyItems!(currentPath, selectedItems)
                      : null,

                  // Download and Delete are always available since
                  // onFileDownload and onFileDelete are required callbacks.
                  // They use per-file callbacks unless batch overrides are
                  // provided via onDownloadItems / onDeleteItems.

                  onDownload: _handleToolbarDownload,
                  onRename: widget.onRenameItem != null
                      ? () => widget.onRenameItem!(
                            currentPath,
                            _selectedItems.first,
                          )
                      : null,
                  onDelete: _handleToolbarDelete,
                  currentSortOption: _currentSortOption,
                  onSortChanged: changeSortOption,
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
      selectedItems: _selectedItems,
      onDirectorySelected: navigateToDirectory,
      onFileSelected: (name, path) {
        widget.onFileSelected.call(name, path);
      },
      onToggleSelection: toggleItemSelection,
    );
  }
}
