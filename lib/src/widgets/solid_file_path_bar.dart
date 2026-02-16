/// A path bar widget for file browser navigation.
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

/// A path bar widget that displays the current directory path and provides
/// navigation controls.

class PathBar extends StatelessWidget {
  /// The current directory path being displayed.

  final String currentPath;

  /// History of visited directories for navigation.

  final List<String> pathHistory;

  /// Callback when the user wants to navigate up one directory.

  final VoidCallback onNavigateUp;

  /// Callback when the user wants to refresh the current directory.

  final VoidCallback onRefresh;

  /// Whether the file browser is currently loading.

  final bool isLoading;

  /// Number of files in the current directory.

  final int currentDirFileCount;

  /// Number of directories in the current directory.

  final int currentDirDirectoryCount;

  /// Friendly folder name.

  final String friendlyFolderName;

  const PathBar({
    super.key,
    required this.currentPath,
    required this.pathHistory,
    required this.onNavigateUp,
    required this.onRefresh,
    required this.isLoading,
    required this.currentDirFileCount,
    required this.currentDirDirectoryCount,
    required this.friendlyFolderName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar with back button, friendly name, and refresh button.
            Row(
              children: [
                // Back button (only shown if there's history).
                if (pathHistory.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip: 'Back to $friendlyFolderName',
                    onPressed: onNavigateUp,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (pathHistory.length > 1) const SizedBox(width: 12),

                // Path text display.
                Expanded(
                  child: Text(
                    friendlyFolderName,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // File and directory counts.
                Row(
                  children: [
                    Text(
                      'Directories: $currentDirDirectoryCount',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Files: $currentDirFileCount',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Refresh button.
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            color: Theme.of(context).iconTheme.color,
                          ),
                  ),
                  tooltip: 'Refresh',
                  onPressed: isLoading ? null : onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Full current path with horizontal scrolling.
            SizedBox(
              height: 20,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  currentPath,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
