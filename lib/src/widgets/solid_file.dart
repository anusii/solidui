/// File service widget.
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

import 'package:solidui/src/models/file_type_config.dart';
import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_upload_area.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// Configuration for the SolidFile widget.

class SolidFileConfig {
  /// Base path for file operations.

  final String basePath;

  /// Whether to show the back button.

  final bool showBackButton;

  /// Text for the back button.

  final String backButtonText;

  /// Whether to use wide screen layout.

  final bool? forceWideScreen;

  /// Custom height for the file browser.

  final double? browserHeight;

  const SolidFileConfig({
    required this.basePath,
    this.showBackButton = true,
    this.backButtonText = 'Back to Home Folder',
    this.forceWideScreen,
    this.browserHeight,
  });
}

/// Callbacks for SolidFile operations.

class SolidFileCallbacks {
  /// Callback when back button is pressed.

  final VoidCallback? onBackPressed;

  /// Callback when a file is selected.

  final Function(String fileName, String filePath)? onFileSelected;

  /// Callback when a file should be downloaded.

  final Function(String fileName, String filePath)? onFileDownload;

  /// Callback when a file should be deleted.

  final Function(String fileName, String filePath)? onFileDelete;

  /// Callback when directory changes.

  final Function(String path)? onDirectoryChanged;

  /// Callback for CSV import.

  final Function(String fileName, String filePath)? onImportCsv;

  /// Upload area callbacks.

  final SolidFileUploadCallbacks? uploadCallbacks;

  const SolidFileCallbacks({
    this.onBackPressed,
    this.onFileSelected,
    this.onFileDownload,
    this.onFileDelete,
    this.onDirectoryChanged,
    this.onImportCsv,
    this.uploadCallbacks,
  });
}

/// State for the SolidFile widget.

class SolidFileState {
  /// Current path in the file browser.

  final String currentPath;

  /// Friendly name for the current folder.

  final String friendlyFolderName;

  /// Upload area state.

  final SolidFileUploadState? uploadState;

  /// Upload area configuration.

  final SolidFileUploadConfig? uploadConfig;

  const SolidFileState({
    required this.currentPath,
    required this.friendlyFolderName,
    this.uploadState,
    this.uploadConfig,
  });
}

/// A comprehensive file management widget combining file browser and upload
/// functionality.

class SolidFile extends StatefulWidget {
  /// Base path for file operations.

  final String basePath;

  /// Current path in the file browser.

  final String? currentPath;

  /// Friendly name for the current folder.

  final String? friendlyFolderName;

  /// Whether to show the back button.

  final bool showBackButton;

  /// Text for the back button.

  final String backButtonText;

  /// Whether to use wide screen layout.

  final bool? forceWideScreen;

  /// Custom height for the file browser.

  final double? browserHeight;

  /// Callback when back button is pressed.

  final VoidCallback? onBackPressed;

  /// Callback when a file is selected.

  final Function(String fileName, String filePath)? onFileSelected;

  /// Callback when a file should be downloaded.

  final Function(String fileName, String filePath)? onFileDownload;

  /// Callback when a file should be deleted.

  final Function(String fileName, String filePath)? onFileDelete;

  /// Callback when directory changes.

  final Function(String path)? onDirectoryChanged;

  /// Callback for CSV import.

  final Function(String fileName, String filePath)? onImportCsv;

  /// Whether to show upload functionality.

  final bool showUpload;

  /// Upload configuration.
  /// If null, will be auto-generated based on currentPath.

  final SolidFileUploadConfig? uploadConfig;

  /// Upload callbacks.

  final SolidFileUploadCallbacks? uploadCallbacks;

  /// Upload state.

  final SolidFileUploadState? uploadState;

  /// Global key for the file browser.

  final GlobalKey<SolidFileBrowserState>? browserKey;

  /// Whether to automatically configure upload settings based on path.
  /// Defaults to true for convenience.

  final bool autoConfig;

  const SolidFile({
    super.key,
    required this.basePath,
    this.currentPath,
    this.friendlyFolderName,
    this.showBackButton = true,
    this.backButtonText = 'Back to Home Folder',
    this.forceWideScreen,
    this.browserHeight,
    this.onBackPressed,
    this.onFileSelected,
    this.onFileDownload,
    this.onFileDelete,
    this.onDirectoryChanged,
    this.onImportCsv,
    this.showUpload = true,
    this.uploadConfig,
    this.uploadCallbacks,
    this.uploadState,
    this.browserKey,
    this.autoConfig = true,
  });

  /// Legacy constructor for backward compatibility.

  SolidFile.withConfig({
    super.key,
    required SolidFileConfig config,
    required SolidFileCallbacks callbacks,
    required SolidFileState state,
    this.browserKey,
  })  : basePath = config.basePath,
        currentPath = state.currentPath,
        friendlyFolderName = state.friendlyFolderName,
        showBackButton = config.showBackButton,
        backButtonText = config.backButtonText,
        forceWideScreen = config.forceWideScreen,
        browserHeight = config.browserHeight,
        onBackPressed = callbacks.onBackPressed,
        onFileSelected = callbacks.onFileSelected,
        onFileDownload = callbacks.onFileDownload,
        onFileDelete = callbacks.onFileDelete,
        onDirectoryChanged = callbacks.onDirectoryChanged,
        onImportCsv = callbacks.onImportCsv,
        showUpload = state.uploadConfig != null,
        uploadConfig = state.uploadConfig,
        uploadCallbacks = callbacks.uploadCallbacks,
        uploadState = state.uploadState,
        autoConfig = false; // Legacy mode does not use auto-config

