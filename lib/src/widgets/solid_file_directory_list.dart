/// A directory list widget for displaying folders.
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

/// A widget that displays a list of directories with their item counts.

class DirectoryList extends StatelessWidget {
  /// List of directory names to display.

  final List<String> directories;

  /// Map of directory names to their item counts (files + folders).

  final Map<String, int> directoryCounts;

  /// Set of currently selected item keys (e.g. "dir:folderName").

  final Set<String> selectedItems;

  /// Callback when a directory is tapped to navigate into it.

  final Function(String) onDirectorySelected;

  /// Callback to toggle selection of an item by its key.

  final Function(String) onToggleSelection;

  /// Callback to add or remove a batch of item keys in one operation.

  final void Function(List<String> keys, {required bool selected})
  onBatchSetSelection;

  const DirectoryList({
    super.key,
    required this.directories,
    required this.directoryCounts,
    required this.selectedItems,
    required this.onDirectorySelected,
    required this.onToggleSelection,
    required this.onBatchSetSelection,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no directories to display.

    if (directories.isEmpty) return const SizedBox.shrink();

    // Compute the selection state for the select-all checkbox.

    final allKeys = directories.map((d) => 'dir:$d').toList();
    final selectedCount = allKeys
        .where((k) => selectedItems.contains(k))
        .length;
    final allSelected = selectedCount == directories.length;
    final noneSelected = selectedCount == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with a select-all checkbox.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: allSelected
                      ? true
                      : noneSelected
                      ? false
                      : null,
                  tristate: true,
                  onChanged: (_) {
                    if (allSelected) {
                      onBatchSetSelection(allKeys, selected: false);
                    } else {
                      onBatchSetSelection(allKeys, selected: true);
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Folders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ),

        // List of directory items with selection checkboxes.
        ...directories.map((dir) {
          final itemKey = 'dir:$dir';
          final isSelected = selectedItems.contains(itemKey);

          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selection checkbox.
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelection(itemKey),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),

                // Folder icon.
                Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
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

                // Item count badge. Shows a compact loading indicator while
                // counts are being fetched in the background.
                if (directoryCounts.containsKey(dir))
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
                      '${directoryCounts[dir]}'
                      ' item${directoryCounts[dir] == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            onTap: () => onDirectorySelected(dir),
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Theme.of(context).cardColor,
            selectedTileColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
          );
        }),
      ],
    );
  }
}
