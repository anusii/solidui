/// Navigation, sorting and data-loading methods for [SolidFileBrowserState].
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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

part of 'solid_file_browser.dart';

/// Extension grouping navigation and data-loading methods on
/// [SolidFileBrowserState].

extension BrowserNavigation on SolidFileBrowserState {
  /// Navigates into a subdirectory.

  Future<void> performNavigateToDirectory(String dirName) async {
    if (!mounted) return;
    final newPath = PathUtils.combine(currentPath, dirName);
    await _navigateTo(newPath);
  }

  /// Navigates back in history (browser-style back).

  Future<void> performNavigateBack() async {
    if (!canGoBack || !mounted) return;
    _selectedItems.clear();
    updateState(() {
      _historyIndex--;
      currentPath = pathHistory[_historyIndex];
    });
    widget.onDirectoryChanged.call(currentPath);
    await refreshFiles();
  }

  /// Navigates forward in history (browser-style forward).

  Future<void> performNavigateForward() async {
    if (!canGoForward || !mounted) return;
    _selectedItems.clear();
    updateState(() {
      _historyIndex++;
      currentPath = pathHistory[_historyIndex];
    });
    widget.onDirectoryChanged.call(currentPath);
    await refreshFiles();
  }

  /// Navigates to the parent directory of the current path.

  Future<void> performNavigateToParent() async {
    if (!canGoUp || !mounted) return;
    final parentPath = PathUtils.parent(currentPath);
    await _navigateTo(parentPath);
  }

  /// Navigates to the home directory.

  Future<void> performNavigateHome() async {
    if (!mounted) return;
    await _navigateTo(_homePath);
  }

  /// Changes the current sort option and re-sorts the displayed items.

  void performChangeSortOption(FileSortOption option) {
    if (option == _currentSortOption) return;
    updateState(() {
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
        directories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        files.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case FileSortOption.nameDescending:
        directories.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
        files.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case FileSortOption.dateModifiedAscending:
        directories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        files.sort((a, b) => a.dateModified.compareTo(b.dateModified));
      case FileSortOption.dateModifiedDescending:
        directories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        files.sort((a, b) => b.dateModified.compareTo(a.dateModified));
      case FileSortOption.typeAscending:
        directories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        files.sort((a, b) {
          final cmp = _fileExtension(a.name).compareTo(_fileExtension(b.name));
          // Fall back to name order when extensions match.

          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case FileSortOption.typeDescending:
        directories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        files.sort((a, b) {
          final cmp = _fileExtension(b.name).compareTo(_fileExtension(a.name));
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
    updateState(() {
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

  Future<void> performRefreshFiles() async {
    if (!isLoggedIn) {
      if (mounted) updateState(() => isLoading = false);
      return;
    }

    if (!mounted) return;
    updateState(() => isLoading = true);

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
      // that reference items no longer present in the directory listing.

      updateState(() {
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
      if (mounted) updateState(() => isLoading = false);
    }
  }

  /// Loads file counts for each subdirectory in the background.
  ///
  /// Updates the UI incrementally as each count becomes available, rather
  /// than blocking the initial render on N REST calls.

  Future<void> _loadDirectoryCountsInBackground(List<String> dirs) async {
    final requestPath = currentPath;

    final counts = await FileOperations.getDirectoryCounts(requestPath, dirs);

    if (!mounted) return;

    // Only apply the results if the user is still viewing the same directory.

    if (currentPath == requestPath) {
      updateState(() => directoryCounts = counts);
    }
  }

  /// Navigate to a specific path in the file browser.

  void performNavigateToPath(String path) {
    final normalisedPath = PathUtils.normalise(path);

    updateState(() {
      currentPath = normalisedPath;
      _selectedItems.clear();

      if (normalisedPath == _homePath || normalisedPath.isEmpty) {
        pathHistory = [_homePath];
        _historyIndex = 0;
      } else {
        if (pathHistory.isEmpty || pathHistory.last != normalisedPath) {
          if (_homePath.isEmpty || normalisedPath.startsWith('$_homePath/')) {
            pathHistory = [_homePath];
            final relativePath = PathUtils.relativeTo(
              normalisedPath,
              _homePath,
            );
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
}
