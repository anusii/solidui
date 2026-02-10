/// File type configuration for SolidFile widget.
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

import 'package:solidui/src/models/data_format_config.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/widgets/solid_file_helpers.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// A callback type for resolving file type configurations from a path.
///
/// Applications can provide their own resolver to map directory paths to
/// specific [FileTypeConfig] instances. Return `null` to fall through to the
/// default generic behaviour.

typedef FileTypeResolver = FileTypeConfig? Function(
  String normalisedPath,
  String? basePath,
);

/// Configuration for different file types.

class FileTypeConfig {
  /// A string identifier for this file type (e.g. 'general', 'blood_pressure').
  ///
  /// Applications may define their own type identifiers.

  final String typeId;

  /// Display name for the folder.

  final String displayName;

  /// Whether to show CSV import/export buttons.

  final bool showCsvButtons;

  /// Whether to show Profile import/export buttons.

  final bool showProfileButtons;

  /// Whether to show JSON operations.

  final bool showJsonButtons;

  /// Whether to show file preview options.

  final bool showPreviewButtons;

  /// Data format configuration for this file type.

  final DataFormatConfig? formatConfig;

  /// Upload button text.

  final String uploadButtonText;

  /// Upload tooltip text.

  final String uploadTooltip;

  const FileTypeConfig({
    this.typeId = 'general',
    required this.displayName,
    this.showCsvButtons = false,
    this.showProfileButtons = false,
    this.showJsonButtons = true,
    this.showPreviewButtons = true,
    this.formatConfig,
    this.uploadButtonText = 'Upload',
    this.uploadTooltip = 'Upload a file',
  });

  /// Gets the file type configuration based on the current path.

  static FileTypeConfig fromPath(
    String currentPath, [
    String? basePath,
    FileTypeResolver? resolver,
  ]) {
    // Normalise the path for consistent pattern matching.

    final normalisedPath = PathUtils.normalise(currentPath);

    // Attempt app-specific resolution first.

    if (resolver != null) {
      final resolved = resolver(normalisedPath, basePath);
      if (resolved != null) return resolved;
    }

    // Generic fallback — derive a friendly display name from the path.

    String effectiveBasePath =
        basePath != null ? PathUtils.normalise(basePath) : '';

    if (effectiveBasePath.isEmpty) {
      final segments =
          normalisedPath.split('/').where((s) => s.isNotEmpty).toList();

      // Construct a reasonable base path — typically the first 2 segments
      // for most cases.

      if (segments.length >= 2) {
        effectiveBasePath = '${segments[0]}/${segments[1]}';
      } else if (segments.length == 1) {
        effectiveBasePath = segments[0];
      }
    }

    final friendlyName = SolidFileHelpers.getFriendlyFolderName(
      normalisedPath,
      effectiveBasePath,
    );

    String displayName =
        friendlyName == 'Home' ? 'Home Folder' : friendlyName;

    return FileTypeConfig(
      typeId: 'general',
      displayName: displayName,
      uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Pod.

''',
    );
  }

  /// Creates the upload configuration for this file type.

  SolidFileUploadConfig createUploadConfig() {
    return SolidFileUploadConfig(
      showCsvButtons: showCsvButtons,
      showProfileButtons: showProfileButtons,
      showJsonButtons: showJsonButtons,
      showPreviewButtons: showPreviewButtons,
      formatConfig: formatConfig,
      uploadButtonText: uploadButtonText,
      uploadTooltip: uploadTooltip,
    );
  }
}
