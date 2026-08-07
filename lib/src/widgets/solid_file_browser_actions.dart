/// Action handlers for [SolidFileBrowserState].
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

/// Extension grouping toolbar action handlers on [SolidFileBrowserState].

extension _BrowserActions on SolidFileBrowserState {
  /// Handles the toolbar Download action.
  ///
  /// If [widget.onDownloadItems] is provided, it is used for custom batch
  /// handling. Otherwise the built-in flow is used:
  /// - A single file with no directories selected: delegates to
  ///   [widget.onFileDownload] for a direct download.
  /// - Multiple files, any directories, or a mix: bundles everything into
  ///   a zip archive via [SolidFileDownloadOperations.downloadMultipleItems].

  Future<void> handleToolbarDownload() async {
    if (widget.onDownloadItems != null) {
      widget.onDownloadItems!(currentPath, selectedItems);
      return;
    }

    final items = Set<String>.from(_selectedItems);

    final fileNames = items
        .where((k) => k.startsWith('file:'))
        .map((k) => k.substring(5))
        .toList();
    final dirNames = items
        .where((k) => k.startsWith('dir:'))
        .map((k) => k.substring(4))
        .toList();

    // Single file, no directories → use the existing single-file download
    // which supports save-as dialogue and individual decryption.

    if (fileNames.length == 1 && dirNames.isEmpty) {
      widget.onFileDownload(fileNames.first, currentPath);
      return;
    }

    if (fileNames.isEmpty && dirNames.isEmpty) return;

    if (!mounted) return;

    // Derive a sensible zip file name:
    //  - Single folder selected  → use that folder's name.
    //  - Multiple items or mix   → use the current directory name.
    //  - Root directory ("")     → use "root".

    final String zipBaseName;
    if (dirNames.length == 1 && fileNames.isEmpty) {
      zipBaseName = dirNames.first;
    } else {
      final current = PathUtils.basename(currentPath);
      zipBaseName = current.isEmpty ? 'root' : current;
    }
    final zipFileName = '$zipBaseName.zip';

    await SolidFileDownloadOperations.downloadMultipleItems(
      context,
      currentPath: currentPath,
      fileNames: fileNames,
      directoryNames: dirNames,
      zipFileName: zipFileName,
    );
  }

  /// Handles the toolbar Print action.
  ///
  /// Only a single file may be printed at a time. Directories are excluded
  /// from the selection. If the file format is not printable, the user will be
  /// notified via a snackbar.

  Future<void> handleToolbarPrint() async {
    final items = Set<String>.from(_selectedItems);

    final fileNames = items
        .where((k) => k.startsWith('file:'))
        .map((k) => k.substring(5))
        .toList();

    if (fileNames.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to print.'),
          backgroundColor: ActionColors.warning,
        ),
      );

      return;
    }

    if (fileNames.length > 1) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only one file can be printed at a time.'),
          backgroundColor: ActionColors.warning,
        ),
      );

      return;
    }

    if (!mounted) return;

    await SolidFilePrintOperations.printFile(
      context,
      fileName: fileNames.first,
      currentPath: currentPath,
    );
  }

  /// Handles the toolbar Delete action.
  ///
  /// If [widget.onDeleteItems] is provided, it is used for custom batch
  /// handling. Otherwise the built-in unified flow is used, which deletes
  /// a mixed selection of files and directories in a single batch via
  /// [SolidFileDeleteOperations.deleteMultipleItems].

  Future<void> handleToolbarDelete() async {
    if (widget.onDeleteItems != null) {
      widget.onDeleteItems!(currentPath, selectedItems);
      return;
    }

    // Take a snapshot of selected items before clearing.

    final items = Set<String>.from(_selectedItems);

    // Separate files and directories.

    final fileNames = items
        .where((k) => k.startsWith('file:'))
        .map((k) => k.substring(5))
        .toList();
    final dirNames = items
        .where((k) => k.startsWith('dir:'))
        .map((k) => k.substring(4))
        .toList();

    if (fileNames.isEmpty && dirNames.isEmpty) return;

    if (!mounted) return;

    // Delegate to the unified batch delete UI which handles confirmation,
    // progress reporting and result feedback.

    await SolidFileDeleteOperations.deleteMultipleItems(
      context,
      currentPath: currentPath,
      fileNames: fileNames,
      directoryNames: dirNames,
      onSuccess: () {
        if (!mounted) return;

        // Purge deleted directory paths from navigation history so the
        // Back / Forward buttons cannot navigate into removed folders.

        final deletedPaths = dirNames
            .map((n) => PathUtils.combine(currentPath, n))
            .toList();
        _purgeDeletedPathsFromHistory(deletedPaths);

        _selectedItems.removeAll(items);
        refreshFiles();
      },
    );
  }

  /// Removes entries from [pathHistory] that match or are children of any
  /// path in [deletedPaths], then adjusts [_historyIndex] so it still
  /// points to [currentPath].
  ///
  /// This prevents the Back / Forward buttons from navigating into
  /// directories that no longer exist on the POD.

  void _purgeDeletedPathsFromHistory(List<String> deletedPaths) {
    if (deletedPaths.isEmpty) return;

    // A history entry should be removed when it exactly matches a deleted
    // path or is a descendant of one (i.e. starts with "deletedPath/").

    bool isDeleted(String entry) {
      return deletedPaths.any((dp) => entry == dp || entry.startsWith('$dp/'));
    }

    // Remember the current entry so we can re-locate the index afterwards.

    final currentEntry = pathHistory[_historyIndex];

    pathHistory.removeWhere(isDeleted);

    // Re-calculate the index. The current entry should still be present
    // because we are viewing the parent directory, not the deleted one.

    final newIndex = pathHistory.indexOf(currentEntry);
    _historyIndex = newIndex != -1 ? newIndex : pathHistory.length - 1;
  }

  /// Handles the "New Folder" action.
  ///
  /// If the user provides [widget.onCreateFolder], it is invoked as a
  /// custom override. Otherwise the built-in flow is used: a dialog prompts
  /// for the folder name, the container is created on the POD via
  /// [createContainer] from solidpod, and the directory listing is refreshed.

  Future<void> handleCreateFolder() async {
    // Delegate to the user's custom handler when provided.

    if (widget.onCreateFolder != null) {
      widget.onCreateFolder!(currentPath);
      return;
    }

    // Show the folder name input dialog.

    final folderName = await _showNewFolderDialog();
    if (folderName == null || folderName.isEmpty) return;

    // Check for duplicate folder names in the current directory.

    if (directories.contains(folderName)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A folder named "$folderName" already exists.'),
          backgroundColor: ActionColors.error,
        ),
      );
      return;
    }

    // Create the container on the POD.

    if (!mounted) return;
    updateState(() => isLoading = true);

    try {
      await createContainer(currentPath, folderName);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folder "$folderName" created successfully.'),
          backgroundColor: ActionColors.success,
        ),
      );

      await refreshFiles();
    } catch (e) {
      debugPrint('Error creating folder "$folderName": $e');
      if (!mounted) return;
      updateState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create folder: $e'),
          backgroundColor: ActionColors.error,
        ),
      );
    }
  }

  /// Displays a dialog prompting the user for a new folder name.
  ///
  /// Returns the entered folder name, or `null` if the dialog was dismissed.

  Future<String?> _showNewFolderDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Folder name',
                hintText: 'Enter folder name',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Folder name cannot be empty.';
                }

                try {
                  validateContainerName(value.trim());
                } on ArgumentError catch (e) {
                  return e.message as String;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
