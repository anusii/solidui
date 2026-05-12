/// Navigation style constants.
///
// Time-stamp: <Tuesday 2025-08-06 16:30:00 +1000 Tony Chen>
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

/// Navigation constants used throughout the application.

class NavigationConstants {
  /// The width threshold for determining very narrow screen layout.

  static const double veryNarrowScreenThreshold = 600.0;

  /// The width threshold for determining narrow/wide screen layout.

  static const double narrowScreenThreshold = 800.0;

  /// The width threshold for wide screen layout.

  static const double wideScreenThreshold = 900.0;

  /// The width threshold for very wide screen layout.

  static const double veryWideScreenThreshold = 1000.0;

  /// Minimum width for the navigation rail.

  static const double navRailMinWidth = 84.0;

  /// Vertical alignment for navigation rail items.

  static const double navRailGroupAlignment = -1.0;

  /// Icon size for navigation items.

  static const double navIconSize = 24.0;

  /// Font size for navigation labels.

  static const double navLabelFontSize = 11.0;

  /// Letter spacing for navigation labels.

  static const double navLabelLetterSpacing = 0.3;

  /// Vertical padding for navigation rail destinations.

  static const double navDestinationVerticalPadding = 8.0;

  /// Maximum lines for navigation labels.

  static const int navLabelMaxLines = 2;

  /// Padding for navigation drawer items.

  static const double navDrawerPadding = 15.0;

  /// User info header top padding.

  static const double userHeaderTopPadding = 24.0;

  /// User info header bottom padding.

  static const double userHeaderBottomPadding = 24.0;

  /// User avatar icon size.

  static const double userAvatarSize = 64.0;

  /// User name font size.

  static const double userNameFontSize = 20.0;

  /// WebID font size.

  static const double webIdFontSize = 12.0;

  /// Spacing between user info elements.

  static const double userInfoSpacing = 12.0;

  /// Spacing for WebID text.

  static const double webIdSpacing = 8.0;

  /// Divider height in navigation drawer.

  static const double navDividerHeight = 32.0;

  /// Horizontal padding for WebID container.

  static const double webIdHorizontalPadding = 16.0;

  /// Size of the hamburger button (when no AppBar is present).

  static const double hamburgerButtonSize = 48.0;

  /// Border radius for the hamburger button.

  static const double hamburgerButtonRadius = 12.0;

  /// Icon size for the hamburger button.

  static const double hamburgerIconSize = 24.0;
}
