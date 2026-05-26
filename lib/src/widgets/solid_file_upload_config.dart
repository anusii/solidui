/// Configuration classes for the file upload area widget.
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

import 'package:solidui/src/models/data_format_config.dart';

/// Configuration for the file upload area.

class SolidFileUploadConfig {
  /// Whether to show CSV import/export buttons.

  final bool showCsvButtons;

  /// Whether to show Profile import/export buttons.

  final bool showProfileButtons;

  /// Whether to show JSON operations.

  final bool showJsonButtons;

  /// Whether to show file preview options.

  final bool showPreviewButtons;

  /// The data format configuration to display.

  final DataFormatConfig? formatConfig;

  /// Custom upload button text.

  final String uploadButtonText;

  /// Custom upload tooltip message.

  final String? uploadTooltip;

  /// Optional whitelist of file extensions allowed when uploading.
  ///
  /// Extensions may be supplied with or without a leading dot and are matched
  /// case-insensitively (e.g. `['csv', '.json', 'PDF']`). When null or empty,
  /// no client-side restriction is applied and any file may be selected.
  ///
  /// The same allow list is honoured by every upload entry point fed by the
  /// default callbacks, ensuring a single source of truth for the restriction.

  final List<String>? allowedExtensions;

  const SolidFileUploadConfig({
    this.showCsvButtons = false,
    this.showProfileButtons = false,
    this.showJsonButtons = true,
    this.showPreviewButtons = true,
    this.formatConfig,
    this.uploadButtonText = 'Upload File',
    this.uploadTooltip,
    this.allowedExtensions,
  });
}

/// Callbacks for file upload area operations.

class SolidFileUploadCallbacks {
  /// Callback for file upload.

  final VoidCallback? onUpload;

  /// Callback for CSV import.

  final VoidCallback? onImportCsv;

  /// Callback for CSV export.

  final VoidCallback? onExportCsv;

  /// Callback for successful CSV import.

  final Function(String importType)? onImportSuccess;

  /// Callback for Profile import.

  final VoidCallback? onImportProfile;

  /// Callback for Profile export.

  final VoidCallback? onExportProfile;

  /// Callback for JSON visualisation from POD.

  final VoidCallback? onVisualiseJson;

  /// Callback for selecting local JSON files.

  final VoidCallback? onSelectLocalJson;

  /// Callback for file preview.

  final VoidCallback? onPreviewFile;

  /// Callback for PDF to JSON conversion.

  final VoidCallback? onConvertToJson;

  const SolidFileUploadCallbacks({
    this.onUpload,
    this.onImportCsv,
    this.onExportCsv,
    this.onImportSuccess,
    this.onImportProfile,
    this.onExportProfile,
    this.onVisualiseJson,
    this.onSelectLocalJson,
    this.onPreviewFile,
    this.onConvertToJson,
  });

  /// Creates a default instance with empty (no-op) callbacks for all
  /// operations. This allows all upload features to be enabled but with
  /// default behavior.

  const SolidFileUploadCallbacks.defaults()
      : onUpload = _defaultCallback,
        onImportCsv = _defaultCallback,
        onExportCsv = _defaultCallback,
        onImportSuccess = null,
        onImportProfile = _defaultCallback,
        onExportProfile = _defaultCallback,
        onVisualiseJson = _defaultCallback,
        onSelectLocalJson = _defaultCallback,
        onPreviewFile = _defaultCallback,
        onConvertToJson = _defaultCallback;

  /// Creates a default instance with disabled callbacks (null values).
  /// This will make all upload features appear disabled/greyed out.

  const SolidFileUploadCallbacks.disabled()
      : onUpload = null,
        onImportCsv = null,
        onExportCsv = null,
        onImportSuccess = null,
        onImportProfile = null,
        onExportProfile = null,
        onVisualiseJson = null,
        onSelectLocalJson = null,
        onPreviewFile = null,
        onConvertToJson = null;

  /// Default no-operation callback that does nothing when invoked.

  static void _defaultCallback() {
    // Default implementation - no operation.
    // Users can override specific callbacks if needed.
  }
}

/// State information for the upload area.

class SolidFileUploadState {
  /// Whether upload is in progress.

  final bool uploadInProgress;

  /// Whether import is in progress.

  final bool importInProgress;

  /// Whether export is in progress.

  final bool exportInProgress;

  /// Path to uploaded file.

  final String? uploadedFilePath;

  /// Whether upload is done.

  final bool uploadDone;

  /// File preview content.

  final String? filePreview;

  /// Whether to show preview.

  final bool showPreview;

  const SolidFileUploadState({
    this.uploadInProgress = false,
    this.importInProgress = false,
    this.exportInProgress = false,
    this.uploadedFilePath,
    this.uploadDone = false,
    this.filePreview,
    this.showPreview = false,
  });

  SolidFileUploadState copyWith({
    bool? uploadInProgress,
    bool? importInProgress,
    bool? exportInProgress,
    String? uploadedFilePath,
    bool? uploadDone,
    String? filePreview,
    bool? showPreview,
  }) {
    return SolidFileUploadState(
      uploadInProgress: uploadInProgress ?? this.uploadInProgress,
      importInProgress: importInProgress ?? this.importInProgress,
      exportInProgress: exportInProgress ?? this.exportInProgress,
      uploadedFilePath: uploadedFilePath ?? this.uploadedFilePath,
      uploadDone: uploadDone ?? this.uploadDone,
      filePreview: filePreview ?? this.filePreview,
      showPreview: showPreview ?? this.showPreview,
    );
  }
}
