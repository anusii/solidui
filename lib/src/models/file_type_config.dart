/// File type configuration for SolidFile widget.
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

import 'package:solidui/src/models/data_format_config.dart';
import 'package:solidui/src/widgets/solid_file_upload_area.dart';

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

  static FileTypeConfig fromPath(String currentPath) {
    if (currentPath.contains('/blood_pressure')) {
      return FileTypeConfig(
        type: SolidFileType.bloodPressure,
        displayName: 'Blood Pressure Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.bloodPressure,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (currentPath.contains('/vaccination')) {
      return FileTypeConfig(
        type: SolidFileType.vaccination,
        displayName: 'Vaccination Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.vaccination,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (currentPath.contains('/medication')) {
      return FileTypeConfig(
        type: SolidFileType.medication,
        displayName: 'Medication Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.medication,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (currentPath.contains('/diary')) {
      return FileTypeConfig(
        type: SolidFileType.diary,
        displayName: 'Appointments Data',
        showCsvButtons: true,
        formatConfig: SolidFileDataFormats.diary,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else if (currentPath.contains('/profile')) {
      return FileTypeConfig(
        type: SolidFileType.profile,
        displayName: 'Profile Data',
        showProfileButtons: true,
        formatConfig: SolidFileDataFormats.profile,
        uploadTooltip: '''

**Upload**: Tap here to upload a file to your Solid Health Pod.

''',
      );
    } else {
      // General case - extract folder name from path
      final segments = currentPath.split('/');
      String displayName = 'Home Folder';

      if (segments.length >= 3) {
        final folderName = segments[2];

        final words = folderName
            .trim()
            .split(RegExp(r'[_\s]+'))
            .where((w) => w.isNotEmpty)
            .map((w) =>
                w[0].toUpperCase() +
                (w.length > 1 ? w.substring(1).toLowerCase() : ''))
            .toList();

        final formattedName = words.join(' ');

        displayName = '$formattedName Data';
      }

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
