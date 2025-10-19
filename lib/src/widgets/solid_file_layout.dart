/// Layout builders for SolidFile widget.
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
