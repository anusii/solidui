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

/// Predefined file types for different data categories.

enum SolidFileType {
  bloodPressure,
  vaccination,
  medication,
  diary,
  profile,
  general,
}

/// Configuration for different file types.

class FileTypeConfig {
  /// The file type.

  final SolidFileType type;

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
    required this.type,
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

  static FileTypeConfig fromPath(String currentPath, [String? basePath]) {
    // Normalise the path for consistent pattern matching.

    final normalisedPath = PathUtils.normalise(currentPath);

    if (normalisedPath.contains('/blood_pressure') ||
        normalisedPath.contains('blood_pressure/') ||
        normalisedPath.endsWith('blood_pressure')) {
      return const FileTypeConfig(
        type: SolidFileType.bloodPressure,
        displayName: 'Blood Pressure Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.bloodPressure,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (normalisedPath.contains('/vaccination') ||
        normalisedPath.contains('vaccination/') ||
        normalisedPath.endsWith('vaccination')) {
      return const FileTypeConfig(
        type: SolidFileType.vaccination,
        displayName: 'Vaccination Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.vaccination,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (normalisedPath.contains('/medication') ||
        normalisedPath.contains('medication/') ||
        normalisedPath.endsWith('medication')) {
      return const FileTypeConfig(
        type: SolidFileType.medication,
        displayName: 'Medication Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.medication,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (normalisedPath.contains('/diary') ||
        normalisedPath.contains('diary/') ||
        normalisedPath.endsWith('diary')) {
      return const FileTypeConfig(
        type: SolidFileType.diary,
        displayName: 'Appointments Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.diary,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (normalisedPath.contains('/profile') ||
        normalisedPath.contains('profile/') ||
        normalisedPath.endsWith('profile')) {
      return const FileTypeConfig(
        type: SolidFileType.profile,
        displayName: 'Profile Data',
        showProfileButtons: true,
        formatConfig: SolidFileDataFormats.profile,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else {
      // General case - use the existing friendly folder name logic for
      // consistency. If basePath is provided, use it; otherwise, construct a
      // reasonable default.

      String effectiveBasePath =
          basePath != null ? PathUtils.normalise(basePath) : '';

      if (effectiveBasePath.isEmpty) {
        final segments =
            normalisedPath.split('/').where((s) => s.isNotEmpty).toList();

        // Construct a reasonable base path - typically the first 2 segments
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
        type: SolidFileType.general,
        displayName: displayName,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    }
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
