/// A path bar widget for file browser navigation.
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
    required this.friendlyFolderName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
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

            // File count.

            Text(
              'Files in current directory: $currentDirFileCount',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
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
      ),
    );
  }
}
