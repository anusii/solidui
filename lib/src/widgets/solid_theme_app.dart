/// Convenience wrapper for MaterialApp with SolidUI theme management.
///
// Time-stamp: <Monday 2025-08-25 15:30:00 +1000 Tony Chen>
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
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
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
