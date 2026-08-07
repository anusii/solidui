/// A file list item widget for displaying individual files.
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

/// A widget that displays a single file item with its metadata.
///
/// The widget adapts its layout based on available width constraints:
/// - At < 40px: Shows only the file name.
/// - At 40-100px: Adds file icon with minimal spacing.
/// - At 100-150px: Increases icon spacing.
/// - At > 150px: Shows modification date.

class FileListItem extends StatelessWidget {
  /// The file item to display.

  final FileItem file;

  /// The current directory path.

  final String currentPath;

  /// Whether this file is currently selected via the checkbox.

  final bool isSelected;

  /// Callback when the file is tapped to view/open it.

  final Function(String, String) onFileSelected;

  /// Callback when the selection state is toggled.

  final VoidCallback onToggleSelect;

  const FileListItem({
    super.key,
    required this.file,
    required this.currentPath,
    required this.isSelected,
    required this.onFileSelected,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InkWell(
            onTap: () => onFileSelected(file.name, currentPath),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              // Apply selection highlighting using theme colours.
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
              ),

              // Adjust horizontal padding based on available width.
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 50 ? 4 : 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selection checkbox.
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Show file icon only if width permits.
                  if (constraints.maxWidth > 40)
                    Icon(
                      Icons.insert_drive_file,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),

                  // Responsive spacing after icon.
                  if (constraints.maxWidth > 40)
                    SizedBox(width: constraints.maxWidth < 100 ? 4 : 12),

                  // File information column.
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File name with overflow protection.
                        Text(
                          file.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Show modification date if width permits.
                        if (constraints.maxWidth > 150)
                          Text(
                            'Modified: ${file.dateModified.toString().split('.')[0]}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
