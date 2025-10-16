/// Helper methods for SolidFile widget.
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
