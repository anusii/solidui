/// Helper methods for SolidFile widget.
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

import 'package:path/path.dart' as path;

import 'package:solidui/src/models/file_type_config.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// Helper class for SolidFile widget utilities.

class SolidFileHelpers {
  /// Determines if we should use wide screen layout.

  static bool shouldUseWideScreen(BuildContext context, bool? forceWideScreen) {
    if (forceWideScreen != null) {
      return forceWideScreen;
    }
    return MediaQuery.of(context).size.width > 800;
  }

  /// Gets the effective browser height.

  static double getBrowserHeight(BuildContext context, double? browserHeight) {
    if (browserHeight != null) {
      return browserHeight;
    }
    return MediaQuery.of(context).size.height * 0.7;
  }

  /// Gets the effective upload configuration, either from the provided config
  /// or auto-generated based on the current path when autoConfig is true.

  static SolidFileUploadConfig? getEffectiveUploadConfig(
    String currentPath,
    String basePath,
    bool autoConfig,
    bool showUpload,
    SolidFileUploadConfig? uploadConfig,
  ) {
    if (uploadConfig != null) {
      return uploadConfig;
    }

    if (autoConfig && showUpload) {
      final typeConfig = FileTypeConfig.fromPath(currentPath, basePath);
      return typeConfig.createUploadConfig();
    }

    return null;
  }

  /// Gets the effective friendly folder name, either from the provided name
  /// or auto-generated based on the current path when autoConfig is true.

  static String getEffectiveFriendlyFolderName(
    String currentPath,
    String basePath,
    bool autoConfig,
    String? friendlyFolderName,
  ) {
    if (friendlyFolderName != null) {
      return friendlyFolderName;
    }

    if (autoConfig) {
      final typeConfig = FileTypeConfig.fromPath(currentPath, basePath);
      return typeConfig.displayName;
    }

    return 'Files';
  }

  /// Helper function to get a user-friendly name from the path.

  static String getFriendlyFolderName(String pathValue, String basePath) {
    final String root = basePath;
    if (pathValue.isEmpty || pathValue == root) {
      return 'Home Folder';
    }

    // Use path.basename to safely get the last component.

    final dirName = path.basename(pathValue);

    switch (dirName) {
      case 'diary':
        return 'Appointments Data';
      case 'blood_pressure':
        return 'Blood Pressure Data';
      case 'medication':
        return 'Medication Data';
      case 'vaccination':
        return 'Vaccination Data';
      case 'profile':
        return 'Profile Data';
      case 'health_plan':
        return 'Health Plan Data';
      case 'pathology':
        return 'Pathology Data';
      case 'tv_shows':
        return 'TV Shows';

      default:
        // Basic formatting for unknown folders:
        // capitalise first letter, replace underscores.

        if (dirName.isEmpty) return 'Folder';
        String formattedName = dirName.replaceAll('_', ' ').trim();
        formattedName = formattedName
            .split(RegExp(r'\s+'))
            .map(
              (w) => w.isEmpty
                  ? w
                  : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
            )
            .join(' ');
        return formattedName;
    }
  }
}
