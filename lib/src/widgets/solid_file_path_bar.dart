/// A toolbar and path bar widget for file browser navigation.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/models/file_sort_option.dart';

/// A toolbar and path bar widget that provides navigation controls and
/// file operation actions.

class PathBar extends StatelessWidget {
  /// The current directory path being displayed.

  final String currentPath;

  /// Friendly folder name for display.

  final String friendlyFolderName;

  /// Whether the file browser is currently loading.

  final bool isLoading;

  /// Number of files in the current directory.

  final int currentDirFileCount;

  /// Number of directories in the current directory.

  final int currentDirDirectoryCount;

  /// Whether the user can navigate back in history.

  final bool canGoBack;

  /// Whether the user can navigate forward in history.

  final bool canGoForward;

  /// Whether the user can navigate to the parent directory.

  final bool canGoUp;

  /// Number of currently selected items.

  final int selectedCount;

  /// Callback for navigating back in history.

  final VoidCallback onNavigateBack;

  /// Callback for navigating forward in history.

  final VoidCallback onNavigateForward;

  /// Callback for navigating to the parent directory.

  final VoidCallback onNavigateUp;

  /// Callback for navigating to the home directory.

  final VoidCallback onNavigateHome;

  /// Callback for refreshing the current directory.

  final VoidCallback onRefresh;

  /// Callback for creating a new folder. Null disables the button.

  final VoidCallback? onNewFolder;

  /// Callback for moving selected items. Null disables the button.

  final VoidCallback? onMoveTo;

  /// Callback for copying selected items. Null disables the button.

  final VoidCallback? onCopyTo;

  /// Callback for downloading selected items. Null disables the button.

  final VoidCallback? onDownload;

  /// Callback for printing the selected file. Null disables the button.

  final VoidCallback? onPrint;

  /// Callback for renaming the selected item. Null disables the button.

  final VoidCallback? onRename;

  /// Callback for deleting selected items. Null disables the button.

  final VoidCallback? onDelete;

  /// The currently active sort option.

  final FileSortOption currentSortOption;

  /// Callback when the user selects a different sort option.

  final ValueChanged<FileSortOption> onSortChanged;

  const PathBar({
    super.key,
    required this.currentPath,
    required this.friendlyFolderName,
    required this.isLoading,
    required this.currentDirFileCount,
    required this.currentDirDirectoryCount,
    required this.canGoBack,
    required this.canGoForward,
    required this.canGoUp,
    required this.selectedCount,
    required this.onNavigateBack,
    required this.onNavigateForward,
    required this.onNavigateUp,
    required this.onNavigateHome,
    required this.onRefresh,
    this.onNewFolder,
    this.onMoveTo,
    this.onCopyTo,
    this.onDownload,
    this.onPrint,
    this.onRename,
    this.onDelete,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedCount > 0;
    final bool singleSelection = selectedCount == 1;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar row with navigation buttons (left) and action
            // buttons (right). Uses LayoutBuilder to ensure proper spacing
            // on wide screens whilst remaining scrollable on narrow ones.

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side: Navigation buttons.

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNavButton(
                              context,
                              icon: Icons.arrow_back,
                              label: 'Back',
                              onPressed: canGoBack ? onNavigateBack : null,
                            ),
                            _buildNavButton(
                              context,
                              icon: Icons.arrow_forward,
                              label: 'Forward',
                              onPressed:
                                  canGoForward ? onNavigateForward : null,
                            ),
                            _buildNavButton(
                              context,
                              icon: Icons.arrow_upward,
                              label: 'Up',
                              onPressed: canGoUp ? onNavigateUp : null,
                            ),
                            _buildNavButton(
                              context,
                              icon: Icons.home,
                              label: 'Home',
                              onPressed: onNavigateHome,
                            ),
                          ],
                        ),

