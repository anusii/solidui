/// A directory list widget for displaying folders.
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

/// A widget that displays a list of directories with their file counts.

class DirectoryList extends StatelessWidget {
  /// List of directory names to display.

  final List<String> directories;

  /// Map of directory names to their file counts.

  final Map<String, int> directoryCounts;

  /// Callback when a directory is selected.

  final Function(String) onDirectorySelected;

  const DirectoryList({
    super.key,
    required this.directories,
    required this.directoryCounts,
    required this.onDirectorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no directories to display.

    if (directories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header for directories.

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Folders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),

        // List of directory items.

        ...directories.map(
          (dir) => ListTile(
            leading: Icon(
              Icons.folder,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Row(
              children: [
                // Directory name with overflow protection.

                Expanded(
                  child: Text(
                    dir,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // File count badge.

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${directoryCounts[dir] ?? 0} files',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            onTap: () => onDirectorySelected(dir),
            tileColor: Theme.of(context).cardColor,
            selectedTileColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
