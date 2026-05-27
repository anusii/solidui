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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/models/file_item.dart';
import 'package:solidui/src/models/file_sort_option.dart';
import 'package:solidui/src/utils/file_operations.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_file_operations_delete.dart';
import 'package:solidui/src/utils/solid_file_operations_download.dart';
import 'package:solidui/src/utils/solid_file_operations_print.dart';
import 'package:solidui/src/widgets/solid_file_browser_content.dart';
import 'package:solidui/src/widgets/solid_file_browser_loading_state.dart';
import 'package:solidui/src/widgets/solid_file_browser_not_logged_in.dart';
import 'package:solidui/src/widgets/solid_file_empty_directory_view.dart';
import 'package:solidui/src/widgets/solid_file_operations.dart';
import 'package:solidui/src/widgets/solid_file_path_bar.dart';

part 'solid_file_browser_actions.dart';
part 'solid_file_browser_navigation.dart';

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

  /// Callback for uploading a file into the current directory.
  ///
  /// When provided, a dedicated upload button is shown in the toolbar at the
  /// top of the browser. The intent is to share a single handler with the
  /// side-panel upload button so users have two equivalent entry points
  /// driven by the same code path. Null hides/disables the toolbar button.

  final VoidCallback? onUpload;

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
    this.onUpload,
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

  /// Public wrapper around [setState].
  ///
  /// Extensions on this state cannot call [setState] directly because the
  /// framework declares it as `@protected`. This helper forwards to it so the
  /// extension methods can request a rebuild without subclassing.

  void updateState(VoidCallback fn) {
    setState(fn);
  }

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

  Future<void> navigateToDirectory(String dirName) =>
      performNavigateToDirectory(dirName);

  /// Navigates back in history (browser-style back).

  Future<void> navigateBack() => performNavigateBack();

  /// Navigates forward in history (browser-style forward).

  Future<void> navigateForward() => performNavigateForward();

  /// Navigates to the parent directory of the current path.

  Future<void> navigateToParent() => performNavigateToParent();

  /// Navigates to the home directory.

  Future<void> navigateHome() => performNavigateHome();

  /// Navigates up one directory level.

  Future<void> navigateUp() => performNavigateBack();

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

  /// Adds or removes a batch of item keys in a single setState call.
  ///
  /// When [selected] is true every key in [keys] is added to the
  /// selection; when false every key is removed.

  void batchSetSelection(List<String> keys, {required bool selected}) {
    setState(() {
      if (selected) {
        _selectedItems.addAll(keys);
      } else {
        _selectedItems.removeAll(keys);
      }
    });
  }

  /// Changes the current sort option and re-sorts the displayed items.

  void changeSortOption(FileSortOption option) =>
      performChangeSortOption(option);

  /// Refreshes the current directory's contents from the Solid POD.

  Future<void> refreshFiles() => performRefreshFiles();

  /// Navigate to a specific path in the file browser.

  void navigateToPath(String path) => performNavigateToPath(path);

  /// Handles the toolbar Download action.

  Future<void> _handleToolbarDownload() => handleToolbarDownload();

  /// Handles the toolbar Delete action.

  Future<void> _handleToolbarDelete() => handleToolbarDelete();

  /// Handles the toolbar Print action.

  Future<void> _handleToolbarPrint() => handleToolbarPrint();

  /// Handles the "New Folder" action.

  Future<void> _handleCreateFolder() => handleCreateFolder();

  /// Gets the effective friendly folder name based on the current path.

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
                  onNewFolder: _handleCreateFolder,
                  onUpload: widget.onUpload,
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
                  onPrint: _handleToolbarPrint,
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
      onBatchSetSelection: batchSetSelection,
    );
  }
}
