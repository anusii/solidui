/// File service widget.
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

import 'package:solidpod/solidpod.dart' show getDataDirPath;

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
  ///
  /// If null, defaults to the app data directory path (e.g. 'appname/data').
  /// If the app data directory does not exist, falls back to the pod root ('').

  final String? basePath;

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
    this.basePath,
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
        autoConfig = false; // Legacy mode does not use auto-config.

  /// Default base path constant representing the pod root.

  static const String podRoot = '';

  @override
  State<SolidFile> createState() => _SolidFileState();
}

class _SolidFileState extends State<SolidFile> {
  late GlobalKey<SolidFileBrowserState> _browserKey;
  late String _currentPath;

  /// The resolved base path (either from widget or computed default).

  String? _resolvedBasePath;

  /// Whether the base path is currently being resolved.

  bool _isResolvingBasePath = true;

  @override
  void initState() {
    super.initState();
    _browserKey = widget.browserKey ?? GlobalKey<SolidFileBrowserState>();
    _resolveBasePath();
  }

  /// Resolves the base path asynchronously.
  ///
  /// If basePath is provided, uses it directly.
  /// Otherwise, defaults to the app data directory path.
  /// Falls back to pod root if the app data directory cannot be determined.

  Future<void> _resolveBasePath() async {
    if (widget.basePath != null) {
      // Use the provided basePath directly.

      _resolvedBasePath = widget.basePath;
      _currentPath = widget.currentPath ?? _resolvedBasePath!;
      setState(() {
        _isResolvingBasePath = false;
      });
      return;
    }

    // Attempt to get the app data directory path.

    try {
      final appDataPath = await getDataDirPath();
      _resolvedBasePath = appDataPath;
    } catch (e) {
      // Fall back to pod root if getDataDirPath fails.

      debugPrint('Failed to get app data path, falling back to pod root: $e');
      _resolvedBasePath = SolidFile.podRoot;
    }

    _currentPath = widget.currentPath ?? _resolvedBasePath!;
    setState(() {
      _isResolvingBasePath = false;
    });
  }

  /// Gets the effective base path (resolved or empty string as fallback).

  String get _effectiveBasePath => _resolvedBasePath ?? SolidFile.podRoot;

  @override
  void didUpdateWidget(covariant SolidFile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle basePath changes.

    if (oldWidget.basePath != widget.basePath) {
      _resolveBasePath();
      return;
    }

    final oldPath = oldWidget.currentPath ?? _effectiveBasePath;
    final newPath = widget.currentPath ?? _effectiveBasePath;

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
    // Show loading indicator whilst resolving the base path.

    if (_isResolvingBasePath) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Resolving file path...'),
          ],
        ),
      );
    }

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
                    // Default behaviour: reset to base path.

                    setState(() {
                      _currentPath = _effectiveBasePath;
                    });

                    // Refresh the browser to the base path.

                    _browserKey.currentState?.navigateToPath(_effectiveBasePath);
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
                            _effectiveBasePath,
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
                            _effectiveBasePath,
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
      basePath: _effectiveBasePath,
      friendlyFolderName: SolidFileHelpers.getEffectiveFriendlyFolderName(
        _currentPath,
        _effectiveBasePath,
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
