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

import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_browser_builder.dart';
import 'package:solidui/src/widgets/solid_file_callbacks.dart';
import 'package:solidui/src/widgets/solid_file_helpers.dart';
import 'package:solidui/src/widgets/solid_file_layout.dart';
import 'package:solidui/src/widgets/solid_file_models.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

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

  /// Callback when preview is closed by user.

  final VoidCallback? onClosePreview;

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
    this.onClosePreview,
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
        onClosePreview = callbacks.onClosePreview,
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

  /// Gets the effective upload callbacks, either from the provided callbacks
  /// or default implementations with working file operations.

  SolidFileUploadCallbacks _getEffectiveUploadCallbacks() {
    if (widget.uploadCallbacks != null) {
      return widget.uploadCallbacks!;
    }

    // Use default callbacks helper.

    return SolidFileDefaultCallbacks.createUploadCallbacks(
      context,
      _currentPath,
      _browserKey,
    );
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
    final isWideScreen = SolidFileHelpers.shouldUseWideScreen(
      context,
      widget.forceWideScreen,
    );
    final browserHeight = SolidFileHelpers.getBrowserHeight(
      context,
      widget.browserHeight,
    );

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
          child: Column(
            children: [
              // File browser and upload area.

              Expanded(
                child: SingleChildScrollView(
                  child: isWideScreen
                      ? SolidFileLayoutBuilder.buildWideScreenLayout(
                          browserHeight: browserHeight,
                          fileBrowser: _buildFileBrowser(),
                          showUpload: widget.showUpload,
                          uploadConfig:
                              SolidFileHelpers.getEffectiveUploadConfig(
                            _currentPath,
                            widget.basePath,
                            widget.autoConfig,
                            widget.showUpload,
                            widget.uploadConfig,
                          ),
                          uploadCallbacks: _getEffectiveUploadCallbacks(),
                          uploadState: widget.uploadState ??
                              const SolidFileUploadState(),
                          onClosePreview: widget.onClosePreview,
                        )
                      : SolidFileLayoutBuilder.buildNarrowScreenLayout(
                          browserHeight: browserHeight,
                          fileBrowser: _buildFileBrowser(),
                          showUpload: widget.showUpload,
                          uploadConfig:
                              SolidFileHelpers.getEffectiveUploadConfig(
                            _currentPath,
                            widget.basePath,
                            widget.autoConfig,
                            widget.showUpload,
                            widget.uploadConfig,
                          ),
                          uploadCallbacks: _getEffectiveUploadCallbacks(),
                          uploadState: widget.uploadState ??
                              const SolidFileUploadState(),
                          onClosePreview: widget.onClosePreview,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the file browser widget.

  Widget _buildFileBrowser() {
    return SolidFileBrowserBuilder.build(
      browserKey: _browserKey,
      basePath: widget.basePath,
      friendlyFolderName: SolidFileHelpers.getEffectiveFriendlyFolderName(
        _currentPath,
        widget.basePath,
        widget.autoConfig,
        widget.friendlyFolderName,
      ),
      onFileSelected: widget.onFileSelected,
      onFileDownload: widget.onFileDownload,
      onFileDelete: widget.onFileDelete,
      onImportCsv: widget.onImportCsv,
      onDirectoryChanged: _handleDirectoryChanged,
      uploadCallbacks: widget.uploadCallbacks,
    );
  }
}
