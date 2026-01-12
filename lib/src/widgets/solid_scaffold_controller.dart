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
  int _navigationVersion = 0;
  int? _selectedMenuIndex;

  /// Get the current subpage being displayed.
  ///
  /// The subpage is wrapped with a unique key to ensure it is rebuilt
  /// each time [navigateToSubpage] is called, even for the same page type.

  Widget? get currentSubpage {
    if (_currentSubpage == null) return null;

    // Wrap with KeyedSubtree using the navigation version to force rebuild.

    return KeyedSubtree(
      key: ValueKey<int>(_navigationVersion),
      child: _currentSubpage!,
    );
  }

  /// Get the currently selected menu index.
  ///
  /// Returns null if no index has been set via [navigateToMenuIndex].
  /// When null, the SolidScaffold will use its own internal state.

  int? get selectedMenuIndex => _selectedMenuIndex;

  /// Navigate to a subpage.
  ///
  /// The subpage will be displayed using bodyOverride, taking precedence
  /// over menu-based navigation.
  ///
  /// Each call to this method will force a complete rebuild of the subpage,
  /// even when navigating to the same page type. This ensures that the page
  /// state is always refreshed.
  ///
  /// When navigating to a subpage that is not in the Navigation Rail menu,
  /// the Navigation Rail will have no item highlighted. If you want to
  /// navigate to a page that corresponds to a menu item and keep it
  /// highlighted, use [navigateToMenuIndex] instead.

  void navigateToSubpage(Widget subpage) {
    _navigationVersion++;
    _currentSubpage = subpage;
    _selectedMenuIndex = -1;
    notifyListeners();
  }

  /// Navigate to a menu item by index.
  ///
  /// This method allows navigation to a specific menu item in the Navigation
  /// Rail whilst also synchronising the highlighted state of the rail.
  ///
  /// Use this method when you want an AppBar action button to navigate to
  /// a page that also exists in the Navigation Rail, ensuring the rail item
  /// is properly highlighted.
  ///
  /// If [subpage] is provided, it will be displayed as a body override.
  /// If [subpage] is null, the menu item's configured child widget will be
  /// shown.
  ///
  /// Example:
  /// ```dart
  /// // Navigate to the second menu item (index 1) and highlight it
  /// controller.navigateToMenuIndex(1);
  ///
  /// // Navigate to the third menu item with a custom subpage
  /// controller.navigateToMenuIndex(2, subpage: CustomDetailPage());
  /// ```

  void navigateToMenuIndex(int index, {Widget? subpage}) {
    _selectedMenuIndex = index;
    if (subpage != null) {
      _navigationVersion++;
      _currentSubpage = subpage;
    } else {
      _currentSubpage = null;
    }
    notifyListeners();
  }

  /// Clear the current subpage and return to menu navigation.

  void clearSubpage() {
    _currentSubpage = null;
    notifyListeners();
  }

  /// Clear the selected menu index.

  void clearMenuIndex() {
    _selectedMenuIndex = null;
    notifyListeners();
  }

  /// Check if a subpage is currently displayed.

  bool get hasSubpage => _currentSubpage != null;

  /// Check if the controller is managing the menu index.

  bool get hasMenuIndex => _selectedMenuIndex != null;

  @override
  void dispose() {
    _currentSubpage = null;
    _selectedMenuIndex = null;
    super.dispose();
  }
}
