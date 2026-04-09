/// A dropdown menu for selecting a resource from a list of resource names.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/constants/ui_common.dart';

/// A dropdown menu for selecting which resource's permissions to display,
/// followed by the currently selected resource name.
///
/// Parameters:
/// - [resourceNames] - The list of resource names to display in the dropdown.
/// - [selectedResourceName] - The currently selected resource name, if any.
/// - [isFile] - Whether the resources are files (true) or folders (false),
/// used for the dropdown label.
/// - [showFullPath] - Whether to show full paths or just the last path segment.
/// - [onSelected] - Callback invoked with the newly selected resource name.

class PermissionDropdownResourceList extends StatelessWidget {
  const PermissionDropdownResourceList({
    super.key,
    required this.resourceNames,
    required this.selectedResourceName,
    required this.isFile,
    required this.showFullPath,
    required this.onSelected,
  });

  final List<String> resourceNames;
  final String? selectedResourceName;
  final bool isFile;
  final bool showFullPath;
  final Future<void> Function(String name) onSelected;

  String _displayName(String name) =>
      showFullPath ? name : name.split('/').last;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu<String>(
          // Force rebuild if showFullPath changes
          key: ValueKey(showFullPath),
          // Set inset padding on sides of dropdown
          // to zero to align with other elements in the layout
          expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
          initialSelection: null,
          label: Text(isFile ? 'Select File' : 'Select Folder'),
          textStyle: Theme.of(context)
                  .dropdownMenuTheme
                  .textStyle
                  ?.copyWith(fontSize: 12) ??
              const TextStyle(fontSize: 12),
          // Setting edge insets to zero also helped with
          // left-right edge alignment
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.zero,
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context)
                      .dropdownMenuTheme
                      .menuStyle
                      ?.backgroundColor
                      ?.resolve({}) ??
                  DropdownColors.accent,
            ),
          ),
          dropdownMenuEntries: resourceNames.map(
            (name) {
              final isSelected = name == selectedResourceName;
              final textColor =
                  Theme.of(context).dropdownMenuTheme.textStyle?.color;
              return DropdownMenuEntry(
                value: name,
                label: _displayName(name),
                trailingIcon:
                    isSelected ? Icon(Icons.check, color: textColor) : null,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).dropdownMenuTheme.textStyle?.copyWith(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ) ??
                        TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                  foregroundColor: WidgetStatePropertyAll(textColor),
                  backgroundColor: WidgetStatePropertyAll(
                    isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.4)
                        : null,
                  ),
                ),
              );
            },
          ).toList(),
          onSelected: (name) async {
            if (name != null && name != selectedResourceName) {
              await onSelected(name);
            }
          },
        ),
        smallGapV,
        if (selectedResourceName != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _displayName(selectedResourceName!),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ),
        smallGapV,
      ],
    );
  }
}
