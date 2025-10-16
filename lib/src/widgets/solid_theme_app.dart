/// Convenience wrapper for MaterialApp with SolidUI theme management.
///
// Time-stamp: <Monday 2025-08-25 15:30:00 +1000 Tony Chen>
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

import 'package:solidui/src/widgets/solid_theme.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

class SolidThemeApp extends StatefulWidget {
  /// The title of the application.

  final String title;

  /// The light theme data. If null, uses SolidTheme.lightTheme().

  final ThemeData? theme;

  /// The dark theme data. If null, uses SolidTheme.darkTheme().

  final ThemeData? darkTheme;

  /// Optional theme configuration for customising default themes.

  final SolidThemeConfig? themeConfig;

  /// The home widget.

  final Widget home;

  /// Whether to show the debug banner.

  final bool debugShowCheckedModeBanner;

  /// Creates a SolidThemeApp with automatic theme management.

  const SolidThemeApp({
    super.key,
    required this.title,
    required this.home,
    this.theme,
    this.darkTheme,
    this.themeConfig,
    this.debugShowCheckedModeBanner = false,
  });

  @override
  State<SolidThemeApp> createState() => _SolidThemeAppState();
}

class _SolidThemeAppState extends State<SolidThemeApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    // Ensure the theme notifier is properly initialised before first build.

    await solidThemeNotifier.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while theme is being initialised.

    if (!_isInitialized) {
      return MaterialApp(
        title: widget.title,
        theme: widget.theme ??
            (widget.themeConfig?.lightTheme ?? SolidTheme.lightTheme()),
        darkTheme: widget.darkTheme ??
            (widget.themeConfig?.darkTheme ?? SolidTheme.darkTheme()),
        themeMode: ThemeMode.system, // Use system theme as fallback
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AnimatedBuilder(
      animation: solidThemeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: widget.title,
          theme: widget.theme ??
              (widget.themeConfig?.lightTheme ?? SolidTheme.lightTheme()),
          darkTheme: widget.darkTheme ??
              (widget.themeConfig?.darkTheme ?? SolidTheme.darkTheme()),
          themeMode: solidThemeNotifier.themeMode,
          debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
          home: widget.home,
        );
      },
    );
  }
}
