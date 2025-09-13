/// Configuration classes for the file upload area widget.
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

  const SolidFileUploadConfig({
    this.showCsvButtons = false,
    this.showProfileButtons = false,
    this.showJsonButtons = true,
    this.showPreviewButtons = true,
    this.formatConfig,
    this.uploadButtonText = 'Upload File',
    this.uploadTooltip,
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

  /// Callback for JSON visualisation.

  final VoidCallback? onVisualiseJson;

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
