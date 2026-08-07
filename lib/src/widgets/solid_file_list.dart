/// A file list widget for displaying files.
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

import 'package:solidui/src/models/file_item.dart';
import 'package:solidui/src/widgets/solid_file_list_item.dart';

/// A widget that displays a list of files with their metadata and actions.

class FileList extends StatelessWidget {
  /// List of files to display.

  final List<FileItem> files;

  /// The current directory path.

  final String currentPath;

  /// Set of currently selected item keys (e.g. "file:fileName").

  final Set<String> selectedItems;

  /// Callback when a file is tapped to view/open it.

  final Function(String, String) onFileSelected;

  /// Callback to toggle selection of an item by its key.

  final Function(String) onToggleSelection;

  /// Callback to add or remove a batch of item keys in one operation.

  final void Function(List<String> keys, {required bool selected})
  onBatchSetSelection;

  const FileList({
    super.key,
    required this.files,
    required this.currentPath,
    required this.selectedItems,
    required this.onFileSelected,
    required this.onToggleSelection,
    required this.onBatchSetSelection,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no files to display.

    if (files.isEmpty) return const SizedBox.shrink();

    // Compute the selection state for the select-all checkbox.

    final allKeys = files.map((f) => 'file:${f.name}').toList();
    final selectedCount = allKeys
        .where((k) => selectedItems.contains(k))
        .length;
    final allSelected = selectedCount == files.length;
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
                'Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ),

        // List of file items with selection support.
        ...files.map((file) {
          final itemKey = 'file:${file.name}';

          return FileListItem(
            file: file,
            currentPath: currentPath,
            isSelected: selectedItems.contains(itemKey),
            onFileSelected: onFileSelected,
            onToggleSelect: () => onToggleSelection(itemKey),
          );
        }),
      ],
    );
  }
}
