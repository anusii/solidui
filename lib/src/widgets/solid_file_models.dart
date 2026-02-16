/// Models and configurations for SolidFile widget.
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

import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// Configuration for the SolidFile widget.

class SolidFileConfig {
  /// Whether to show the back button.

  final bool showBackButton;

  /// Text for the back button.

  final String backButtonText;

  /// Whether to use wide screen layout.

  final bool? forceWideScreen;

  /// Custom height for the file browser.

  final double? browserHeight;

  const SolidFileConfig({
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

  /// Callback when preview is closed by user.

  final VoidCallback? onClosePreview;

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
    this.onClosePreview,
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
