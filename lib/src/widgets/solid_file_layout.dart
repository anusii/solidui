/// Layout builders for SolidFile widget.
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

import 'package:solidui/src/widgets/solid_file_upload_area.dart';
import 'package:solidui/src/widgets/solid_file_upload_config.dart';

/// Helper class for building SolidFile layouts.

class SolidFileLayoutBuilder {
  /// Builds the wide screen layout (side-by-side).

  static Widget buildWideScreenLayout({
    required double browserHeight,
    required Widget fileBrowser,
    required bool showUpload,
    required SolidFileUploadConfig? uploadConfig,
    required SolidFileUploadCallbacks uploadCallbacks,
    required SolidFileUploadState uploadState,
    required VoidCallback? onClosePreview,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File browser on the left.
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.only(left: 16, right: 8),
            child: SizedBox(height: browserHeight, child: fileBrowser),
          ),
        ),

        // Upload section on the right.
        if (showUpload && uploadConfig != null)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.only(left: 8, right: 16),
              child: SizedBox(
                height: browserHeight,
                child: SingleChildScrollView(
                  child: SolidFileUploadArea(
                    config: uploadConfig,
                    callbacks: uploadCallbacks,
                    state: uploadState,
                    onClosePreview: onClosePreview,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the narrow screen layout (stacked).

  static Widget buildNarrowScreenLayout({
    required double browserHeight,
    required Widget fileBrowser,
    required bool showUpload,
    required SolidFileUploadConfig? uploadConfig,
    required SolidFileUploadCallbacks uploadCallbacks,
    required SolidFileUploadState uploadState,
    required VoidCallback? onClosePreview,
  }) {
    return Column(
      children: [
        // File browser on top.
        Card(
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            height: browserHeight * 0.6, // Smaller height for narrow screens
            child: fileBrowser,
          ),
        ),

        // Upload section below.
        if (showUpload && uploadConfig != null)
          Card(
            margin: const EdgeInsets.all(16),
            child: SolidFileUploadArea(
              config: uploadConfig,
              callbacks: uploadCallbacks,
              state: uploadState,
              onClosePreview: onClosePreview,
            ),
          ),
      ],
    );
  }
}