                        // Right side: Action buttons.

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              context,
                              icon: Icons.create_new_folder,
                              label: 'New Folder',
                              onPressed: onNewFolder,
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.drive_file_move,
                              label: 'Move to',
                              onPressed: hasSelection ? onMoveTo : null,
                              tooltipMessage: 'Under development',
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.file_copy,
                              label: 'Copy to',
                              onPressed: hasSelection ? onCopyTo : null,
                              tooltipMessage: 'Under development',
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.download,
                              label: 'Download',
                              onPressed: hasSelection ? onDownload : null,
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.print,
                              label: 'Print',
                              onPressed: hasSelection ? onPrint : null,
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.edit,
                              label: 'Rename',
                              onPressed: singleSelection ? onRename : null,
                              tooltipMessage: 'Under development',
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.delete,
                              label: 'Delete',
                              onPressed: hasSelection ? onDelete : null,
                              isDestructive: true,
                            ),

                            // Vertical divider before View menu.

                            Container(
                              height: 24,
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              color: Theme.of(context).dividerColor,
                            ),

                            // View / Sort dropdown menu.

                            _buildViewDropdown(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Path info row with friendly name, counts, and refresh.

            Row(
              children: [
                // Friendly folder name.

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

                // Show selection count when items are selected, otherwise
                // show directory and file counts.

                if (selectedCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      '$selectedCount selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      final total =
                          currentDirDirectoryCount + currentDirFileCount;
                      final dirs = currentDirDirectoryCount;
                      final files = currentDirFileCount;
                      return Text(
                        '$total item${total == 1 ? '' : 's'}'
                        ' ($dirs director${dirs == 1 ? 'y' : 'ies'}'
                        ' and $files file${files == 1 ? '' : 's'})',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),

                const SizedBox(width: 12),

                // Refresh button.

                MarkdownTooltip(
                  message: '**Refresh**',
                  child: IconButton(
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
                    onPressed: isLoading ? null : onRefresh,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Full current path with horizontal scrolling.

            SizedBox(
              height: 20,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  currentPath.isEmpty ? '/' : currentPath,
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

  /// Builds a compact icon-only navigation button with a tooltip.

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return MarkdownTooltip(
      message: '**$label**',
      child: Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  /// Builds a compact icon-only action button with a [MarkdownTooltip].
  ///
  /// The button label is shown exclusively in the tooltip. When
  /// [tooltipMessage] is provided it is appended beneath the label.
  /// When [isDestructive] is true, the button uses the error colour scheme
  /// to indicate a destructive action such as deletion.

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isDestructive = false,
    String? tooltipMessage,
  }) {
    final colour = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    final tooltip =
        tooltipMessage != null ? '**$label**\n\n$tooltipMessage' : '**$label**';

    return MarkdownTooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            foregroundColor: onPressed != null ? colour : null,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  /// Builds the View dropdown menu for sorting options.
  ///
  /// Uses compact [PopupMenuItem]s with a small leading tick icon instead
  /// of the wider [CheckedPopupMenuItem] to keep the menu narrow.

  Widget _buildViewDropdown(BuildContext context) {
    return MarkdownTooltip(
      message: '**Sort options**',
      child: PopupMenuButton<FileSortOption>(
        tooltip: '',
        onSelected: onSortChanged,
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(minWidth: 0),
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildSortMenuItem(context, FileSortOption.nameAscending),
          _buildSortMenuItem(context, FileSortOption.nameDescending),
          const PopupMenuDivider(height: 1),
          _buildSortMenuItem(context, FileSortOption.dateModifiedAscending),
          _buildSortMenuItem(context, FileSortOption.dateModifiedDescending),
          const PopupMenuDivider(height: 1),
          _buildSortMenuItem(context, FileSortOption.typeAscending),
          _buildSortMenuItem(context, FileSortOption.typeDescending),
        ],
      ),
    );
  }

  /// Builds a single compact sort menu item with a small tick when active.

  PopupMenuEntry<FileSortOption> _buildSortMenuItem(
    BuildContext context,
    FileSortOption option,
  ) {
    final isActive = currentSortOption == option;

    return PopupMenuItem<FileSortOption>(
      value: option,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            child: isActive
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            option.displayLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
