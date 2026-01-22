/// Solid POD configuration constants.
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

/// Configuration constants for Solid POD servers.

class SolidConfig {
  /// Default production Solid POD server URL.

  static const String defaultServerUrl = 'https://pods.solidcommunity.au';

  /// Default background image asset path.

  static const String defaultImagePath = 'assets/images/app_image.jpg';

  /// Default logo asset path.

  static const String defaultLogoPath = 'assets/images/app_icon.png';

  /// Default background image for the login screen.

  static const AssetImage defaultImage = AssetImage(defaultImagePath);

  /// Default logo for the login screen.

  static const AssetImage defaultLogo = AssetImage(defaultLogoPath);

  /// Default background image from solidui package (fallback).

  static const AssetImage soliduiDefaultImage = AssetImage(
    defaultImagePath,
    package: 'solidui',
  );

  /// Default logo from solidui package (fallback).

  static const AssetImage soliduiDefaultLogo = AssetImage(
    defaultLogoPath,
    package: 'solidui',
  );

  // Prevent instantiation.

  SolidConfig._();
}
