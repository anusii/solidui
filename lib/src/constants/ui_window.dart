/// Window and list item size constants for responsive UI.
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang, Jess Moore, Tony Chen

library;

import 'package:flutter/material.dart';

/// Thresholds for window size.

class WindowSize {
  /// Small width threshold.

  static const double smallWidthLimit = 600;

  /// Small height threshold.

  static const double smallHeightLimit = 600;

  /// Boolean describing whether the parent widget is narrow.
  /// Derived from the box constraints found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [constraints] - The box constraints of the parent widget
  ///   where LayoutBuilder() was called.

  bool isNarrowWindow(BoxConstraints constraints) {
    final bool isNarrow;
    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      isNarrow = true;
    } else {
      isNarrow = false;
    }

    return isNarrow;
  }
}

/// Approximate size for grid items used for displaying text in list item.

class ListItemSize {
  /// Approximate height of compressed item in list when list item text
  /// is line wrapped in a narrow mobile phone size window.
  /// (Where each of note title, created date time, modified date time
  /// are line wrapped to two lines.)

  static const double compressedItemHeight = 260;

  /// Approximate height of uncompressed item in list when list item text
  /// is not line wrapped.

  static const double uncompressedItemHeight = 138;

  /// Calculate card aspect ratio to use for gridview builder cards
  /// using the box constraints found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [constraints] - The box constraints of the parent widget
  ///   where LayoutBuilder() was called.

  double calculateCardAspectRatio(BoxConstraints constraints) {
    /// Aspect ratio (width / height) for gridview cards to display note items.

    final double cardAspectRatio;

    // Derive card aspect ratio (width / height).

    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      cardAspectRatio = constraints.maxWidth / compressedItemHeight;
    } else {
      cardAspectRatio = constraints.maxWidth / uncompressedItemHeight;
    }
    return cardAspectRatio;
  }
}
