/// Asset resolution helper for SolidLogin widget.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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
import 'package:flutter/services.dart' show rootBundle;

import 'package:solidui/src/constants/solid_config.dart';

/// Helper class for resolving SolidLogin image assets with fallback logic.

class SolidLoginAssetHelper {
  /// Attempts to resolve an asset with fallback to alternative formats.
  ///
  /// [requestedAsset] is the AssetImage specified by the user.
  /// [defaultBaseName] is the base name for fallback (e.g., 'app_image').
  ///
  /// Returns the first available asset in this order:
  /// 1. The requested asset if it exists
  /// 2. Same file name with alternate extension (png->jpg or jpg->png)
  /// 3. The solidui package default

  static Future<AssetImage> resolveAssetWithFallback(
    AssetImage requestedAsset,
    String defaultBaseName,
  ) async {
    final requestedPath = requestedAsset.assetName;
    if (await assetExists(requestedPath)) {
      return requestedAsset;
    }

    final baseName = extractBaseName(requestedPath);
    final extension = extractExtension(requestedPath);
    final directory = extractDirectory(requestedPath);

    final alternateExtension = extension.toLowerCase() == 'png' ? 'jpg' : 'png';
    final alternatePath = '$directory$baseName.$alternateExtension';
    if (await assetExists(alternatePath)) {
      return AssetImage(alternatePath);
    }

    return defaultBaseName == 'app_image'
        ? SolidConfig.soliduiDefaultImage
        : SolidConfig.soliduiDefaultLogo;
  }

  /// Extracts the directory path from an asset path.

  static String extractDirectory(String path) {
    final lastSlash = path.lastIndexOf('/');
    return lastSlash != -1 ? path.substring(0, lastSlash + 1) : '';
  }

  /// Extracts the file extension from an asset path.

  static String extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    return dotIndex != -1 ? path.substring(dotIndex + 1) : '';
  }

  /// Extracts the base name (without extension) from an asset path.

  static String extractBaseName(String path) {
    final fileName = path.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
  }

  /// Checks whether an asset exists in the asset bundle.

  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
