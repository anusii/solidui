/// AppBar visibility helpers for Solid Scaffold.
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

import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Provides visibility checks for AppBar actions.

class SolidAppBarVisibilityHelper {
  /// Determines if an action should be shown based on the available
  /// layout width from [LayoutBuilder] constraints.

  static bool shouldShowAction(
    SolidAppBarAction action,
    SolidAppBarConfig config,
    double layoutWidth,
  ) {
    if (!action.showOnVeryNarrowScreen &&
        layoutWidth < config.veryNarrowScreenThreshold) {
      return false;
    } else if (!action.showOnNarrowScreen &&
        layoutWidth < config.narrowScreenThreshold) {
      return false;
    }
    return true;
  }

  /// Determines if theme toggle should be shown based on the available
  /// layout width from [LayoutBuilder] constraints.

  static bool shouldShowThemeToggle(
    SolidThemeToggleConfig? themeToggle,
    SolidAppBarConfig config,
    double layoutWidth,
  ) {
    if (themeToggle == null || !themeToggle.enabled) return false;
    if (!themeToggle.showInAppBarActions) return false;

    if (!themeToggle.showOnVeryNarrowScreen &&
        layoutWidth < config.veryNarrowScreenThreshold) {
      return false;
    } else if (!themeToggle.showOnNarrowScreen &&
        layoutWidth < config.narrowScreenThreshold) {
      return false;
    }

    return true;
  }
}