  @override
  State<SolidFile> createState() => _SolidFileState();
}

class _SolidFileState extends State<SolidFile> {
  late GlobalKey<SolidFileBrowserState> _browserKey;
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _browserKey = widget.browserKey ?? GlobalKey<SolidFileBrowserState>();
    _currentPath = widget.currentPath ?? widget.basePath;
  }

  @override
  void didUpdateWidget(covariant SolidFile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = oldWidget.currentPath ?? oldWidget.basePath;
    final newPath = widget.currentPath ?? widget.basePath;

    if (oldPath != newPath && newPath != _currentPath) {
      setState(() {
        _currentPath = newPath;
      });
    }
  }

  /// Determines if we should use wide screen layout.

  bool _shouldUseWideScreen(BuildContext context) {
    if (widget.forceWideScreen != null) {
      return widget.forceWideScreen!;
    }
    return MediaQuery.of(context).size.width > 800;
  }

  /// Gets the effective browser height.

  double _getBrowserHeight(BuildContext context) {
    if (widget.browserHeight != null) {
      return widget.browserHeight!;
    }
    return MediaQuery.of(context).size.height * 0.7;
  }

  /// Gets the effective upload configuration, either from the provided config
  /// or auto-generated based on the current path when autoConfig is true.

  SolidFileUploadConfig? _getEffectiveUploadConfig() {
    if (widget.uploadConfig != null) {
      return widget.uploadConfig;
    }

    if (widget.autoConfig && widget.showUpload) {
      final typeConfig = FileTypeConfig.fromPath(_currentPath, widget.basePath);
      return typeConfig.createUploadConfig();
    }

    return null;
  }

  /// Gets the effective friendly folder name, either from the provided name
  /// or auto-generated based on the current path when autoConfig is true.

  String _getEffectiveFriendlyFolderName() {
    if (widget.friendlyFolderName != null) {
      return widget.friendlyFolderName!;
    }

    if (widget.autoConfig) {
      final typeConfig = FileTypeConfig.fromPath(_currentPath, widget.basePath);
      return typeConfig.displayName;
    }

    return 'Files';
  }

  /// Handles directory changes and updates internal state.

  void _handleDirectoryChanged(String path) {
    setState(() {
      _currentPath = path;
    });

    // Call the external callback if provided.

    widget.onDirectoryChanged?.call(path);
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = _shouldUseWideScreen(context);
    final browserHeight = _getBrowserHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button to root folder.

        if (widget.showBackButton)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextButton.icon(
              onPressed: widget.onBackPressed ??
                  () {
                    // Default behavior: reset to base path.

                    setState(() {
                      _currentPath = widget.basePath;
                    });

                    // Refresh the browser to the base path.

                    _browserKey.currentState?.navigateToPath(widget.basePath);
                  },
              icon: const Icon(Icons.home),
              label: Text(widget.backButtonText),
            ),
          ),

        // Main content area.

        Expanded(
          child: SingleChildScrollView(
            child: isWideScreen
                ? _buildWideScreenLayout(context, browserHeight)
                : _buildNarrowScreenLayout(context, browserHeight),
          ),
        ),
      ],
    );
  }

  /// Builds the wide screen layout (side-by-side).

  Widget _buildWideScreenLayout(BuildContext context, double browserHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File browser on the left.

        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.only(left: 16, right: 8),
            child: SizedBox(
              height: browserHeight,
              child: _buildFileBrowser(),
            ),
          ),
        ),

        // Upload section on the right.

        if (widget.showUpload &&
            _getEffectiveUploadConfig() != null &&
            widget.uploadCallbacks != null)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.only(left: 8, right: 16),
              child: SizedBox(
                height: browserHeight,
                child: SingleChildScrollView(
                  child: SolidFileUploadArea(
                    config: _getEffectiveUploadConfig()!,
                    callbacks: widget.uploadCallbacks!,
                    state: widget.uploadState ?? const SolidFileUploadState(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the narrow screen layout (stacked).

  Widget _buildNarrowScreenLayout(BuildContext context, double browserHeight) {
    return Column(
      children: [
        // File browser on top.

        Card(
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            height: browserHeight * 0.6, // Smaller height for narrow screens
            child: _buildFileBrowser(),
          ),
        ),

        // Upload section below.

        if (widget.showUpload &&
            _getEffectiveUploadConfig() != null &&
            widget.uploadCallbacks != null)
          Card(
            margin: const EdgeInsets.all(16),
            child: SolidFileUploadArea(
              config: _getEffectiveUploadConfig()!,
              callbacks: widget.uploadCallbacks!,
              state: widget.uploadState ?? const SolidFileUploadState(),
            ),
          ),
      ],
    );
  }

  /// Builds the file browser widget.

  Widget _buildFileBrowser() {
    return SolidFileBrowser(
      key: _browserKey,
      browserKey: _browserKey,
      basePath: widget.basePath,
      friendlyFolderName: _getEffectiveFriendlyFolderName(),
      onFileSelected: widget.onFileSelected ??
          (fileName, filePath) {
            debugPrint('File selected: $fileName at $filePath');
          },
      onFileDownload: widget.onFileDownload ??
          (fileName, filePath) {
            debugPrint('Download file: $fileName at $filePath');
          },
      onFileDelete: widget.onFileDelete ??
          (fileName, filePath) {
            debugPrint('Delete file: $fileName at $filePath');
          },
      onImportCsv: widget.onImportCsv ??
          (fileName, filePath) {
            debugPrint('Import CSV: $fileName at $filePath');
          },
      onDirectoryChanged: _handleDirectoryChanged,
    );
  }
}
