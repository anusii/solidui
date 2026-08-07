/// A scrollable list of resource names for the grant permission UI.
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

import 'package:solidui/src/utils/path_utils.dart';

/// A height-capped scrollable list of resource names, left-aligned.
///
/// Shows a scrollbar when the list is long enough to scroll (> 3 items).
///
/// Parameters:
/// - [resourceNames] - The list of resource names to display.
/// - [showFullPath] - Whether to show the full path or just the last segment.
/// - [showTitle] - When true, uses [titleData] to display a human-readable
///   title for each resource instead of the path. Defaults to false.
/// - [titleData] - Optional map from resource key to display title, used
///   when [showTitle] is true.

class GrantPermissionResourceList extends StatefulWidget {
  const GrantPermissionResourceList({
    super.key,
    required this.resourceNames,
    required this.showFullPath,
    this.showTitle = false,
    this.titleData,
  }) : assert(
          !showTitle || titleData != null,
          'titleData must not be null when showTitle is true',
        );

  final List<String> resourceNames;
  final bool showFullPath;
  final bool showTitle;
  final Map<String, String>? titleData;

  @override
  State<GrantPermissionResourceList> createState() =>
      _GrantPermissionResourceListState();
}

class _GrantPermissionResourceListState
    extends State<GrantPermissionResourceList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _displayName(String name) => PathUtils.resourceDisplayName(
        name,
        showFullPath: widget.showFullPath,
        showTitle: widget.showTitle,
        titleData: widget.titleData,
      );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: Scrollbar(
        controller: _scrollController,
        // Show scrollbar always if > 3 selected
        // as this is when widget will be scrollable
        thumbVisibility: widget.resourceNames.length > 3,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final name in widget.resourceNames)
                Align(
                  alignment: Alignment.centerLeft,
                  // Add 2 pixel vertical padding and
                  // 1 pixel padding on RHS to avoid scrollbar
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 1, 2),
                    child: Text(
                      _displayName(name),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
