/// Solid Scaffold Controller for managing subpage navigation.
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

/// Controller for managing SolidScaffold subpage navigation.
///
/// Provides a simple API for navigating to subpages without requiring
/// the user to manage state manually.
///
/// Example:
/// ```dart
/// final controller = SolidScaffoldController();
///
/// SolidScaffold(
///   controller: controller,
///   appBar: SolidAppBarConfig(
///     actions: [
///       SolidAppBarAction(
///         icon: Icons.settings,
///         onPressed: () => controller.navigateToSubpage(SettingsPage()),
///       ),
///     ],
///   ),
/// )
/// ```

class SolidScaffoldController extends ChangeNotifier {
  Widget? _currentSubpage;

  /// Get the current subpage being displayed.

  Widget? get currentSubpage => _currentSubpage;

  /// Navigate to a subpage.
  ///
  /// The subpage will be displayed using bodyOverride, taking precedence
  /// over menu-based navigation.

  void navigateToSubpage(Widget subpage) {
    _currentSubpage = subpage;
    notifyListeners();
  }

  /// Clear the current subpage and return to menu navigation.

  void clearSubpage() {
    _currentSubpage = null;
    notifyListeners();
  }

  /// Check if a subpage is currently displayed.

  bool get hasSubpage => _currentSubpage != null;

  @override
  void dispose() {
    _currentSubpage = null;
    super.dispose();
  }
}
